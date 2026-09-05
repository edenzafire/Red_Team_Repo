// Package proto: mensagens + criptografia compartilhadas (T1573.001).
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

const CHUNK_SIZE = 256 * 1024 // 256 KB — mesmo padrão do Cobalt Strike

type Message struct {
	ID      string   `json:"id"`
	Kind    string   `json:"kind"`
	Info    SysInfo  `json:"info,omitempty"`
	Results []Result `json:"results,omitempty"`
	Tasks   []Task   `json:"tasks,omitempty"`
}

type SysInfo struct {
	Hostname string `json:"hostname"`
	User     string `json:"user"`
	OS       string `json:"os"`
	Arch     string `json:"arch"`
	PID      int    `json:"pid"`
}

type Task struct {
	UID  string `json:"uid"`
	Cmd  string `json:"cmd"`
	Data []byte `json:"data,omitempty"`
}

// Result: Seq/Total/FileName/Hash suportam transferência em chunks (T1105).
type Result struct {
	UID      string `json:"uid"`
	Output   string `json:"output"`
	Success  bool   `json:"success"`
	Data     []byte `json:"data,omitempty"`
	Seq      int    `json:"seq,omitempty"`
	Total    int    `json:"total,omitempty"`
	FileName string `json:"filename,omitempty"`
	Hash     string `json:"hash,omitempty"` // SHA-256 do arquivo completo
}

func DeriveKey(secret string) []byte {
	h := sha256.Sum256([]byte(secret))
	return h[:]
}

func Encrypt(key, plaintext []byte) (string, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}
	nonce := make([]byte, gcm.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(
		gcm.Seal(nonce, nonce, plaintext, nil)), nil
}

func Decrypt(key []byte, enc string) ([]byte, error) {
	data, err := base64.StdEncoding.DecodeString(enc)
	if err != nil {
		return nil, err
	}
	block, _ := aes.NewCipher(key)
	gcm, _ := cipher.NewGCM(block)
	if len(data) < gcm.NonceSize() {
		return nil, errors.New("ciphertext truncado")
	}
	nonce, ct := data[:gcm.NonceSize()], data[gcm.NonceSize():]
	return gcm.Open(nil, nonce, ct, nil)
}

func EncodeMessage(key []byte, msg any) (string, error) {
	b, err := json.Marshal(msg)
	if err != nil {
		return "", err
	}
	return Encrypt(key, b)
}

func DecodeMessage(key []byte, data string, out any) error {
	b, err := Decrypt(key, data)
	if err != nil {
		return err
	}
	return json.Unmarshal(b, out)
}

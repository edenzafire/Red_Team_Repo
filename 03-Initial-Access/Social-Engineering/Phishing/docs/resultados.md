# Resultados dos Testes — Bypass do Microsoft Defender

## Ambiente de teste

| Item | Valor |
|---|---|
| Alvo | Windows 10 (Acer físico / VM Win10) |
| AV | Microsoft Defender (antivírus + SmartScreen + cloud) |
| Servidor de entrega | AWS EC2 + Nginx + Let's Encrypt |
| Navegador | Chrome / Edge |
| Atacante | Debian 12 (QEMU/KVM no host Ubuntu 24.04) |

## Registro de evolução

### v1 — XOR fixo + CreateThread (pipeline original)

| Item | Resultado |
|---|---|
| Entrega (HTML → ISO) | ⚠️ Chrome bloqueou download (HTTP sem TLS, "arquivo perigoso") |
| Execução com Defender OFF | ✅ sessão Meterpreter recebida |
| Execução com Defender ON | ❌ detectado |
| Detecção (histórico de proteção) | `PREENCHER: ex. Trojan:Win32/Wacatac.B!ml` |
| Camada provável | estática (assinatura do shellcode/loader) |

**Análise:** payload como array em `.data` + XOR de chave constante `0x77`
+ `CreateThread` em shellcode = trifecta de assinaturas.

### v2 — Rolling XOR + recurso RCDATA + callback exec

| Item | Resultado |
|---|---|
| Entrega (HTTPS + smuggling) | ⏳ pendente |
| Execução com Defender OFF | ⏳ pendente |
| Execução com Defender ON | ⏳ pendente |
| Detecção (histórico de proteção) | — |
| Camada provável | — |

### Matriz de diagnóstico (preencher em cada falha)

| Mensagem do Defender | Camada | Contra-medida |
|---|---|---|
| `Trojan:Win32/...` ao salvar | estática (disco) | encrypt mais forte, recurso, menos entropia |
| `Behavior:Win32/...` na execução | comportamental | indirect syscall, unhooking, callbacks |
| Bloqueio na memória (ETW/AMSI) | memória | patch AMSI, syscall indireto |
| SmartScreen bloqueou | reputação | assinatura, metadados, domínio mais velho |

## Lições aprendidas

- (preencher)

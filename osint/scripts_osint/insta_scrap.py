#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Instagram OSINT (versão simplificada e refatorada, com comentários)
⚠️ Uso apenas didático/educacional.

Melhorias aplicadas:
- Sessão HTTP com timeout e retries simples
- Leitura de SESSIONID via argumento ou variável de ambiente
- Opção de mostrar/ocultar e-mail e telefone (--show-email / --show-phone)
- Exportação JSON/CSV com flatten
- Flags extras (--format both)
- Tratamento de erros mais claros
"""

import os
import sys
import json
import csv
import argparse
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from datetime import datetime

# ----------------------------
# Funções utilitárias
# ----------------------------

def mask_email(s: str) -> str:
    """Mascara um e-mail, deixando só as 2 primeiras letras do nome."""
    try:
        name, dom = s.split("@", 1)
        return (name[:2] + "***@" + dom) if len(name) >= 2 else "***@" + dom
    except Exception:
        return s

def mask_phone(cc: str, num: str) -> str:
    """Mascara um número de telefone, deixando só o começo e o fim."""
    tail = num[-3:] if len(num) >= 3 else num
    return f"+{cc} {num[:2]}******{tail}"

def flatten(d: dict, prefix: str = "", sep: str = ".") -> dict:
    """Transforma dicionário aninhado em um nível só (para CSV)."""
    out = {}
    for k, v in d.items():
        kk = f"{prefix}{sep}{k}" if prefix else k
        if isinstance(v, dict):
            out.update(flatten(v, kk, sep))
        else:
            out[kk] = v
    return out

# ----------------------------
# Sessão HTTP com retries
# ----------------------------

def build_session():
    """Cria uma sessão HTTP com tentativas automáticas de retry."""
    s = requests.Session()
    retries = Retry(
        total=2,
        backoff_factor=0.5,
        status_forcelist=(429, 500, 502, 503, 504),
        allowed_methods=("GET", "POST"),
        raise_on_status=False,
    )
    adapter = HTTPAdapter(max_retries=retries)
    s.mount("http://", adapter)
    s.mount("https://", adapter)
    return s

# ----------------------------
# Cliente Instagram
# ----------------------------

class InstagramClient:
    BASE = "https://i.instagram.com/api/v1"

    def __init__(self, session, sessionid: str):
        # Sessão HTTP + cookie do Instagram
        self.session = session
        self.cookies = {"sessionid": sessionid}

    def get_user_id(self, username: str):
        """Obtém o ID numérico do usuário a partir do username."""
        url = f"{self.BASE}/users/web_profile_info/?username={username}"
        headers = {"User-Agent": "iphone_ua", "x-ig-app-id": "936619743392459"}
        r = self.session.get(url, headers=headers, cookies=self.cookies, timeout=15)
        if r.status_code == 404:
            return {"id": None, "error": "Usuário não encontrado"}
        try:
            data = r.json()
            return {"id": data["data"]["user"]["id"], "error": None}
        except Exception:
            return {"id": None, "error": "Resposta inválida"}

    def get_user_info(self, user_id: str):
        """Obtém informações detalhadas do usuário a partir do ID."""
        url = f"{self.BASE}/users/{user_id}/info/"
        headers = {"User-Agent": "Instagram 64.0.0.14.96"}
        r = self.session.get(url, headers=headers, cookies=self.cookies, timeout=15)
        if r.status_code == 429:
            return {"user": None, "error": "Rate limit atingido"}
        if r.status_code in (401, 403):
            return {"user": None, "error": "Não autorizado / proibido"}
        try:
            data = r.json()
            user = data.get("user")
            if not user:
                return {"user": None, "error": "Usuário não encontrado"}
            user["userID"] = user_id
            return {"user": user, "error": None}
        except Exception:
            return {"user": None, "error": "Resposta inválida"}

# ----------------------------
# Exportação
# ----------------------------

def export_json(data: dict, path: str):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def export_csv(data: dict, path: str):
    flat = flatten(data)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["Campo", "Valor"])
        for k, v in flat.items():
            w.writerow([k, str(v)])

# ----------------------------
# Main CLI
# ----------------------------

def main():
    parser = argparse.ArgumentParser(description="Instagram OSINT didático")
    parser.add_argument("--username", "-u", required=True, help="Nome de usuário alvo")
    parser.add_argument("--sessionid", "-s", help="Se ausente, usa env SESSIONID")
    parser.add_argument("--format", "-f", choices=["json", "csv", "both"], default="json", help="Formato de saída")
    parser.add_argument("--output", "-o", help="Arquivo base de saída")
    parser.add_argument("--show-email", action="store_true", help="Mostrar e-mail público completo")
    parser.add_argument("--show-phone", action="store_true", help="Mostrar telefone público completo")
    args = parser.parse_args()

    # Pega sessionid
    sid = args.sessionid or os.getenv("SESSIONID")
    if not sid:
        print("❌ Erro: sessionid ausente (use -s ou variável de ambiente SESSIONID)")
        sys.exit(2)

    s = build_session()
    client = InstagramClient(s, sid)

    # Busca ID do usuário
    res_id = client.get_user_id(args.username.lstrip("@"))
    if res_id.get("error"):
        print("❌", res_id["error"])
        sys.exit(1)
    uid = res_id["id"]

    # Busca informações detalhadas
    res_info = client.get_user_info(uid)
    if res_info.get("error"):
        print("❌", res_info["error"])
        sys.exit(1)

    data = res_info["user"]

    # mascarar dados se flags não forem usadas
    if data.get("public_email") and not args.show_email:
        data["public_email"] = mask_email(data["public_email"])
    if data.get("public_phone_number") and not args.show_phone:
        data["public_phone_number"] = mask_phone(
            data.get("public_phone_country_code", ""),
            data["public_phone_number"]
        )

    # nome base para arquivos
    base = args.output or f"instagram_{data.get('username','unknown')}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

    # exportar
    if args.format in ("json", "both"):
        export_json(data, base + ".json")
        print("✅ Exportado:", base + ".json")
    if args.format in ("csv", "both"):
        export_csv(data, base + ".csv")
        print("✅ Exportado:", base + ".csv")

if __name__ == "__main__":
    main()

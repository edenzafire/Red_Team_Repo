#!/usr/bin/env python3
"""
📌 Como usar:

Modo seguro (redige senhas/hashes):
python3 bd_lookup.py -e teste@dominio.com -k SUA_API_KEY

Modo detalhado (mostra senhas/hashes reais):
python3 bd_lookup.py -e teste@dominio.com -k SUA_API_KEY --show-passwords


Script para consulta no BreachDirectory (via RapidAPI).
Permite exibir resultados com senhas/hashes visíveis ou redigidos,
dependendo da flag usada na execução.
"""

import argparse
import requests
import json
from typing import List

# ------------------------------
# Função para chamar a API
# ------------------------------
def fetch_breachdirectory(email: str, api_key: str) -> dict:
    """Consulta a API do BreachDirectory e retorna os dados em JSON."""
    url = "https://breachdirectory.p.rapidapi.com/"
    querystring = {"func": "auto", "term": email}

    headers = {
        "X-RapidAPI-Key": api_key,
        "X-RapidAPI-Host": "breachdirectory.p.rapidapi.com"
    }

    response = requests.get(url, headers=headers, params=querystring)

    if response.status_code == 200:
        return response.json()
    else:
        print(f"⚠️ Erro {response.status_code}: {response.text}")
        return {}


# ------------------------------
# Função auxiliar para redatar campos sensíveis
# ------------------------------
def process_dict_redacted(item: dict, show_passwords: bool) -> dict:
    """
    Percorre o dicionário de resultados e redige senhas/hashes,
    exceto se show_passwords=True.
    """
    safe = {}
    for k, v in item.items():
        # Campos considerados sensíveis
        if not show_passwords and k.lower() in ("password", "hash", "hash_type"):
            if isinstance(v, str):
                safe[k] = f"[REDACTED len={len(v)}]"
            else:
                safe[k] = "[REDACTED]"
        else:
            safe[k] = v
    return safe


# ------------------------------
# Função de resumo
# ------------------------------
def summarize(results: List[dict], show_passwords: bool) -> dict:
    """Cria resumo estatístico dos resultados."""
    total = len(results)
    sources = []
    sensitive_fields_count = 0

    for item in results:
        if "sources" in item:
            if isinstance(item["sources"], list):
                sources.extend(item["sources"])
            else:
                sources.append(str(item["sources"]))

        # Contagem de quantos campos sensíveis apareceram
        for k in item.keys():
            if k.lower() in ("password", "hash", "hash_type"):
                sensitive_fields_count += 1

    return {
        "total_results": total,
        "unique_sources": sorted(set(sources)),
        # Só contabiliza se show_passwords=False, senão não faz sentido
        "sensitive_fields": sensitive_fields_count if not show_passwords else "Mostrados"
    }


# ------------------------------
# Função principal
# ------------------------------
def main() -> None:
    # ------------------------------
    # Parsing dos argumentos (CLI)
    # ------------------------------
    parser = argparse.ArgumentParser(
        description=(
            "Consulta BreachDirectory (RapidAPI) – opção de redatar ou mostrar senhas/hashes."
        )
    )
    parser.add_argument("--email", "-e", required=True, help="E-mail para consulta (auto-OSINT)")
    parser.add_argument("--key", "-k", required=True, help="Sua RapidAPI Key")
    parser.add_argument("--save", action="store_true", help="Salvar JSON em arquivo")
    parser.add_argument("--show-passwords", action="store_true", help="Exibir senhas/hashes completas")
    args = parser.parse_args()

    # ------------------------------
    # 1) Chamada à API e parsing
    # ------------------------------
    data = fetch_breachdirectory(args.email, args.key)

    # A API costuma retornar em "result" ou (menos comum) "results"
    results = data.get("result") or data.get("results") or []

    if not results:
        print(f"\n✅ Nenhum vazamento encontrado (ou não retornado) para: {args.email}")
        return

    # ------------------------------
    # 2) RESUMO amigável
    # ------------------------------
    info = summarize(results, args.show_passwords)
    print(f"\n🔎 Resultados para {args.email}")
    print(f"- Vazamentos encontrados : {info['total_results']}")
    if info["unique_sources"]:
        print(f"- Fontes únicas : {', '.join(info['unique_sources'])}")
    print(f"- Campos sensíveis: {info['sensitive_fields']}")

    # ------------------------------
    # 3) DETALHES
    # ------------------------------
    print("\n===== Detalhamento =====")
    safe_items: List[dict] = []

    for i, item in enumerate(results, start=1):
        safe_item = process_dict_redacted(item, args.show_passwords)
        safe_items.append(safe_item)
        print(f"\n--- Vazamento #{i} ---")
        print(json.dumps(safe_item, ensure_ascii=False, indent=2))

    # ------------------------------
    # 4) (Opcional) Salvar em disco
    # ------------------------------
    if args.save:
        # Nome de arquivo seguro (substitui '@' para não atrapalhar shell)
        fname = f"breachdirectory_{args.email.replace('@','_at_')}.json"
        with open(fname, "w", encoding="utf-8") as f:
            json.dump(safe_items, f, ensure_ascii=False, indent=2)
        print(f"\n💾 Arquivo salvo: {fname}")


if __name__ == "__main__":
    main()

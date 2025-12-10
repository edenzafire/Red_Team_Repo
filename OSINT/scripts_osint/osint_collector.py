#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OSINT Automation Script
Coleta informações de fontes abertas sobre e-mail, nome de usuário e nome completo
"""

import requests
import json
import re
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed


class OSINTCollector:
    def __init__(self):
        self.results = {
            "email": {},
            "username": {},
            "full_name": {}
        }

    def validate_email(self, email):
        """Valida formato de e-mail"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(pattern, email) is not None

    def validate_username(self, username):
        """Valida formato de nome de usuário"""
        # Verifica se tem caracteres alfanuméricos e alguns especiais comuns
        pattern = r'^[a-zA-Z0-9._-]{3,30}$'
        return re.match(pattern, username) is not None

    def search_email_hunter(self, email):
        """Verifica se o e-mail está em listas públicas usando Hunter.io (API pública limitada)"""
        try:
            # Esta é uma API pública que não requer chave
            domain = email.split('@')[1]
            url = f"https://api.hunter.io/v2/domain-search?domain={domain}"
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if 'data' in data and 'emails' in data['data']:
                    emails_found = []
                    for item in data['data']['emails']:
                        emails_found.append({
                            'email': item.get('value'),
                            'name': item.get('name'),
                            'position': item.get('position'),
                            'source': 'Hunter.io'
                        })
                    return emails_found
            return []
        except Exception as e:
            return [{"error": f"Hunter.io error: {str(e)}"}]

    def search_email_clearbit(self, email):
        """Busca informações de e-mail usando Clearbit (parte da funcionalidade de automação)"""
        try:
            # Simulando chamada para API Clearbit (requer chave em produção)
            # Este exemplo mostra como seria feita a integração
            return {
                "source": "Clearbit Simulation",
                "info": "Requires API key in production environment"
            }
        except Exception as e:
            return {"error": f"Clearbit error: {str(e)}"}

    def search_social_media_profiles(self, username):
        """Procura perfis em redes sociais pelo nome de usuário"""
        platforms = {
            "GitHub": f"https://github.com/{username}",
            "Twitter": f"https://twitter.com/{username}",
            "Instagram": f"https://instagram.com/{username}",
            "Reddit": f"https://reddit.com/user/{username}",
            "LinkedIn": f"https://linkedin.com/in/{username}"
        }
        
        profiles = {}
        for platform, url in platforms.items():
            try:
                response = requests.head(url, timeout=5)
                if response.status_code == 200:
                    profiles[platform] = {
                        "url": url,
                        "status": "Found"
                    }
                elif response.status_code == 404:
                    profiles[platform] = {
                        "url": url,
                        "status": "Not Found"
                    }
                else:
                    profiles[platform] = {
                        "url": url,
                        "status": f"Status code: {response.status_code}"
                    }
            except Exception as e:
                profiles[platform] = {
                    "url": url,
                    "status": f"Error: {str(e)}"
                }
                
        return profiles

    def search_name_pipl(self, full_name):
        """Busca informações baseadas no nome completo (simulação Pipl API)"""
        try:
            # Em produção, você conectaria à API real do Pipl
            # Exemplo de como seria feita a chamada:
            # url = f"https://api.pipl.com/search/v5/?key=YOUR_KEY&name={full_name}"
            return {
                "source": "Pipl API Simulation",
                "info": "Would provide people search results in production"
            }
        except Exception as e:
            return {"error": f"Pipl error: {str(e)}"}

    def search_google_dorks(self, query_terms):
        """Gera dorks do Google para pesquisa manual"""
        dorks = [
            f"intext:'{query_terms}'",
            f"inurl:{query_terms}",
            f"site:linkedin.com '{query_terms}'",
            f"site:github.com '{query_terms}'",
            f"\"{query_terms}\" filetype:pdf",
            f"\"{query_terms}\" (site:facebook.com OR site:twitter.com)"
        ]
        return dorks

    def search_breach_databases(self, email):
        """Verifica se o e-mail aparece em vazamentos conhecidos"""
        try:
            # Usando a API de HIBP (Have I Been Pwned) - requer aceite dos termos
            # Em produção, siga rigorosamente os termos de uso e rate limits
            headers = {'User-Agent': 'OSINT-Tool'}
            url = f"https://haveibeenpwned.com/api/v3/breachedaccount/{email}"
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code == 200:
                breaches = response.json()
                return {
                    "breaches_count": len(breaches),
                    "breaches": [b.get("Name") for b in breaches[:5]]  # Primeiros 5 apenas
                }
            elif response.status_code == 404:
                return {"breaches_count": 0, "message": "No breaches found"}
            else:
                return {"error": f"HIBP API error: {response.status_code}"}
        except Exception as e:
            return {"error": f"Breach check error: {str(e)}"}

    def collect_all_info(self, email=None, username=None, full_name=None):
        """Coleção principal de todas as informações"""
        print("[+] Starting OSINT collection...")
        
        # Processar e-mail se fornecido
        if email and self.validate_email(email):
            print(f"[+] Checking email: {email}")
            self.results["email"]["raw"] = email
            
            # Buscas simultâneas para melhor performance
            with ThreadPoolExecutor(max_workers=3) as executor:
                futures = {}
                futures[executor.submit(self.search_email_hunter, email)] = 'hunter'
                futures[executor.submit(self.search_breach_databases, email)] = 'hibp'
                
                for future in as_completed(futures):
                    source = futures[future]
                    try:
                        result = future.result()
                        self.results["email"][source] = result
                    except Exception as e:
                        self.results["email"][f"{source}_error"] = str(e)
        elif email:
            self.results["email"]["error"] = "Invalid email format"

        # Processar nome de usuário se fornecido
        if username and self.validate_username(username):
            print(f"[+] Checking username: {username}")
            self.results["username"]["raw"] = username
            
            # Verificar perfis em redes sociais
            self.results["username"]["social_profiles"] = self.search_social_media_profiles(username)
            
            # Dorks do Google para o username
            self.results["username"]["google_dorks"] = self.search_google_dorks(username)
        elif username:
            self.results["username"]["error"] = "Invalid username format"

        # Processar nome completo se fornecido
        if full_name:
            print(f"[+] Checking full name: {full_name}")
            self.results["full_name"]["raw"] = full_name
            self.results["full_name"]["simulated_pipl_result"] = self.search_name_pipl(full_name)
            self.results["full_name"]["google_dorks"] = self.search_google_dorks(full_name)

        return self.results

    def save_results(self, filename="osint_results.json"):
        """Salva os resultados em arquivo JSON"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)
        print(f"[+] Results saved to {filename}")

    def print_summary(self):
        """Imprime um resumo dos resultados"""
        print("\n" + "="*50)
        print("OSINT COLLECTION SUMMARY")
        print("="*50)
        
        if self.results.get("email"):
            print("\n[EMAIL INFORMATION]")
            email_data = self.results["email"]
            if "raw" in email_data:
                print(f"Email: {email_data['raw']}")
            if "hibp" in email_data:
                hibp_info = email_data["hibp"]
                if isinstance(hibp_info, dict) and "breaches_count" in hibp_info:
                    print(f"Breaches found: {hibp_info['breaches_count']}")
                    if hibp_info.get("breaches"):
                        print("Breaches:", ", ".join(hibp_info["breaches"]))
            if "hunter" in email_data:
                hunter_results = email_data["hunter"]
                if isinstance(hunter_results, list) and hunter_results:
                    print("Hunter.io found emails:")
                    for item in hunter_results[:3]:  # Limitar a 3 resultados
                        print(f"  - {item.get('email', 'N/A')}: {item.get('name', 'N/A')}")
        
        if self.results.get("username"):
            print("\n[USERNAME INFORMATION]")
            username_data = self.results["username"]
            if "raw" in username_data:
                print(f"Username: {username_data['raw']}")
            if "social_profiles" in username_data:
                profiles = username_data["social_profiles"]
                found_profiles = [p for p, info in profiles.items() if info.get("status") == "Found"]
                if found_profiles:
                    print(f"Profiles found on: {', '.join(found_profiles)}")
        
        if self.results.get("full_name"):
            print("\n[FULL NAME INFORMATION]")
            name_data = self.results["full_name"]
            if "raw" in name_data:
                print(f"Full Name: {name_data['raw']}")
        
        print("\n" + "="*50)


def main():
    collector = OSINTCollector()
    
    # Obter entradas do usuário
    email = input("Enter email (or press Enter to skip): ").strip()
    username = input("Enter username (or press Enter to skip): ").strip()
    full_name = input("Enter full name (or press Enter to skip): ").strip()
    
    if not any([email, username, full_name]):
        print("[-] No search terms provided!")
        sys.exit(1)
    
    # Coletar informações
    start_time = time.time()
    results = collector.collect_all_info(email=email, username=username, full_name=full_name)
    end_time = time.time()
    
    # Mostrar e salvar resultados
    collector.print_summary()
    collector.save_results()
    
    print(f"\n[+] Collection completed in {end_time - start_time:.2f} seconds")


if __name__ == "__main__":
    main()

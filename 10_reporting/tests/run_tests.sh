#!/usr/bin/env bash
# Phase 10 tests: the report's core promise is traceability. Test it.
set -u
P=0; F=0
ok()  { echo "PASS: $1"; P=$((P+1)); }
bad() { echo "FAIL: $1"; F=$((F+1)); }

# T1: builder runs and produces consolidated file
bash "$(dirname "$0")/../scripts/report_builder.sh" >/dev/null 2>&1 \
  && ok "report_builder executes" || bad "report_builder executes"
[[ -s "$(dirname "$0")/../report/consolidated_findings.md" ]] \
  && ok "consolidation file emitted" || bad "consolidation file emitted"

# T2: no live-looking credential values in report (doctrine: classes, not secrets)
if grep -riE '(password|secret)\s*[:=]\s*"[^"]{8,}"' \
   "$(dirname "$0")/../report/" >/dev/null 2>&1; then
  bad "no live secrets in report"
else
  ok "no live secrets in report"
fi

# T3: every finding row cites evidence pointer
if ! grep -E '^\| V-|^\| L-' "$(dirname "$0")/../report/consolidated_findings.md" \
   | grep -vE '\| (0[4-9])/evidence' >/dev/null 2>&1; then
  ok "all finding rows carry evidence pointer"
else
  bad "all finding rows carry evidence pointer"
fi

echo "---"; echo "passed=${P} failed=${F}"
(( F == 0 )) && echo "ALL TESTS PASSED" || exit 1

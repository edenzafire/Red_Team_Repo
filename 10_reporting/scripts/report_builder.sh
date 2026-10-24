#!/usr/bin/env bash
# ==============================================================================
# report_builder.sh v1 — campaign consolidation from phase artifacts.
# Doctrine: the report is generated, not written. Every finding row traces to
# a stable ID in a phase artifact. Missing artifact => row is absent, never invented.
#
# Inputs (relative to repo root):
#   04_enumeration/evidence/findings.json
#   05_vulnerability_research/evidence/triage.json
#   06_exploitation/evidence/outcomes.json
#   07_privilege_escalation/evidence/outcomes.json
#   08_post_exploitation/evidence/credentials_map.json
#   09_lateral_movement/*/attempted.list
# Output: report/consolidated_findings.md (+ ioc list + coverage matrix)
# ==============================================================================
set -uo pipefail
ROOT="${ROOT:-$(cd .. && pwd)}"
OUT="${ROOT}/10_reporting/report"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

: > "${OUT}/consolidated_findings.md"
{
  echo "# Consolidated Findings — generated ${TS}"
  echo ""
  echo "| ID | Phase | Title | Severity | ATT&CK | Evidence |"
  echo "|---|---|---|---|---|---|"

  # 04 — enumeration observations
  if [[ -f "${ROOT}/04_enumeration/evidence/findings.json" ]]; then
    jq -r '.[] | "| \(.id) | 04 | \(.title) | Info | — | 04/evidence/findings.json |"' \
      "${ROOT}/04_enumeration/evidence/findings.json" 2>/dev/null
  fi

  # 05 — vulnerability triage (severity carried from triage)
  if [[ -f "${ROOT}/05_vulnerability_research/evidence/triage.json" ]]; then
    jq -r '.[] | "| \(.id) | 05 | \(.title) | \(.severity // "TBD") | \(.attck // "—") | 05/evidence/triage.json |"' \
      "${ROOT}/05_vulnerability_research/evidence/triage.json" 2>/dev/null
  fi

  # 06 — exploitation outcomes (only executed vectors become findings)
  if [[ -f "${ROOT}/06_exploitation/evidence/outcomes.json" ]]; then
    jq -r 'select(.outcome == "exploited") |
      "| \(.vector_id) | 06 | \(.title // "Exploit executed") | High | \(.attck // "—") | 06/evidence/outcomes.json |"' \
      "${ROOT}/06_exploitation/evidence/outcomes.json" 2>/dev/null
  fi

  # 07 — privilege escalation outcomes
  if [[ -f "${ROOT}/07_privilege_escalation/evidence/outcomes.json" ]]; then
    jq -r 'select(.outcome == "escalated") |
      "| \(.vector_id) | 07 | \(.title // "Privilege escalated") | High | \(.attck // "—") | 07/evidence/outcomes.json |"' \
      "${ROOT}/07_privilege_escalation/evidence/outcomes.json" 2>/dev/null
  fi
} >> "${OUT}/consolidated_findings.md"

# ATT&CK coverage matrix — techniques touched, generated from all artifacts
{
  echo ""
  echo "## ATT&CK Coverage"
  echo ""
  echo "| Tactic | Technique | Phase | Status |"
  echo "|---|---|---|---|"
  for f in "${ROOT}"/0{4,5,6,7,8,9}_*/evidence/*.json; do
    [[ -f "$f" ]] || continue
    jq -r '.. | objects | select(has("attck")) | "\(.tactic // "—") | \(.attck) | \(.phase // "?") | observed"' "$f" 2>/dev/null
  done | sort -u >> "${OUT}/consolidated_findings.md"
} 2>/dev/null

# IOC list + contact log (blue-team debrief inputs)
{
  echo ""
  echo "## Blue-Team Inputs"
  echo ""
  echo "### East-west contact log (from 09 ledger)"
  if ls "${ROOT}"/09_lateral_movement/*/attempted.list >/dev/null 2>&1; then
    cat "${ROOT}"/09_lateral_movement/*/attempted.list | sort -u | sed 's/^/- /'
  else
    echo "- (none recorded)"
  fi
  echo ""
  echo "### Credential material inventory (from 08 map, classes only — never values)"
  if [[ -f "${ROOT}/08_post_exploitation/evidence/credentials_map.json" ]]; then
    jq -r '.material[]? | "- \(.id // .class // "unknown") (\(.class // "n/a")) — source: \(.source // "n/a")"' \
      "${ROOT}/08_post_exploitation/evidence/credentials_map.json" 2>/dev/null
  fi
} >> "${OUT}/consolidated_findings.md"

echo "consolidation written: ${OUT}/consolidated_findings.md"
echo "rule: nothing invented, everything traced. Review and curate before delivery."

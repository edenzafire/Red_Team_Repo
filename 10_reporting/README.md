# 10 — Reporting & Campaign Consolidation

> **Engagement:** Authorized lab engagement — closure of phases 01–09.
> **Phase position:** 10 of 10 — receives the full campaign, produces the deliverables.
> **Frameworks honored:** MITRE ATT&CK (attacker view), Cyber Kill Chain (narrative view),
> PTES (report structure), NIST SP 800-115 (finding format), CVSS v3.1 (severity).

---

## 1. Objective

Transform nine phases of executed, evidenced work into the deliverable that
outlives the engagement: a report that a defender can act on and a reviewer
can audit — without ever re-running anything.

**Doctrine: the report is generated, not written.** Every claim traces to an
artifact (`findings.json`, `outcome.json`, `execution_proof.txt`) via stable
IDs (`V-05-*`, `L-09-*`). The `report_builder.sh` assembles the campaign
consolidation mechanically; human authorship is reserved for analysis.

## 2. The four deliverables

| # | Deliverable | Audience | Source |
|---|---|---|---|
| D1 | Executive Summary (1 page, risk language) | Board / management | Generated + curated |
| D2 | Technical Report (structure per PTES/NIST) | Engineers, reviewers | All phases |
| D3 | Remediation Plan (priority matrix: impact × effort) | Engineering leads | Findings ledger |
| D4 | Blue-Team Debrief (detection opportunities, IOC list, contact log) | Defenders | attempt ledger, artifacts |

## 3. Structure of the technical report (D2)

1. Scope & Authorization — targets, rules, dates
2. Methodology — phases 01–10, framework mapping
3. Campaign Narrative — the kill-chain story, one continuous arc
4. Findings — each finding: ID, title, severity (CVSS), ATT&CK mapping,
   evidence pointer, affected asset, reproduction reference
5. Attack Path Reconstruction — the full chain 01→09 as a single diagram
6. Remediation Plan — prioritized, owner-ready
7. Appendices — IOC list, tool inventory, artifacts index

## 4. Repo Layout

10_reporting/ ├── README.md ├── scripts/report_builder.sh # consolidates findings from 04–09 ├── templates/finding.tmpl.md # NIST-style finding template ├── report/ │ ├── 10_executive_summary.md │ ├── 10_technical_report.md │ └── 10_blue_team_debrief.md ├── evidence/raw/ ├── tests/run_tests.sh ├── USAGE.md └── .gitignore





# 09 — Lateral Movement

> **Engagement:** Authorized lab engagement — continuation of phases 04–08.
> **Phase position:** 09 of N — receives Post-Exploitation (08), feeds Impact & Final Reporting (10).
> **ATT&CK mapping:** TA0008 — T1021.004 (SSH), T1021.006 (WinRM), T1021.001 (RDP, conditional),
> T1570 (lateral tool transfer via pivot channel).

---

## 1. Objective

Execute movement to additional hosts **against the phase-08 contract** — every hop
validated against `credentials_map.json` destinations[] before a single packet is
sent. The defining property of this phase is that it is **the most gated phase of
the pipeline**: movement is where engagements produce the loudest east-west noise,
so every control that was documentation in earlier phases becomes an exit code here.

**Invariants (all mechanically enforced):**

1. **Map gate** — destination absent from `destinations[]` ⇒ exit 2, refused.
   Verified access paths (`match:"local_key=..."` from 08) are the sanctioned hops.
2. **One attempt per destination** — retry against a mapped destination requires
   a new invocation with `--justification FILE`. Retry storms are detection gifts.
3. **BatchMode/interactive-free** — no password prompts, ever. A credential that
   needs interactive typing was never validated and will not be here.
4. **Pivot channel discipline** — all east-west traffic rides the established
   Meterpreter route/SOCKS path; no direct new connections from the operator
   to internal hosts.

## 2. Methodology: hop lifecycle

| Step | Action | Enforcement |
|---|---|---|
| 1. Select | Pick destination from map (prefer `confidence: likely` + `match: local_key`) | Operator, from map only |
| 2. Validate | Plugin checks map + reachability plan + material presence | exit 2 if unmapped |
| 3. Connect | Single attempt, bounded timeout, non-interactive | exit 4 on failure |
| 4. Record | Proof: destination, method, identity captured on remote side | evidence-grade |
| 5. Expand | New host becomes new phase-04-style enum input (loop back to collect → correlate) | pipeline iteration |

**The pipeline is a cycle, not a line:** every new host re-enters the loop at
enumeration (04-style checks against the new context), which is the real-world
shape of internal campaigns — and demonstrating that loop is the portfolio's
crowning argument.

## 3. Plugins

| Plugin | OS | Technique | Gate chain |
|---|---|---|---|
| `v0506_ssh_pivot.sh` | Linux | T1021.004 | map membership → key readable → BatchMode attempt |
| `v0507_winrm_lateral.ps1` | Windows | T1021.006 | map membership → creds from 08 store → NLA check → single attempt |

## 4. Key Outcomes (summary)

| ID | Outcome | ATT&CK |
|----|---------|--------|
| L-09-01 | Second host reached via verified SSH key path | T1021.004 |
| L-09-02 | WinRM session established with phase-08 material | T1021.006 |
| L-09-03 | Pivot network path documented (route/SOCKS, no direct connections) | T1570 |
| L-09-04 | Pipeline cycle demonstrated (new host → re-enumeration) | — |

Full narrative: [`report/09_lateral_movement.md`](report/09_lateral_movement.md).

## 5. Repo Layout

09_lateral_movement/ ├── README.md ├── scripts/vectors/ │ ├── v0506_ssh_pivot.sh │ └── v0507_winrm_lateral.ps1 ├── evidence/raw/ ├── fixtures/map_without_dest.json # refusal-test fixture ├── tests/run_tests.sh # map gate + retry-ceiling tests ├── report/09_lateral_movement.md ├── USAGE.md └── .gitignore





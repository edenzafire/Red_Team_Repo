# 07 — Privilege Escalation

> **Engagement:** Authorized lab engagement — continuation of phases 04–06.
> **Phase position:** 07 of N — receives Exploitation (06), feeds Credential Access & Lateral Movement (08).
> **ATT&CK mapping:** T1068 (Linux kernel, contingency), T1134 (Windows token manipulation), T1548.002 (AIE execution completion).

---

## 1. Objective

Expand and consolidate privilege from the execution context obtained in phase 06,
through vectors that were **quarantined or invisible before**:

| Vector | Context dependency | Why here, not in 06 |
|---|---|---|
| V-05-02 (DirtyPipe) | Requires operator go/no-go AFTER primary vector resolved | Crash-risk doctrine: never runs while an unconsolidated foothold exists |
| V-05-03-AIE completion (Win) | Requires AIE confirmed + MSI staged | Execution completes the staged plan from 06's plugin |
| V-05-priv (token abuse, Win) | Requires token privilege triage from 04 + new context | SeBackup/SeImpersonate exploitation is consolidation, not first entry |

**Three invariants (inherited from phase 06 doctrine):**

1. Runner + plugin contract unchanged — same `exploit_runner.sh`/`.ps1`, new plugins only.
2. Go/no-go for crash-risk vectors is **human, explicit, and logged** (`--confirm-risk`).
3. Every escalation is evidence-grade: proof artifacts, not claims.

## 2. Methodology

Same 4-stage playbook (ingest → validate → execute → evidence), two new plugin classes:

### Linux: `v0502_dirtypipe.sh`
- **Validation:** exact minor version vs CVE-2022-0847 fixed range (5.15.25 / 5.16.11
  and below are safe — abort if matched). Offline, silent.
- **Go/no-go gate:** runner refuses execution without `--confirm-risk` AND an
  operator-supplied `--recovery-plan FILE`. The plan is parsed for the three
  mandatory sections (session recovery, crash handling, evidence preservation) —
  a plan without all three is rejected. This is the "quarantine" made mechanical.
- **Execution:** overwrites an SUID-root binary's page cache via splice and spawns
  root shell bounded-exec, same proof-collection pattern as V-05-01.

### Windows: `v0503_token_abuse.ps1`
- **Validation:** `whoami /priv` triage — privilege must be **Enabled** (not merely
  listed; the classic trap documented in phase 05).
- **Execution branches (context-determined, non-interactive):**
  - `SeBackupPrivilege` → `robocopy /b` SAM + SYSTEM + SECURITY to evidence dir
    (proof: file hashes; dump content redacted at capture per doctrine).
  - `SeImpersonatePrivilege` → detection of service context (port 135 callback /
    named pipe check logged) and staged potato plan — same execution-plan-first
    honesty as the AIE plugin: the exploit binary (SweetPotato/PrintSpoofer class)
    is operator-staged, plugin validates context + runs + captures proof.
- **Fallback logic is explicit, never implicit:** each branch logs why it was taken.

## 3. Key Outcomes (summary)

| ID | Outcome | ATT&CK | Feeds |
|----|---------|--------|-------|
| P-07-01 | Root consolidation confirmed (post-06 re-verification) | T1548.003 | 08 — Credential Access |
| P-07-02 | SAM/SYSTEM/SECURITY recovered (Win, if SeBackup) | T1003.002 | 08 — Offline cracking |
| P-07-03 | Potato-class SYSTEM escalation staged/executed (Win, if SeImpersonate) | T1134.001 | 08 — Lateral prep |

Full narrative: [`report/07_privilege_escalation.md`](report/07_privilege_escalation.md).

## 4. Repo Layout

07_privilege_escalation/ ├── README.md ├── scripts/vectors/ │ ├── v0502_dirtypipe.sh # Contingência Linux (controlada por --confirm-risk) │ └── v0503_token_abuse.ps1 # Branches SeBackup/SeImpersonate do Windows ├── evidence/raw/ ├── report/07_privilege_





**Note:** runners are NOT duplicated here — phase 06's runners are the canonical
executors (single audited frame). This phase contributes plugins only, and its
USAGE documents runner reuse with the `--findings` flag pointing to this phase's
evidence.

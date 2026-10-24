
# Phase 07 — Privilege Escalation

**Classification:** TLP:AMBER — Authorized engagement
**Target:** LAB-01 (Linux) + Windows track — continuation of phases 04–06
**Author:** <your-name>
**Date:** 2026-10-XX
**Phase inputs:** Execution context from 06 (X-06-XX); quarantined V-05-02; token triage from 04
**Phase outputs:** Consolidated privilege (P-07-XX) → Phase 08 (Credential Access & Lateral Movement)

---

## 1. Executive Summary

This phase converts the phase-06 execution context into consolidated privilege
and unblocks the vectors that doctrine had quarantined. The defining property
of the phase is that its most dangerous vector (V-05-02, DirtyPipe) is
gated **mechanically, not by convention**: the plugin refuses execution
without an explicit operator confirmation flag AND a recovery plan containing
three mandatory sections. The quarantine from phase 05 is enforced by code.

On the Windows track, privilege consolidation follows the token triage from
phase 04 with the `Enabled`-state validation doctrine: SeBackup branches to
registry hive recovery with hash-only proof; SeImpersonate branches to
potato-class escalation with operator-staged binaries and service-context
validation.

## 2. Design Decisions Worth Defending

**Crash-risk gate as code, not culture.** Phases 05 and 06 *said* "kernel
exploits need go/no-go." Phase 07 makes the say impossible to bypass: missing
flag, missing plan, or plan missing any mandatory section ⇒ exit 3 before
any execution. Doctrines that live in documentation are suggestions; doctrines
that live in exit codes are controls.

**`Enabled` vs `listed` privilege validation.** `whoami /priv` lists disabled
privileges too. Every token-privilege vector in this phase validates the
Enabled state first — the single most common false-positive in Windows
privilege escalation walkthroughs.

**Hash-only hive proof.** SAM/SYSTEM/SECURITY recovery records SHA-256
fingerprints in the proof artifact; hive content moves directly into the
gitignored evidence store (phase 08 input). The no-plaintext-credential
invariant holds across the entire pipeline, even in the artifacts that most
tempt a shortcut.

**Branch decisions are logged with reasons.** The token plugin emits *why*
it took sebackup vs seimpersonate vs none — because the alternative
(silent branching) makes post-incident review guess at operator logic.

## 3. Execution Record

| Stage | Linux (V-05-02) | Windows (V-05-PRIV) |
|---|---|---|
| Ingest | findings cross-check (phase 07 evidence) | same |
| Validation | exact minor vs patched range (5.15.25/5.16.11) | Enabled-priv triage |
| Go/no-go | flag + 3-section recovery plan (mechanical) | service-context check |
| Execution | operator-staged PoC, bounded, 1 attempt | branch: hive save / potato staged |
| Evidence | euid=0 proof, kernel version | hive SHA-256 / SYSTEM whoami |

## 4. Findings

### P-07-01 — Root consolidation confirmed (Linux)
Post-escalation re-verification of context from phase 06 (euid=0, shadow
readable, root key material inventoried). Consolidation matters because a
root shell that isn't *verified as stable* is not a root position.

### P-07-02 — Registry hives recovered (Windows, SeBackup branch)
SAM/SYSTEM/SECURITY saved with backup semantics; fingerprints logged.
Feeds phase 08 offline cracking (operator-side, hashcat + format awareness).

### P-07-03 — SYSTEM escalation staged/executed (Windows, SeImpersonate branch)
Potato-class vector staged by operator per portability doctrine; plugin
validated service context, executed, captured SYSTEM proof.

## 5. Negative Results

- V-05-02 remains unexecuted in the reference run: with V-05-01 confirmed
  and consolidated, the crash-risk vector is *by doctrine* never consumed —
  the gate exists precisely so this vector stays a case study, not an event.
- No persistence mechanisms installed (separate engagement decision).
- No privilege branch executed without logged reason.

## 6. Next-Phase Handoff (Phase 08 — Credential Access & Lateral Movement)

| Input | Planned action |
|---|---|
| P-07-02 hives | Offline cracking; NTLM extraction; reuse map |
| P-07-03 SYSTEM context | DPAPI / credential vault access; WinRM lateral |
| Root context (P-07-01) | svc-deploy key-class map expansion (V-05-04) |
| Cred reuse (V-05-03) | One careful validation per service, via pivot |

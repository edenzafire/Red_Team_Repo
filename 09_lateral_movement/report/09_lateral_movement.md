
# Phase 09 — Lateral Movement

**Classification:** TLP:AMBER — Authorized engagement
**Target:** LAB-01 → internal segment (10.0.2.0/24) — continuation of phases 04–08
**Author:** <your-name>
**Date:** 2026-10-XX
**Phase inputs:** credentials_map.json (C-08-XX), verified access paths, pivot channel
**Phase outputs:** Additional host control (L-09-XX), pipeline cycle demonstrated → Phase 10 (Impact & Final Report)

---

## 1. Executive Summary

Lateral movement was executed as the most gated phase of the engagement: every
hop validated against the phase-08 `credentials_map.json` before any packet
was generated, one attempt per destination, no interactive credential use,
and all east-west traffic riding the established pivot channel. The primary
hop (L-09-01) used a **verified access path** — a destination whose
`authorized_keys` fingerprint had been cross-referenced against a locally-held
private key in phase 08 — meaning the movement was a confirmed path being
*consumed*, not a hypothesis being *tested*.

The phase's structural argument: the anti-spray doctrine that began as a
phrase in phase 05, became a scoring constraint in the triage, an exit code
in the runners, and a file format in phase 08, reaches its final form here —
**a refusal that is tested** (`tests/run_tests.sh` T1–T3: unmapped destination,
missing map, retry without justification).

## 2. Design Decisions Worth Defending

**Map gate re-checked at execution, not only at validation.** The plugin
re-runs the map check inside `execute` — a validation gate that is not
re-verified at the moment of action is advisory. Defense in depth applies to
our own automation as much as to the target.

**The attempt ledger.** `attempted.list` records every destination contacted.
It enforces the retry ceiling (second attempt requires a justification
artifact) and doubles as an honest east-west contact log for the blue-team
debrief — the defender's question "what did they touch?" has a direct answer.

**No interactive credentials, structurally.** BatchMode with
`NumberOfPasswordPrompts=0` (Linux) and store-sourced `PSCredential` objects
(Windows) mean the tooling *cannot* fall back to typed credentials. A
credential that would require typing was never validated — and this phase
refuses to become its validation mechanism.

**Movement as cycle.** Each new host re-enters the pipeline at enumeration:
collect → correlate → update map → next hop. The engagement is presented as
what internal campaigns actually are — a loop — rather than a linear exploit
checklist. This is the portfolio's closing argument for why phase separation
matters: each loop iteration reuses the *same audited frames*.

## 3. Execution Record

| Hop | Method | Map basis | Result |
|---|---|---|---|
| `10.0.2.9` (svc-deploy) | SSH key, BatchMode | `match:"local_key=..."` (verified path, phase-08) | L-09-01: identity captured (`id`, hostname, interfaces) |
| `10.0.2.20` (app-service) | WinRM, Negotiate | RDP MRU entry + cred from 08 store | L-09-02: session established |
| Pivot path | Meterpreter route + SOCKS | — | L-09-03: no direct operator→internal connections |

## 4. Findings

- **L-09-01/L-09-02:** additional hosts controlled under the contract; remote
  identity artifacts (`id`, `whoami`, host, interfaces) captured as proof.
- **L-09-03:** pivot topology documented — the network path *is* part of the
  evidence, not an implementation detail.
- **L-09-04:** the cycle demonstrated — hop 1's host produced new
  enumeration data feeding the map before hop 2.

## 5. Negative Results

- Unmapped hosts observed in ARP data were **deliberately not contacted** —
  the map-gate doctrine means discovery without correlation produces
  documentation, not connections. Recorded for the defender as proof the
  operator could have gone wider and chose not to.
- No credential spraying occurred (structurally impossible given the gates).
- No persistence on lateral targets (separate engagement decision).

## 6. Handoff (10 — Impact & Final Reporting)

| Input | Destination |
|---|---|
| Full campaign chain (01→09) | Executive summary with kill-chain narrative |
| Every phase's findings ledger | Consolidated remediation table, priority-ordered |
| Attempted.list + state-change inventories | Blue-team debrief package |
| Detection opportunities observed | Defensive recommendations (the reciprocal gift) |


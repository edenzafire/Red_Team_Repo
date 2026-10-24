# Blue-Team Debrief — Defensive Counterpart

**Classification:** TLP:AMBER — for the defense, by the offense.

---

## Purpose

The offense's honest ledger. What we did, when, and — most importantly —
**what you could have seen**. Every item below is a signal that existed in
your telemetry.

## 1. Detection Opportunities (the gift)

| # | Signal | Where it lived | Detection idea |
|---|---|---|---|
| D-01 | Reverse shell egress | Network flow / EDR | Unusual parent-child (browser→shell), beacon timing |
| D-02 | Enumeration bursts | Auth logs, process telemetry | Rapid sequential `sudo -l`/`net`/`id` in one session |
| D-03 | Kernel exploit artifact | Auditd, syslog | Anomalous `pkexec`/kernel paths, crash signatures |
| D-04 | Credential access | Sysmon/auditd | Access to `SAM`/`lsass`/`authorized_keys` reads by unexpected processes |
| D-05 | East-west hops | Internal flow logs, WinRM/SSH logs | New source-destination service pairs; first-time key usage |
| D-06 | Our attempt ledger | (handed over) | Direct contact list — reconcile against your logs for blind spots |

## 2. IOC List

{{PATHS, TIMING PATTERNS, USER AGENTS, NAMED PIPES — no live credential values}}

## 3. Contact Log (from `attempted.list`)

{{GENERATED — every east-west destination contacted, verbatim}}

## 4. Questions We Hope You Ask

1. "Why didn't D-{{X}} fire?" — usually a log-source gap, not a rule gap.
2. "Which finding recurs next quarter if we fix nothing?" — all three.
3. "What would have broken the chain cheapest?" — see remediation P0.

## 5. Cleanup Confirmation

Every state change was reverted per the cleanup manifest (Appendix D of the
technical report). Keys identified in the phase-08 map should nonetheless be
**rotated on your side** — treating exposed material as compromised is the
only sound posture after credential access.

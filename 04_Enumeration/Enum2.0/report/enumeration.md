
# Phase 04 — Post-Exploitation Enumeration

**Classification:** TLP:AMBER — Authorized engagement
**Target:** LAB-01 (`10.10.XX.14`, Linux host, initial access via phishing → reverse Meterpreter)
**Author:** Eden Zafire
**Date:** 2026-10-XX
**Phase inputs:** Initial Access (03) — T1566.001 / T1059
**Phase outputs:** PrivEsc candidates, credential material, internal network map → Phases 05–06

---

## 1. Executive Summary

Following the delivery of a weaponized payload via spearphishing attachment (T1566.001), code execution
was established in the context of user `devuser` on the target host. A single automated enumeration
pass was executed using a purpose-built script (`scripts/enum_linux.sh`), designed to extract maximal
intelligence with minimal footprint and zero third-party tooling on the endpoint.

Enumeration identified **four actionable findings**, of which **three directly enable privilege
escalation or lateral movement**:

- A misconfigured `sudo` rule granting passwordless `find` execution (trivial root);
- Plaintext production database credentials stored in a world-readable application config;
- A reusable SSH private key belonging to the `svc-deploy` account, with key-based auth to at least one internal host;
- Internal network reachability to a second host exposing SMB, previously unknown from the external attack surface.

The foothold is therefore not an end state: within one automated pass, this session escalates
to root *and* pivots. Both paths are documented below and scheduled for execution in phases 05–06.

## 2. Scope and Constraints

| Item | Detail |
|---|---|
| Session context | `devuser` (uid 1000), not in `sudo` group |
| Dwell constraint | Single automated pass; target host monitored for log volume |
| Tooling | On-host natives only; one 6 KB bash script uploaded to `/tmp`, removed post-run |
| Exfiltration | Results downloaded over existing Meterpreter channel; no new connections |

## 3. Findings

### F-04-01 — Passwordless sudo on `find` allows trivial root escalation

**Severity:** High · **ATT&CK:** T1548.003 (Sudo and Sudo Caching) · **Feeds:** Phase 05

**Evidence** (`evidence/raw/current_user.txt`, abridged):

User devuser may run the following commands on lab-01: (root) NOPASSWD: /usr/bin/find

**Analysis.** `find` supports `-exec` with arbitrary command execution. The rule specifies the
absolute binary path and does not constrain arguments, so the classic GTFOBins pattern applies:

```bash
sudo find / -exec /bin/sh \; -quit

```
The rule appears to have been added for a cleanup script that was later removed — the sudoers entry outlived its purpose. This is a common lifecycle failure: permissions are granted for a task, and never revoked when the task dies.

Recommended remediation: remove the sudoers entry; where delegated execution is genuinely required, wrap the operation in a purpose-built, argument-validating helper rather than delegating a general-purpose binary.




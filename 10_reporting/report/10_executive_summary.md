# Executive Summary — Authorized Engagement Report

**Classification:** TLP:AMBER | **Engagement:** LAB-01 full-chain assessment
**Dates:** 2026-10 | **Prepared by:** <your-name> | **Version:** 1.0

---

## For the Reader

This engagement simulated a realistic external adversary across ten controlled
phases — from open-source intelligence to lateral movement — against
**LAB-01**, under explicit written authorization. This summary is written for
decision-makers; the technical detail lives in the full report.

## What Happened (plain language)

An attacker with **no insider knowledge** was able to:

1. **Map the organization** from public sources and passive reconnaissance.
2. **Gain the first foothold** through a realistic phishing delivery.
3. **Learn the environment** from inside, faster than it can be defended.
4. **Identify and exploit** a known, patchable weakness.
5. **Become administrator** on the first host.
6. **Harvest credentials** — the keys to the kingdom — with built-in tools.
7. **Move to additional hosts** using those credentials, following paths the
   environment itself validated.

## The Three Findings That Matter Most

| # | Finding | Why it matters | The fix |
|---|---|---|---|
| 1 | {{F-01: initial access vector}} | The entry point invalidates perimeter spending | {{remediation}} |
| 2 | {{F-02: credential exposure class}} | One compromised host became many | Credential tiering, LAPS/gMSA, monitoring |
| 3 | {{F-03: lateral path}} | Verified trust paths exist without segmentation control | Segment, monitor east-west, rotate keys |

## Risk Position

**Current state:** a single phishing email can lead to multi-host compromise
within {{TIMEFRAME}}. The chain was not exotic — every step used known
techniques mapped to public frameworks, which is precisely the point:
**determined generalists succeed against the current control set.**

## What We Recommend First

1. {{IMMEDIATE — days}}
2. {{SHORT TERM — weeks}}
3. {{STRATEGIC — quarters}}

## A Note on the Positive

Defensive telemetry captured {{N}} of the campaign's steps in retrospect; the
debrief document lists exactly which signals existed and how to surface them
in real time. This engagement is as much a gift to the defense as a test of it.

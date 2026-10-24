# Recovery Plan — V-05-02 (crash-risk vector)

## session.recovery
If host becomes unreachable: relisten via msfconsole multi/handler on
port 4444; phishing payload re-delivery is DOCTRINE-APPROVED for lab-01.

## crash.handling
On kernel panic: snapshot revert via hypervisor (VBoxManage snapshot restore
lab-01-clean); note time-of-crash in engagement log before reverting.

## evidence.preservation
All phase-07 evidence is downloaded to operator evidence/raw BEFORE exploit
execution; a crash cannot destroy already-exfiltrated artifacts.

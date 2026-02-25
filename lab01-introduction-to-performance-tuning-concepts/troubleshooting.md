# 🛠️ Troubleshooting Guide — Lab 01: Introduction to Performance Tuning Concepts

> This file captures common issues that can occur while running baseline checks, installing monitoring tools, and executing performance test scripts.

---

## 1) ❌ Permission Denied / Access Errors (Monitoring Commands)
### ✅ Problem
Commands fail with errors like:
- `Permission denied`
- `Operation not permitted`
- `Not allowed to access ...`

### 🔎 Likely Cause
Some monitoring operations require elevated privileges:
- `iotop` may need root to observe I/O by process.
- Reading certain system info or managing services can require sudo.
- Writing logs into restricted directories can fail.

### ✅ Fix
- Use sudo where appropriate:
  - `sudo iotop`
  - `sudo systemctl enable sysstat`
- Confirm file permissions:
  - `ls -la`
- Avoid writing logs to restricted locations; use a user directory like:
  - `~/performance_lab/`

---

## 2) ❌ Missing Tools (htop / iostat / iftop / stress-ng)
### ✅ Problem
You see errors like:
- `command not found: htop`
- `iostat not available`
- `stress-ng: command not found`

### 🔎 Likely Cause
Packages are not installed by default on minimal server images.

### ✅ Fix
Install required packages using a distro-appropriate command (this lab used an auto-fallback):
- RHEL/CentOS:
  - `sudo yum install -y stress-ng htop iotop nethogs sysstat iftop`
- Debian/Ubuntu:
  - `sudo apt-get install -y stress-ng htop iotop nethogs sysstat iftop`

If `iostat` is missing, it is part of `sysstat`:
- `sudo yum install -y sysstat`

---

## 3) ❌ sysstat Service Enable Fails / Not Found
### ✅ Problem
This command fails:
- `sudo systemctl enable sysstat`

### 🔎 Likely Cause
Service names and sysstat configuration differ slightly between distributions.

### ✅ Fix
- Confirm package installed:
  - `rpm -q sysstat` (RHEL/CentOS)
  - `dpkg -l | grep sysstat` (Debian/Ubuntu)
- Check available unit files:
  - `systemctl list-unit-files | grep -i sysstat`
- If service is different, enable the correct unit found in output.

If your environment doesn’t use a persistent sysstat service, you can still use `iostat` directly once installed.

---

## 4) ⚠️ High System Load During Tests
### ✅ Problem
System becomes slow/unresponsive during stress or bottleneck simulation.

### 🔎 Likely Cause
Bottleneck scripts intentionally consume resources:
- CPU busy loops
- memory pressure via `stress-ng`
- heavy disk writes via `dd`

### ✅ Fix
Stop the test:
- Press `Ctrl + C` in the terminal running the script  
If background jobs remain:
- Kill stress-ng:
  - `killall stress-ng`
- List background jobs:
  - `jobs -l`
- Kill jobs:
  - `kill <PID>`

Monitor recovery:
- `uptime`
- `top` or `htop`
- `free -h`

---

## 5) ❌ Disk Space Issues / Temp Files Accumulate
### ✅ Problem
Disk fills up or you see “No space left on device” when running disk tests.

### 🔎 Likely Cause
Disk bottleneck scripts repeatedly create files in `/tmp`. If scripts are interrupted improperly, temporary files might remain.

### ✅ Fix
Clean up leftover files:
- `rm -f /tmp/test_file_* /tmp/disktest_* /tmp/io_test_* /tmp/mem_test`

Verify space:
- `df -h`

---

## 6) ❌ bc Not Installed (Scripts Fail)
### ✅ Problem
Scripts that rely on `bc` fail with:
- `bc: command not found`

### 🔎 Likely Cause
`bc` is not installed on some minimal OS images.

### ✅ Fix
Install `bc`:
- RHEL/CentOS:
  - `sudo yum install -y bc`
- Debian/Ubuntu:
  - `sudo apt-get install -y bc`

Re-run the scripts after installation.

---

## 7) ❌ ping Localhost Fails in Responsiveness Test
### ✅ Problem
The network test prints:
- `Network test failed`

### 🔎 Likely Cause
Possible causes include:
- ICMP blocked by policy/firewall in the environment
- ping binary permission restrictions (rare but possible)
- transient system issues

### ✅ Fix
Try:
- `ping -c 3 127.0.0.1`
- `ping -c 3 localhost`

Check firewall state (RHEL-based):
- `sudo firewall-cmd --state`
- `sudo firewall-cmd --list-all`

If ICMP is blocked by environment policy, document it as an environment limitation.

---

## 8) ✅ Script Execution Errors (chmod / line endings)
### ✅ Problem
Script fails with:
- `Permission denied`
- `bad interpreter: /bin/bash^M`

### 🔎 Likely Cause
- Script is not executable (`chmod +x` missing)
- Script has Windows line endings (CRLF)

### ✅ Fix
Make it executable:
- `chmod +x scriptname.sh`

Fix line endings:
- `sed -i 's/\r$//' scriptname.sh`

Then run again:
- `./scriptname.sh`

---

## ✅ Quick Verification Checklist
Use these to confirm the lab is complete:

- Scripts created:
  - `ls -la *.sh`
- Logs/reports created:
  - `ls -la *.log *.txt`
- System stable:
  - `uptime && free -h && df -h`

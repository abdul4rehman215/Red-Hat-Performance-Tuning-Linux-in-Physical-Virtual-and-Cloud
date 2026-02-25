# 🛠 Troubleshooting Guide — Lab 12: Network Utilization Tuning

> This guide lists common issues encountered when tuning Linux networking with **sysctl**, **ethtool**, and **iperf3**, along with fixes and prevention tips.

---

## Issue 1: `ifconfig` command not found
### ✅ Symptoms
```bash
ifconfig -a
# bash: ifconfig: command not found
````

### 🔍 Cause

Modern Ubuntu installs do not include `net-tools` by default (deprecated tools).

### ✅ Fix

```bash
sudo apt-get update -y
sudo apt-get install -y net-tools
```

### 🛡 Prevention

Use modern tools by default:

* `ip addr`, `ip link`, `ip -s link`
  Keep `net-tools` only when lab steps require it.

---

## Issue 2: Cannot modify sysctl parameters (permission denied / read-only)

### ✅ Symptoms

* `sysctl -w ...` fails
* Applying sysctl file fails
* Some parameters silently do not change

### 🔍 Cause

* Missing sudo privileges
* Restricted cloud/container environment
* Kernel capability limitations

### ✅ Fix

Verify sudo:

```bash
sudo -v
```

Apply sysctl config with root:

```bash
sudo sysctl -p /etc/sysctl.d/99-network-performance.conf
```

Confirm parameter is writable:

```bash
sysctl -a | grep net.ipv4.tcp_rmem
```

### 🛡 Prevention

Check environment type:

```bash
uname -r
cat /proc/version
```

If tuning inside a container, expect some sysctls to be locked.

---

## Issue 3: `iperf3` connection fails (cannot connect to server)

### ✅ Symptoms

```text
Connecting to host X.X.X.X, port 5001
iperf3: error - unable to connect to server
```

### 🔍 Cause

* iperf3 server not running
* wrong IP/port
* security group/firewall blocking

### ✅ Fix

On server:

```bash
iperf3 -s -p 5001
```

On client:

```bash
iperf3 -c 172.31.20.10 -p 5001 -t 10
```

Verify route:

```bash
ip route
ping -c 3 172.31.20.10
```

### 🛡 Prevention

Start server first and keep it running during tests. Validate reachability before benchmarking.

---

## Issue 4: `ethtool` settings return “Operation not supported”

### ✅ Symptoms

* `sudo ethtool -K ...` fails
* `sudo ethtool -C ...` fails
* output shows `[fixed]`

### 🔍 Cause

Virtual/cloud NICs often limit feature control. Some settings are not supported by the driver/hypervisor.

### ✅ Fix

Check what is fixed:

```bash
ethtool -k ens5 | grep fixed
```

Use scripts that gracefully handle unsupported features:

* run with `2>/dev/null`
* fall back to “not supported” messages
  (Implemented in this lab’s optimization scripts.)

### 🛡 Prevention

Confirm interface type and driver:

```bash
ip link show ens5
ethtool -i ens5
lspci | grep -i network
```

---

## Issue 5: Ring buffers do not change after running `ethtool -G`

### ✅ Symptoms

* `ethtool -g ens5` still shows old RX/TX values

### 🔍 Cause

* requested values exceed max
* driver ignores changes
* operation not supported

### ✅ Fix

Check max supported values first:

```bash
ethtool -g ens5
```

Apply only max supported values:

```bash
sudo ethtool -G ens5 rx 4096
sudo ethtool -G ens5 tx 4096
```

### 🛡 Prevention

Automate with detection (used in `optimize_ring_buffers.sh`).

---

## Issue 6: BBR not available or cannot be enabled

### ✅ Symptoms

* `tcp_available_congestion_control` does not include `bbr`
* `tcp_congestion_control` refuses to change

### 🔍 Cause

* Kernel does not include BBR
* Modules not loaded (older distros)
* restricted environment

### ✅ Fix

Check availability:

```bash
sysctl net.ipv4.tcp_available_congestion_control
```

If BBR missing (older systems), attempt module load:

```bash
sudo modprobe tcp_bbr
```

Then re-check:

```bash
sysctl net.ipv4.tcp_available_congestion_control
```

### 🛡 Prevention

Prefer modern kernels for performance labs. In cloud VMs, BBR is usually available.

---

## Issue 7: systemd oneshot service does not run or shows failed

### ✅ Symptoms

* `systemctl status network-optimization.service` shows failed
* ExecStart script not found or permission denied

### 🔍 Cause

* script path incorrect
* script not executable
* service created but not enabled

### ✅ Fix

Ensure script is executable:

```bash
sudo chmod +x /usr/local/bin/ethtool_persistent.sh
```

Check service file:

```bash
cat /etc/systemd/system/network-optimization.service
```

Reload systemd and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable network-optimization.service
sudo systemctl start network-optimization.service
sudo systemctl status network-optimization.service --no-pager
```

### 🛡 Prevention

Always verify:

* correct ExecStart path
* script permissions
* service enabled at boot

---

## Issue 8: `sar` not found (sysstat missing)

### ✅ Symptoms

```bash
sar: command not found
```

### 🔍 Cause

`sysstat` package not installed.

### ✅ Fix

Ubuntu:

```bash
sudo apt-get install -y sysstat
```

RHEL/CentOS:

```bash
sudo yum install -y sysstat
# or
sudo dnf install -y sysstat
```

### 🛡 Prevention

Validate tooling before monitoring:

```bash
which sar || echo "sar missing"
```

---

## Issue 9: Benchmark results vary heavily run-to-run

### ✅ Symptoms

* inconsistent throughput
* high retransmits
* fluctuating latency

### 🔍 Cause

* background traffic
* unstable VM neighbors
* congestion on shared network
* CPU throttling under load

### ✅ Fix

Run repeatable tests:

* same duration
* same number of streams
* same window sizes
* compare averages

Use monitoring to correlate:

* `sar -u`, `sar -n DEV`, `sar -n EDEV`

### 🛡 Prevention

Run multiple trials and use median/average for reporting instead of a single run.

---

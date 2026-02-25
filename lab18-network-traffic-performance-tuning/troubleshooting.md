# 🛠️ Troubleshooting Guide - Lab 18: Network Traffic Performance Tuning 

? This guide lists the most common problems seen during TCP/DNS/network tuning, how to detect them, and safe fixes.

---

## 1) sysctl settings not applying

### Symptoms
- `sysctl -p /etc/sysctl.d/99-tcp-performance.conf` shows errors
- Values remain unchanged in `/proc/sys/...`

### Causes
- Wrong sysctl key for that kernel
- Module/feature not available (e.g., BBR)
- Typo in file (spaces, wrong name)

### Fix
- Validate keys:
  ```bash
  sysctl -a | grep -E 'net.core.rmem|max|tcp_congestion_control'
  ```

* Apply explicitly:

  ```bash
  sudo sysctl -p /etc/sysctl.d/99-tcp-performance.conf
  ```
* If a key doesn’t exist, remove it or switch to supported values (example: use `cubic`).

---

## 2) BBR not working / not available

### Symptoms

* `sysctl: cannot stat /proc/sys/net/ipv4/tcp_congestion_control`
* `tcp_available_congestion_control` does not include `bbr`

### Causes

* Kernel doesn’t support BBR (older kernel / restricted cloud kernel)
* Module not present or not loaded

### Fix

* Check availability:

  ```bash
  cat /proc/sys/net/ipv4/tcp_available_congestion_control
  ```
* Use a supported algorithm:

  ```bash
  sudo sysctl -w net.ipv4.tcp_congestion_control=cubic
  ```
* If you truly need BBR: use a kernel that supports it and ensure `tcp_bbr` module exists.

---

## 3) iperf3 server issues (port conflict / server not running)

### Symptoms

* Client shows connection refused
* `iperf3 -s -D` succeeds but no test works

### Causes

* Port already used
* Firewall blocks port
* Server didn’t actually start

### Fix

* Check listening port:

  ```bash
  ss -lntp | grep 5201
  ```
* Kill old iperf3:

  ```bash
  pkill iperf3
  ```
* Run server in foreground to confirm:

  ```bash
  iperf3 -s
  ```

---

## 4) DNS caching not improving or DNS breaks

### Symptoms

* `dig` times stay the same on repeat queries
* DNS queries fail after pointing resolv.conf to 127.0.0.1

### Causes

* dnsmasq not running
* resolv.conf overwritten by NetworkManager
* firewall blocks local resolver
* dnsmasq configured incorrectly (bad upstreams)

### Fix

* Check service:

  ```bash
  sudo systemctl status dnsmasq --no-pager
  ```
* Test local resolver directly:

  ```bash
  dig @127.0.0.1 google.com
  ```
* Restart:

  ```bash
  sudo systemctl restart dnsmasq
  ```
* If resolv.conf gets overwritten:

  * Use NetworkManager dnsmasq integration OR set resolv.conf immutable (last resort):

    ```bash
    sudo chattr +i /etc/resolv.conf
    ```

  (Prefer proper NM config over `chattr`.)

---

## 5) cloudflared / DoH proxy fails to start

### Symptoms

* `systemctl status cloudflared` shows failed
* DNS queries hang or fail

### Causes

* Binary not executable / wrong arch
* Service user/group invalid
* Upstream blocked or no outbound HTTPS
* Port already used

### Fix

* Validate service:

  ```bash
  sudo systemctl status cloudflared --no-pager
  journalctl -u cloudflared --no-pager | tail -50
  ```
* Verify it listens:

  ```bash
  ss -lntup | grep 5053
  ```
* Test directly:

  ```bash
  dig @127.0.0.1 -p 5053 google.com
  ```
* If it’s unstable, disable DoH and keep plain dnsmasq caching:

  ```bash
  sudo systemctl disable --now cloudflared
  sudo sed -i '/server=127.0.0.1#5053/d' /etc/dnsmasq.d/dns-performance.conf
  sudo systemctl restart dnsmasq
  ```

---

## 6) High TIME_WAIT or connection churn

### Symptoms

* `ss -tan state time-wait | wc -l` shows very high values
* short-lived connections dominate

### Causes

* No keep-alive / app creates many new connections
* client-side load testing
* proxy behavior

### Safe mitigations

* Enable reuse:

  ```bash
  sudo sysctl -w net.ipv4.tcp_tw_reuse=1
  ```
* Reduce FIN timeout carefully:

  ```bash
  sudo sysctl -w net.ipv4.tcp_fin_timeout=30
  ```
* **Do not use tcp_tw_recycle** (removed; unsafe historically).

---

## 7) netstat not found / missing tools

### Symptoms

* `netstat: command not found`

### Fix

* Ubuntu:

  ```bash
  sudo apt-get install -y net-tools
  ```
* RHEL/CentOS:

  ```bash
  sudo yum install -y net-tools
  ```

---

## 8) “Tuning made latency worse”

### Symptoms

* Higher RTT, worse app response time
* Throughput may increase but interactive traffic becomes sluggish

### Causes

* Bufferbloat: buffers too large
* backlog/queues too high for the workload

### Fix strategy

* Roll back one change at a time:

  * Reduce excessive buffer max values
  * Keep `netdev_max_backlog` reasonable
* Validate using:

  ```bash
  ping -c 20 <gateway_or_target>
  ss -ti
  ```

---

## 9) Settings not persistent after reboot

### Symptoms

* Values revert after restart

### Fix

* Put sysctl changes in:

  * `/etc/sysctl.d/99-tcp-performance.conf`
* Ensure it loads:

  ```bash
  sudo sysctl --system
  ```
* For interface queue length (`txqueuelen`), persist via:

  * NetworkManager config
  * or a systemd oneshot service at boot

---

## Quick “Golden Commands” Cheat Sheet

* TCP settings:

  ```bash
  sysctl net.core.rmem_max net.core.wmem_max net.ipv4.tcp_rmem net.ipv4.tcp_wmem
  ```
* Congestion control:

  ```bash
  cat /proc/sys/net/ipv4/tcp_available_congestion_control
  cat /proc/sys/net/ipv4/tcp_congestion_control
  ```
* DNS timing:

  ```bash
  dig google.com | grep "Query time"
  ```
* Connections:

  ```bash
  ss -tan | head
  ss -tan state time-wait | wc -l
  ss -tulpn | head
  ```
* Socket stats:

  ```bash
  cat /proc/net/sockstat
  ```

---

## Minimal Rollback Plan

If something breaks, revert safely:

1. restore old resolver:

   ```bash
   sudo systemctl disable --now cloudflared dnsmasq
   sudo cp /etc/resolv.conf.backup /etc/resolv.conf 2>/dev/null || true
   ```
2. remove custom sysctl:

   ```bash
   sudo rm -f /etc/sysctl.d/99-tcp-performance.conf
   sudo sysctl --system
   ```
3. confirm networking still works:

   ```bash
   ping -c 3 8.8.8.8
   dig google.com
   ```

---


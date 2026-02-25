# Interview Q&A - Lab 18: Network Traffic Performance Tuning 

> This Q&A set covers practical interview-style questions based on what was done in Lab 18:
> TCP tuning, DNS optimization, and monitoring with `netstat` / `ss`.

---

## 1) TCP Performance Tuning

### Q1. What are TCP send/receive buffers and why do they matter?
**A:**  
TCP buffers hold data waiting to be sent (send buffer) and data received but not yet processed (receive buffer).  
Larger buffers help achieve higher throughput on high-bandwidth or higher-latency links by allowing more in-flight data (better utilization of the link).

---

### Q2. What is Bandwidth-Delay Product (BDP) and how does it relate to tuning?
**A:**  
**BDP = bandwidth × RTT**. It represents how much data must be in flight to fully utilize the link.  
If TCP buffers are smaller than BDP, the sender can’t keep the pipe full, reducing throughput.

---

### Q3. What is TCP window scaling?
**A:**  
Window scaling allows TCP to use receive windows larger than 65,535 bytes by using a scale factor.  
It’s essential for high-throughput connections (especially on fast networks).

---

### Q4. What is SACK and why enable it?
**A:**  
**SACK (Selective Acknowledgment)** allows a receiver to tell the sender exactly which segments were received.  
This reduces retransmission overhead during packet loss and improves performance on lossy networks.

---

### Q5. What does `net.core.netdev_max_backlog` control?
**A:**  
It controls how many packets can be queued on the kernel’s network receive queue when the CPU can’t process packets fast enough.  
Increasing it can reduce packet drops during bursts (but too large can increase latency).

---

### Q6. What does `net.core.somaxconn` affect?
**A:**  
It’s the maximum queue length for pending TCP connections waiting to be accepted by an application.  
Higher values help servers handle connection bursts more reliably.

---

### Q7. Why didn’t BBR enable on some systems?
**A:**  
BBR requires kernel support and module availability. Some older kernels or restricted cloud kernels don’t include it.  
In such cases, `cubic` remains a safe default.

---

### Q8. What’s the difference between `tcp_rmem/tcp_wmem` and `rmem_max/wmem_max`?
**A:**  
- `net.core.rmem_max/wmem_max` set the **maximum socket buffer limit**.
- `net.ipv4.tcp_rmem/tcp_wmem` control **TCP auto-tuning ranges** (min/default/max) for TCP sockets.

Both must align to allow large TCP windows.

---

## 2) DNS Optimization

### Q9. Why does DNS caching improve performance?
**A:**  
Most apps repeatedly resolve the same domains. A local cache avoids repeated upstream lookups, reducing latency from ~10–30ms to ~1–3ms after warm-up.

---

### Q10. Why use dnsmasq instead of systemd-resolved in some environments?
**A:**  
Many RHEL/CentOS builds don’t use `systemd-resolved` by default.  
`dnsmasq` is commonly supported and integrates well with NetworkManager, making it practical for local caching.

---

### Q11. What’s the tradeoff of enabling DNS-over-HTTPS (DoH)?
**A:**  
**Pros:** privacy/security against DNS snooping, sometimes more reliable upstream resolution.  
**Cons:** extra local processing/proxy layer; if misconfigured, can break DNS or add overhead.

---

### Q12. How do you verify DNS improvement?
**A:**  
- Run `dig domain` multiple times and compare “Query time”.
- First query may be slower; second query should be much faster due to caching.

---

## 3) Monitoring with netstat and ss

### Q13. Why prefer `ss` over `netstat`?
**A:**  
`ss` is newer, faster, and provides richer socket statistics.  
It reads kernel socket info more efficiently and supports better filtering.

---

### Q14. What does a high TIME-WAIT count indicate?
**A:**  
Usually many short-lived TCP connections. It can occur with:
- load balancers or proxies
- high request rate clients
- apps not reusing connections (no keep-alive)

It’s not always a problem, but extreme growth can exhaust ports or memory.

---

### Q15. What is `tcp_tw_reuse` and when is it useful?
**A:**  
It allows reusing sockets in TIME-WAIT for new outgoing connections (client side).  
Useful in high connection churn environments.  
(Modern kernels removed `tcp_tw_recycle`—so reuse is the safer option.)

---

### Q16. How would you identify which process is using a port?
**A:**  
Use:
- `ss -tulpn` to map listening sockets to processes
- `lsof -i :PORT` (if installed)

---

### Q17. What does `/proc/net/sockstat` tell you?
**A:**  
It shows socket usage statistics (TCP/UDP sockets in use, memory usage, TIME-WAIT counts).  
Useful to detect socket pressure or connection storms.

---

## 4) Real Troubleshooting Scenarios

### Q18. “Throughput is low even after tuning buffers.” What do you check?
**A:**  
- RTT and BDP (buffers still too small for the real link)
- packet loss / retransmits (`ss -i`, `netstat -s`)
- CPU saturation and IRQ load
- NIC offloads, ring buffers, driver settings
- congestion control availability/compatibility

---

### Q19. “DNS got slower after caching.” Why?
**A:**  
Possible causes:
- caching service not running
- resolv.conf not pointing to cache
- firewall blocking local resolver port
- upstream resolvers slow/unreachable
- cache-size too small or misconfigured

---

### Q20. What’s a safe workflow for network tuning in production?
**A:**  
1) baseline metrics  
2) change one knob at a time  
3) validate under real workload  
4) monitor errors/retransmits/latency  
5) make persistent only after stable results

---

## Quick Recap (One-liners)
- **Buffers + scaling** improve throughput.
- **DNS caching** is a quick latency win.
- **ss + sockstat** help explain connection behavior and bottlenecks.
- Always validate and ensure kernel support before applying “advanced” features.

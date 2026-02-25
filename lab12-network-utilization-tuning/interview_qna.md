# 🎤 Interview Q&A — Lab 12: Network Utilization Tuning

> This Q&A covers the key Linux networking concepts practiced in Lab 12: baseline testing, sysctl tuning, NIC optimization via ethtool, validation with iperf3, and persistence via systemd.

---

## 1) Why do we measure baseline performance before tuning anything?
Because tuning without a baseline is guesswork. Baseline results let you:
- quantify improvement after changes,
- detect regressions,
- and justify configuration changes with evidence.

---

## 2) What does `iperf3` measure and why is it used for network tuning?
`iperf3` measures network throughput between two systems and supports:
- TCP throughput,
- UDP throughput + jitter/loss,
- parallel streams,
- window size testing,
- bidirectional and reverse mode testing.  
It’s ideal for repeatable, controlled performance validation.

---

## 3) What is the purpose of increasing `net.core.rmem_max` and `net.core.wmem_max`?
These set the maximum socket receive/send buffer sizes. Increasing them helps high-bandwidth paths achieve better throughput, especially when the default limits are too small for the network’s bandwidth-delay product (BDP).

---

## 4) What are `net.ipv4.tcp_rmem` and `net.ipv4.tcp_wmem`?
They define TCP buffer ranges as:
- **min / default / max** values for TCP receive (`tcp_rmem`) and send (`tcp_wmem`) buffers.  
Larger max values allow TCP to scale buffers under load to better match the path capacity.

---

## 5) What is Bandwidth-Delay Product (BDP) and why does it matter?
BDP = **Bandwidth × RTT**.  
It estimates the amount of data “in flight” needed to fully utilize a link. If TCP buffers are smaller than BDP, throughput can be artificially capped even on fast links.

---

## 6) Why did you enable TCP window scaling?
Window scaling allows TCP to use receive windows larger than 64KB, which is necessary for high-throughput networks. It’s essential for 10Gb+ links or higher RTT paths.

---

## 7) What is BBR and why would you choose it over Cubic/Reno?
**BBR** (Bottleneck Bandwidth and RTT) is a congestion control algorithm designed to:
- reduce bufferbloat,
- maintain high throughput,
- and improve performance on high-bandwidth networks.  
In this lab, BBR was enabled and verified using sysctl.

---

## 8) What does `net.core.netdev_max_backlog` control?
It controls the maximum number of packets queued on the input side when the kernel is overwhelmed. Increasing it can help in bursty traffic scenarios to reduce packet drops.

---

## 9) What is `net.core.somaxconn` used for?
It sets the maximum number of queued connections for listening sockets. It matters for servers handling many incoming connections (web servers, APIs, load balancers).

---

## 10) Why do we use `ethtool -g` and tune ring buffers?
Ring buffers handle RX/TX descriptor queues. Increasing them can:
- reduce drops during bursts,
- improve throughput stability,
- and handle high PPS workloads better, especially in virtual/cloud NIC environments.

---

## 11) What are NIC offloads (TSO/GSO/GRO) and why can they improve performance?
Offloads reduce CPU overhead by letting the NIC/kernel handle segmentation and aggregation:
- **TSO**: NIC handles TCP segmentation.
- **GSO**: kernel defers segmentation to later stages.
- **GRO**: aggregates received packets before passing up the stack.  
These often improve throughput and reduce CPU usage.

---

## 12) What is interrupt coalescing and why tune it?
Interrupt coalescing reduces CPU interrupt overhead by batching packets before raising interrupts.  
Tuning can increase throughput, but too much coalescing can increase latency. This lab balanced throughput and CPU load with moderate values.

---

## 13) Why might `ethtool` report some features as `[fixed]`?
Cloud/virtual NICs may not support or expose certain hardware capabilities. `[fixed]` means the value cannot be changed, usually due to driver/hardware limitations or hypervisor constraints.

---

## 14) How did you make ethtool changes persistent across reboots?
By creating:
- a boot-time script `/usr/local/bin/ethtool_persistent.sh`
- a **systemd oneshot service** `network-optimization.service`
Then enabling it to run automatically at boot.

---

## 15) Why did you use `sar` (sysstat) during iperf3 testing?
Because throughput alone is not enough. `sar` helps correlate performance with:
- CPU utilization,
- memory pressure,
- NIC RX/TX rates,
- network errors/drops.  
This improves troubleshooting and tuning accuracy.

---

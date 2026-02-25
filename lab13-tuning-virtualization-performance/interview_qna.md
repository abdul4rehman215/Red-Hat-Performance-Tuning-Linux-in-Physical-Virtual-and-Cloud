# 🎤 Interview Q&A — Lab 13: Tuning Virtualization Performance (KVM/libvirt)

> This Q&A reviews key virtualization tuning concepts practiced in Lab 13: vCPU topology, CPU pinning, hugepages, NUMA tuning, memory ballooning, and performance validation using stress/bench tools.

---

## 1) Why is understanding host CPU topology important for VM performance?
Because VM vCPU scheduling is affected by sockets/cores/threads. If the VM vCPU layout doesn’t align with the host topology, you can get:
- cache inefficiency,
- unpredictable scheduling,
- higher latency and jitter under load.

---

## 2) What is CPU pinning and why does it help?
CPU pinning binds VM vCPUs to specific host physical CPUs. This improves:
- cache locality,
- consistent performance,
- reduced CPU scheduling overhead,
especially for latency-sensitive workloads.

---

## 3) What does `--cpu host-passthrough` do in virt-install?
It exposes host CPU features directly to the guest, minimizing virtualization overhead and improving performance. This is commonly used when performance matters more than portability.

---

## 4) Why did vCPU state show “offline” after pinning?
Because the VM was shut off. Pinning can be stored in the domain configuration, but vCPU runtime state is offline until the VM is running.

---

## 5) What are hugepages and why are they useful in virtualization?
Hugepages use larger memory pages (e.g., 2MB vs 4KB). They reduce:
- TLB misses,
- page table overhead,
which can improve VM memory performance under heavy workloads.

---

## 6) What does “NUMA-aware memory allocation” mean?
NUMA tuning controls which NUMA node(s) VM memory is allocated from. Binding memory to a node can reduce cross-node memory access latency and improve performance consistency.

---

## 7) What is memory ballooning in virtualization?
Memory ballooning lets the hypervisor reclaim unused guest memory using a balloon driver/device (virtio-balloon). It supports dynamic memory management across multiple VMs on the host.

---

## 8) What must be in place for ballooning to work correctly?
Two key pieces:
1. **Guest driver** loaded (`virtio_balloon`)
2. **Balloon device** attached in VM XML (`<memballoon model='virtio'>...`)

---

## 9) What does `virsh setmem --live` do?
It changes the VM’s current memory allocation live (without reboot), using ballooning where supported. It adjusts the memory target the guest should release or consume.

---

## 10) Why implement automatic memory balancing?
To keep host stability while maximizing utilization. If host memory is low, reduce VM memory targets; if host memory is plentiful, increase them—within safe min/max bounds.

---

## 11) Why did you log memory balancing actions to `/var/log/memory_balancing.log`?
Logging provides:
- traceability (what changed, when, why),
- operational visibility for troubleshooting,
- audit-friendly evidence of automated decisions.

---

## 12) What tools did you use to validate performance under load?
- `stress-ng` for CPU and memory stress testing
- `sysbench` for CPU, memory, and file I/O benchmarking
- `virsh domstats` and `virsh dommemstat` for VM metrics
- `top` and `free` for host-level visibility

---

## 13) What does `virsh domstats --cpu` tell you?
It provides VM CPU statistics like cumulative CPU time, which helps correlate workload activity with VM usage and compare before/after tuning.

---

## 14) Why is it useful to run both targeted tests and comprehensive benchmarks?
- Targeted tests quickly validate specific tuning (CPU-only or memory-only).
- Comprehensive benchmarks provide broader coverage and represent mixed workloads.

This combination gives better confidence in tuning impact.

---

## 15) Why might virtualization tuning differ in cloud lab environments vs bare metal?
Cloud labs often run on shared infrastructure with:
- noisy neighbors,
- hypervisor feature limitations,
- constrained visibility for some low-level tuning,
which can impact test repeatability and available optimizations.

---

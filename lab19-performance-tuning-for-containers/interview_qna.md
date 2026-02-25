# 🎤 Interview Q&A - Lab 19: Performance Tuning for Containers

## ✅ 1) What is the goal of container performance tuning?
To **maximize performance and stability** while keeping resource usage efficient by:
- monitoring CPU/memory/disk/network usage
- setting correct **resource limits/requests**
- preventing noisy-neighbor issues
- enabling autoscaling for variable workloads

---

## ✅ 2) What does `docker stats` show?
`docker stats` provides **real-time container metrics**, such as:
- CPU %
- Memory usage / limit
- Network I/O
- Block I/O
- PIDs (process count)

---

## ✅ 3) What is the Kubernetes equivalent of `docker stats`?
- `kubectl top nodes` → node resource usage
- `kubectl top pods` → pod usage (CPU/Memory)

> Requires Metrics Server to be installed and working.

---

## ✅ 4) What are *requests* and *limits* in Kubernetes?
- **requests** = guaranteed minimum resources for scheduling  
- **limits** = maximum resources the container can use

Example:
- requests.cpu = 200m → scheduler reserves 0.2 CPU
- limits.cpu = 1000m → container cannot exceed 1 CPU (throttling may occur)

---

## ✅ 5) What happens if CPU limit is reached in Kubernetes?
The container will be **CPU throttled** (not killed).  
Symptoms:
- slower response time
- higher latency
- HPA may scale up if CPU utilization increases

---

## ✅ 6) What happens if memory limit is reached in Kubernetes?
The container is usually **OOMKilled** (killed by kernel).  
Symptoms:
- pod restarts
- Exit code often `137`
- `kubectl describe pod` shows `OOMKilled`

---

## ✅ 7) Why is setting only limits (and no requests) a bad idea?
Because:
- scheduler has no guaranteed baseline to plan capacity
- pods may be placed on nodes without enough headroom
- higher chance of evictions and unstable performance

Best practice: set **both requests + limits**.

---

## ✅ 8) What is a LimitRange and why use it?
A **LimitRange** enforces default and min/max resource settings per namespace.
Benefits:
- stops developers from deploying pods with no limits
- prevents runaway workloads
- maintains cluster stability

---

## ✅ 9) What is a ResourceQuota and why use it?
A **ResourceQuota** limits total resource usage in a namespace.
It can restrict:
- total CPU/memory requests
- total CPU/memory limits
- number of pods

Great for multi-team clusters and cost control.

---

## ✅ 10) What is HPA (Horizontal Pod Autoscaler)?
HPA automatically scales pods based on metrics like:
- CPU utilization %
- Memory utilization %
- custom metrics (advanced)

Example used:
- scale between **2 and 10 replicas**
- when CPU > 70%

---

## ✅ 11) Why did HPA increase replicas during load testing?
Because load increased CPU usage beyond target threshold (e.g., ~78%/70%),
so HPA scaled from 3 replicas → 4 replicas to reduce average utilization.

---

## ✅ 12) What are Kubernetes QoS classes?
QoS depends on requests/limits:
- **Guaranteed**: requests == limits for cpu & memory
- **Burstable**: requests < limits
- **BestEffort**: no requests/limits

Guaranteed gets the highest protection from eviction.

---

## ✅ 13) What are PriorityClasses?
They allow critical workloads to be scheduled and protected first.
Higher priority workloads:
- get scheduled earlier
- may evict lower priority pods when resources are constrained

---

## ✅ 14) What is pod anti-affinity and why use it?
Anti-affinity spreads pods across nodes to improve:
- fault tolerance
- performance (avoid packing all replicas on one node)

Even in single-node labs, it’s a best-practice concept for production.

---

## ✅ 15) What are common container performance bottlenecks?
- CPU throttling (limits too low)
- OOMKills (memory limits too low)
- Disk I/O saturation
- Network congestion
- Bad HPA targets / missing metrics
- Too many pods vs available resources (ResourceQuota hit)

---

## ✅ 16) What is the best workflow for tuning containers?
1. Measure baseline (docker stats / kubectl top)
2. Add requests/limits
3. Load test
4. Monitor bottlenecks
5. Scale with HPA
6. Enforce policies (LimitRange, ResourceQuota)
7. Repeat + validate improvements

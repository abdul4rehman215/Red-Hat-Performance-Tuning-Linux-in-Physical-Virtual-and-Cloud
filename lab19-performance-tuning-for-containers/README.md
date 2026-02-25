# 🧪 Lab 19: Performance Tuning for Containers

## 📌 Overview
This lab focuses on **monitoring and tuning container performance** in both **Docker** and **Kubernetes** environments.  
We used real-time metrics tools (**docker stats**, **kubectl top**) to observe CPU/memory/I/O behavior, then applied **resource limits/requests**, **autoscaling (HPA)**, and **advanced scheduling strategies** (QoS + priority classes) to improve reliability under load.

---

## 🎯 Objectives
- Monitor container performance using **docker stats** and **kubectl top**
- Analyze CPU, memory, and I/O metrics for containerized workloads
- Configure resource **limits/requests** and enforce policies using **LimitRange + ResourceQuota**
- Generate load and validate scaling behavior with **HPA**
- Apply container optimization best practices (readiness/liveness, initContainers, optimized config)
- Troubleshoot common bottlenecks (OOMKilled, CPU throttling, I/O wait)

---

## ✅ Prerequisites
- Linux CLI basics
- Docker fundamentals (containers, run, stats, update)
- Kubernetes basics (pods, deployments, services, namespaces)
- Understanding of resource concepts (CPU, memory, I/O)
- YAML editing experience (nano)

---

## 🧰 Lab Environment
- OS: **Ubuntu 22.04 LTS**
- Docker Engine installed
- Kubernetes single-node cluster installed
- kubectl configured
- Metrics Server available (required for kubectl top + HPA)

---

## 🧩 Task Summary

### 🐳 Task 1: Monitor Performance (Docker + Kubernetes)
**What was done**
- Launched CPU + memory stress containers using Docker with limits
- Deployed Kubernetes apps in a dedicated namespace
- Observed resource usage with:
  - Docker: `docker stats`
  - Kubernetes: `kubectl top nodes/pods`

**Outcome**
- Identified real usage patterns (CPU saturation, memory consumption trends)
- Built continuous logging for later analysis (CSV export)

---

### ⚙️ Task 2: Apply Resource Limits & Policies
**What was done**
- Docker resource controls: CPU quotas, CPU shares, memory caps, memory reservation, I/O throttling
- Kubernetes controls:
  - requests/limits in deployments
  - LimitRange enforcement
  - ResourceQuota enforcement
- Performed live tuning:
  - Docker `docker update`
  - Kubernetes `kubectl patch`

**Outcome**
- Controlled runaway usage, enforced fair scheduling, and ensured predictable behavior

---

### 📈 Task 3: Optimize Under Load + Autoscaling
**What was done**
- Generated steady load using load pods/containers
- Created ClusterIP service and validated endpoints
- Enabled HPA and observed scale-out when CPU crossed threshold
- Added optimized deployment design:
  - readinessProbe/livenessProbe
  - initContainers
  - nginx tuning via ConfigMap
- Advanced controls:
  - CPU affinity / anti-affinity
  - QoS classes (Guaranteed vs Burstable)
  - PriorityClasses for critical workloads

**Outcome**
- Verified autoscaling behavior
- Improved service stability under load and enforced workload priority rules

---

## 📊 Results
- **Docker monitoring + CSV logging** captured ongoing CPU/memory behavior
- **Kubernetes HPA increased replicas** when CPU target exceeded (real scaling observed)
- **Namespace controls** prevented exceeding allowed resources using quotas/limits
- **Optimized deployments** reduced risk of serving traffic before readiness and improved resilience

---

## 🧠 What I Learned
- Container performance tuning is a loop: **measure → limit → load test → verify → optimize**
- Docker and Kubernetes handle resource management differently, but goals are the same:
  **predictability + fairness + stability**
- HPA depends on metrics availability and correct request/limit configuration
- QoS classes and PriorityClasses matter in production when multiple workloads compete

---

## 🌍 Why This Matters
In production, container tuning directly affects:
- **cost efficiency** (better bin packing, fewer nodes needed)
- **stability** (avoid OOM kills and CPU starvation)
- **scalability** (auto scale under traffic spikes)
- **SLA reliability** (critical workloads stay responsive)

---

## 🏗️ Real-World Use Cases
- Microservices platforms with shared clusters
- API gateways and web workloads under burst traffic
- Multi-tenant clusters (resource isolation)
- CI/CD build runners competing for CPU/memory
- E-commerce traffic spikes requiring autoscaling

---

## 🗂️ Repo Structure
```bash
lab19-performance-tuning-for-containers/
├── README.md
├── commands.sh
├── output.txt
├── scripts/
│   ├── monitor_docker.sh
│   ├── monitor_k8s.sh
│   ├── performance_monitor.sh
│   └── analyze_performance.sh
├── manifests/
│   ├── web-app-deployment.yaml
│   ├── resource-demo-deployment.yaml
│   ├── limitrange.yaml
│   ├── resourcequota.yaml
│   ├── web-app-hpa.yaml
│   ├── load-tester-pod.yaml
│   ├── web-app-service.yaml
│   ├── optimized-app-deployment.yaml
│   ├── nginx-configmap.yaml
│   ├── cpu-optimized-app.yaml
│   ├── guaranteed-pod.yaml
│   ├── burstable-pod.yaml
│   ├── priorityclasses.yaml
│   └── critical-app.yaml
├── docker/
│   └── Dockerfile.optimized
├── interview_qna.md
└── troubleshooting.md
```

---

## ✅ Conclusion

This lab demonstrated how to **monitor**, **control**, and **optimize** container performance using Docker + Kubernetes.
By combining real-time metrics with limits, quotas, autoscaling, and scheduling rules, we achieved a practical workflow for keeping containerized workloads stable under pressure.

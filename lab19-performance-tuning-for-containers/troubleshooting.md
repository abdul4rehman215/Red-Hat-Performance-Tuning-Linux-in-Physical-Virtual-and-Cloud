# 🛠️ Troubleshooting Guide - Lab 19: Performance Tuning for Containers

## ✅ Issue 1: Pod stuck in Pending
### Symptoms
- `kubectl get pods` shows `Pending`
- `kubectl describe pod` shows scheduling or missing resource issues

### Fix
1) Check events:
```bash
kubectl describe pod <pod> -n performance-lab
````

2. Common causes + solutions:

* **Missing ConfigMap/Secret** → create it first, then restart pod/deployment
* **Requests too high** → reduce CPU/memory requests
* **Quota exceeded** → increase ResourceQuota or reduce usage

---

## ✅ Issue 2: Metrics not available (`kubectl top` fails)

### Symptoms

* `kubectl top pods` returns errors or empty metrics

### Fix

1. Check metrics server:

```bash
kubectl get pods -n kube-system | grep metrics
kubectl logs -n kube-system deploy/metrics-server
```

2. If missing, install Metrics Server (cluster-specific).

---

## ✅ Issue 3: Container OOMKilled (Exit Code 137)

### Symptoms

* Pod restarts
* `kubectl describe pod` shows `OOMKilled`

### Fix

1. Check last logs:

```bash
kubectl logs <pod> -n performance-lab --previous
```

2. Increase memory limit:

```bash
kubectl patch deployment <deployment> -n performance-lab \
-p='{"spec":{"template":{"spec":{"containers":[{"name":"<container>","resources":{"limits":{"memory":"1Gi"}}}]}}}}'
```

3. Reduce app memory usage (cache sizes, worker count, etc.)

---

## ✅ Issue 4: CPU throttling (slow app under load)

### Symptoms

* High latency
* CPU at/near limit
* HPA scales but performance still slow

### Fix

1. Increase CPU limit:

```bash
kubectl patch deployment <deployment> -n performance-lab \
-p='{"spec":{"template":{"spec":{"containers":[{"name":"<container>","resources":{"limits":{"cpu":"1000m"}}}]}}}}'
```

2. Add more replicas (HPA or manual scale):

```bash
kubectl scale deploy <deployment> -n performance-lab --replicas=5
```

---

## ✅ Issue 5: ResourceQuota blocks new pods

### Symptoms

* New pods fail to create
* Events show quota exceeded

### Fix

1. Check quota usage:

```bash
kubectl describe resourcequota -n performance-lab
```

2. Reduce running pods or increase quota values.

---

## ✅ Issue 6: HPA not scaling as expected

### Symptoms

* HPA stays at same replica count
* TARGETS stays low or shows `<unknown>`

### Fix

1. Verify metrics exist:

```bash
kubectl top pods -n performance-lab
kubectl get hpa -n performance-lab
kubectl describe hpa web-app-hpa -n performance-lab
```

2. Common causes:

* Metrics server not running
* wrong target deployment name
* CPU requests missing (HPA uses requests as baseline)

---

## ✅ Issue 7: Docker container I/O limit fails

### Symptoms

* `--device-read-bps` fails
* wrong disk device used (e.g., `/dev/sda` doesn’t exist)

### Fix

1. Identify actual disk:

```bash
lsblk
```

2. Re-run with correct device (example NVMe):

```bash
docker run -d --name io-limited \
 --device-read-bps /dev/nvme0n1:1mb \
 --device-write-bps /dev/nvme0n1:1mb \
 alpine:latest sh -c "while true; do dd if=/dev/zero of=/tmp/test bs=1M count=10; rm /tmp/test; sleep 5; done"
```

---

## ✅ Issue 8: Cleanup fails because namespace is deleting

### Symptoms

* `kubectl delete namespace performance-lab` hangs

### Fix

1. Check namespace status:

```bash
kubectl get ns performance-lab -o yaml | head -60
```

2. Usually resolves after resources terminate.
   If stuck, check finalizers (advanced cluster admin topic).

---

## ✅ Quick Health Checks

```bash
docker ps
docker stats --no-stream
kubectl get pods -A
kubectl top nodes
kubectl top pods -n performance-lab
kubectl get hpa -n performance-lab
kubectl describe resourcequota -n performance-lab
```


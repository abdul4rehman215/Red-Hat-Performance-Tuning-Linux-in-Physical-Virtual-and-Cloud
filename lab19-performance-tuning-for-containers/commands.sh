#!/bin/bash
# Lab 19: Performance Tuning for Containers (commands.sh)

# =========================
# Task 1: Setup sample apps
# =========================

docker run -d --name cpu-stress --cpus="1.0" --memory="512m" \
  alpine:latest sh -c "while true; do dd if=/dev/zero of=/dev/null bs=1M count=100; done"

docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

docker run -d --name memory-stress --memory="1g" \
  alpine:latest sh -c "while true; do dd if=/dev/zero of=/tmp/memory bs=1M count=500; sleep 5; rm /tmp/memory; done"

docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

kubectl create namespace performance-lab

nano web-app-deployment.yaml
kubectl apply -f web-app-deployment.yaml

kubectl get pods -n performance-lab -l app=web-app

# =========================
# Task 1: Docker monitoring
# =========================

docker stats
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

docker stats cpu-stress --no-stream
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" --no-stream

nano monitor_docker.sh
chmod +x monitor_docker.sh
./monitor_docker.sh &

head -5 docker_performance.csv

# =========================
# Task 1: K8s monitoring
# =========================

kubectl top nodes
kubectl top pods --all-namespaces
kubectl top pods -n performance-lab

kubectl describe nodes | head -60
kubectl describe pods -n performance-lab | head -80

kubectl get resourcequota -n performance-lab

nano monitor_k8s.sh
chmod +x monitor_k8s.sh
./monitor_k8s.sh &

head -5 k8s_performance.csv

# ======================================
# Task 2: Docker resource limits/requests
# ======================================

docker run -d --name limited-cpu --cpus="0.5" \
  alpine:latest sh -c "while true; do echo 'CPU limited container'; sleep 1; done"

docker run -d --name cpu-shares --cpu-shares=512 \
  alpine:latest sh -c "while true; do echo 'CPU shares container'; sleep 1; done"

docker run -d --name memory-limited --memory="256m" --memory-swap="256m" \
  alpine:latest sh -c "while true; do echo 'Memory limited'; sleep 2; done"

docker run -d --name memory-reserved --memory="512m" --memory-reservation="256m" \
  alpine:latest sh -c "while true; do echo 'Memory reserved'; sleep 2; done"

lsblk | head -10

docker run -d --name io-limited \
  --device-read-bps /dev/nvme0n1:1mb \
  --device-write-bps /dev/nvme0n1:1mb \
  alpine:latest sh -c "while true; do dd if=/dev/zero of=/tmp/test bs=1M count=10; rm /tmp/test; sleep 5; done"

# ======================================
# Task 2: Kubernetes resource controls
# ======================================

nano resource-demo-deployment.yaml
kubectl apply -f resource-demo-deployment.yaml

kubectl get pods -n performance-lab -l app=resource-demo

nano limitrange.yaml
kubectl apply -f limitrange.yaml

nano resourcequota.yaml
kubectl apply -f resourcequota.yaml

kubectl get resourcequota -n performance-lab

# ==============================
# Task 2: Dynamic adjustments
# ==============================

docker update --cpus="1.0" cpu-stress
docker update --memory="1g" memory-stress

docker inspect cpu-stress | grep -A 10 "HostConfig" | head -15

kubectl patch deployment web-app -n performance-lab \
-p='{"spec":{"template":{"spec":{"containers":[{"name":"nginx","resources":{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"200m","memory":"256Mi"}}}]}}}}'

kubectl describe deployment web-app -n performance-lab | grep -A 12 "Containers:"

# =========================
# Task 2: HPA
# =========================

kubectl autoscale deployment web-app -n performance-lab --cpu-percent=70 --min=2 --max=10
kubectl get hpa -n performance-lab

nano web-app-hpa.yaml
kubectl apply -f web-app-hpa.yaml

kubectl get hpa -n performance-lab

# ==================================
# Task 3: Load generation + Service
# ==================================

docker run -d --name load-generator \
  alpine:latest sh -c "apk add --no-cache curl && while true; do curl -s http://web-app-service.performance-lab.svc.cluster.local > /dev/null; sleep 0.1; done"

nano load-tester-pod.yaml
kubectl apply -f load-tester-pod.yaml

nano web-app-service.yaml
kubectl apply -f web-app-service.yaml

kubectl get svc -n performance-lab
kubectl get endpoints -n performance-lab web-app-service

# ==================================
# Task 3: Optimized deployment + cfg
# ==================================

nano optimized-app-deployment.yaml
kubectl apply -f optimized-app-deployment.yaml

kubectl get pods -n performance-lab -l app=optimized-app

nano nginx-configmap.yaml
kubectl apply -f nginx-configmap.yaml

kubectl get pods -n performance-lab -l app=optimized-app

nano Dockerfile.optimized

# ==================================
# Task 3: Monitoring under load
# ==================================

nano performance_monitor.sh
chmod +x performance_monitor.sh
./performance_monitor.sh &

kubectl run load-generator --image=busybox --restart=Never -n performance-lab -- \
/bin/sh -c "while true; do wget -q -O- http://web-app-service:80; done"

kubectl get pods -n performance-lab | head -20

watch kubectl get hpa -n performance-lab

kubectl get deploy -n performance-lab web-app

tail -2 performance_report.csv

# ==================================
# Task 3: Analysis script
# ==================================

nano analyze_performance.sh
chmod +x analyze_performance.sh
./analyze_performance.sh

# ==================================
# Task 3: Advanced optimization
# ==================================

nano cpu-optimized-app.yaml
kubectl apply -f cpu-optimized-app.yaml
kubectl get pods -n performance-lab -l app=cpu-optimized-app

nano guaranteed-pod.yaml
kubectl apply -f guaranteed-pod.yaml

nano burstable-pod.yaml
kubectl apply -f burstable-pod.yaml

kubectl get pod guaranteed-pod -n performance-lab -o jsonpath='{.status.qosClass}{"\n"}'
kubectl get pod burstable-pod -n performance-lab -o jsonpath='{.status.qosClass}{"\n"}'

nano priorityclasses.yaml
kubectl apply -f priorityclasses.yaml

nano critical-app.yaml
kubectl apply -f critical-app.yaml
kubectl get pods -n performance-lab -l app=critical-app

# =========================
# Troubleshooting commands
# =========================

kubectl logs <pod-name> -n performance-lab --previous

kubectl patch deployment <deployment-name> -n performance-lab \
-p='{"spec":{"template":{"spec":{"containers":[{"name":"<containername>","resources":{"limits":{"memory":"1Gi"}}}]}}}}'

docker exec <container-id> cat /sys/fs/cgroup/cpu/cpu.stat

kubectl patch deployment <deployment-name> -n performance-lab \
-p='{"spec":{"template":{"spec":{"containers":[{"name":"<containername>","resources":{"limits":{"cpu":"1000m"}}}]}}}}'

iostat -x 1
kubectl get storageclass

docker run --device-read-iops /dev/nvme0n1:1000 --device-write-iops /dev/nvme0n1:1000 <image>

# =========================
# Cleanup
# =========================

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

kubectl delete namespace performance-lab

kubectl delete priorityclass high-priority low-priority

pkill -f monitor_docker.sh
pkill -f monitor_k8s.sh
pkill -f performance_monitor.sh

#!/bin/bash
echo "=== Performance Analysis Report ==="
echo

echo "1. Container Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
echo

echo "2. Kubernetes Pod Performance:"
kubectl top pods -n performance-lab
echo

echo "3. Node Resource Utilization:"
kubectl top nodes
echo

echo "4. HPA Status:"
kubectl get hpa -n performance-lab
echo

echo "5. Resource Quotas:"
kubectl describe resourcequota -n performance-lab
echo

echo "6. Top Resource Consuming Pods:"
kubectl top pods -n performance-lab --sort-by=cpu
echo

echo "7. Container Restart Count:"
kubectl get pods -n performance-lab -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount

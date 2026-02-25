#!/bin/bash
echo "=== Performance Monitoring ==="
echo "Time: $(date)"
echo ""
echo "Load Average:"
uptime
echo ""
echo "Per-CPU Usage:"
mpstat -P ALL 1 1
echo ""
echo "Context Switches:"
vmstat 1 2 | tail -1
echo ""
echo "Memory Usage:"
free -h
echo ""

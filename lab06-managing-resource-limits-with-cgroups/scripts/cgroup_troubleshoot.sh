#!/bin/bash
echo "=== cgroup Troubleshooting Guide ==="
echo
# Check if cgroups v2 is properly mounted
echo "1. Checking cgroups v2 mount:"
if mount | grep -q "cgroup2"; then
 echo " ✓ cgroups v2 is mounted"
else
 echo " ✗ cgroups v2 not found"
 echo " Solution: Ensure kernel supports cgroups v2 and systemd is configured properly"
fi
echo
# Check available controllers
echo "2. Checking available controllers:"
if [ -f "/sys/fs/cgroup/cgroup.controllers" ]; then
 controllers=$(cat /sys/fs/cgroup/cgroup.controllers)
 echo " Available: $controllers"

 for ctrl in cpu memory io; do
  if echo "$controllers" | grep -q "$ctrl"; then
   echo " ✓ $ctrl controller available"
  else
   echo " ✗ $ctrl controller not available"
  fi
 done
else
 echo " ✗ Cannot read controller information"
fi
echo
# Check permissions
echo "3. Checking permissions:"
if [ -w "/sys/fs/cgroup" ]; then
 echo " ✓ Write access to cgroup filesystem"
else
 echo " ✗ No write access - run with sudo"
fi
echo
# Check for common configuration errors
echo "4. Checking for common issues:"
# Check if subtree_control is properly configured
if [ -f "/sys/fs/cgroup/lab6_demo/cgroup.controllers" ]; then
 enabled=$(cat /sys/fs/cgroup/cgroup.subtree_control 2>/dev/null || echo "")
 available=$(cat /sys/fs/cgroup/lab6_demo/cgroup.controllers 2>/dev/null || echo "")

 echo " Parent subtree_control: $enabled"
 echo " Child controllers: $available"

 if [ -z "$available" ]; then
  echo " ✗ No controllers available in child cgroup"
  echo " Solution: Enable controllers in parent with: echo \"+cpu +memory +io\" > /sys/fs/cgroup/cgroup.subtree_control"
 fi
fi
echo
echo "=== End Troubleshooting ==="

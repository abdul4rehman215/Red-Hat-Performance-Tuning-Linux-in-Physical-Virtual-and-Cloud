#!/bin/bash
echo "=== Tuned Troubleshooting Diagnostics ==="
echo "Date: $(date)"
echo ""
echo "1. Checking tuned service status:"
systemctl status tuned --no-pager
echo ""
echo "2. Checking if tuned daemon is running:"
ps aux | grep tuned | grep -v grep
echo ""
echo "3. Current active profile:"
tuned-adm active
echo ""
echo "4. Profile verification:"
tuned-adm verify
echo ""
echo "5. Available profiles:"
tuned-adm list
echo ""
echo "6. System recommendation:"
tuned-adm recommend
echo ""
echo "7. Checking for profile conflicts:"
if [ -f /etc/tuned/active_profile ]; then
 echo "Active profile file exists: $(cat /etc/tuned/active_profile)"
else
 echo "No active profile file found"
fi
echo ""
echo "8. Checking tuned logs:"
echo "Recent tuned log entries:"
journalctl -u tuned --no-pager -n 10
echo ""
echo "9. Checking for custom profiles:"
if [ -d /etc/tuned ]; then
 echo "Custom profiles found:"
 ls -la /etc/tuned/
else
 echo "No custom profiles directory"
fi
echo ""
echo "10. System resource check:"
echo "CPU count: $(nproc)"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Disk space: $(df -h / | tail -1 | awk '{print $4}' | head -1) available"

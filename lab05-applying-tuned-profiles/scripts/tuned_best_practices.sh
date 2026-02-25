#!/bin/bash
echo "=== Tuned Best Practices Checklist ==="
echo ""

# Check 1: Service status
echo "1. Tuned service should be enabled and running:"
if systemctl is-enabled tuned >/dev/null 2>&1 && systemctl is-active tuned >/dev/null 2>&1; then
  echo "✓ Tuned service is enabled and running"
else
  echo "✗ Tuned service is not properly configured"
  echo " Fix: sudo systemctl enable --now tuned"
fi

# Check 2: Profile verification
echo ""
echo "2. Active profile should be verified:"
if tuned-adm verify >/dev/null 2>&1; then
  echo "✓ Active profile is properly applied"
else
  echo "✗ Active profile verification failed"
  echo " Fix: Check profile configuration and reapply"
fi

# Check 3: Appropriate profile selection
echo ""
echo "3. Profile should match system type:"
current_profile=$(tuned-adm active | cut -d: -f2 | xargs)
recommended_profile=$(tuned-adm recommend)
echo " Current: $current_profile"
echo " Recommended: $recommended_profile"
if [ "$current_profile" = "$recommended_profile" ]; then
  echo "✓ Using recommended profile"
else
  echo "! Consider using recommended profile for optimal performance"
fi

# Check 4: Custom profile validation
echo ""
echo "4. Custom profiles should be properly configured:"
if [ -d /etc/tuned ]; then
  custom_profiles=$(ls /etc/tuned/ 2>/dev/null | grep -v active_profile | wc -l)
  if [ $custom_profiles -gt 0 ]; then
    echo " Found $custom_profiles custom profile(s)"
    for profile in $(ls /etc/tuned/ | grep -v active_profile); do
      if [ -f "/etc/tuned/$profile/tuned.conf" ]; then
        echo "✓ $profile has valid configuration"
      else
        echo "✗ $profile missing tuned.conf"
      fi
    done
  else
    echo " No custom profiles found"
  fi
fi

# Check 5: System monitoring
echo ""
echo "5. Performance monitoring recommendations:"
echo " - Regularly monitor system performance after profile changes"
echo " - Use tools like htop, iostat, vmstat for ongoing monitoring"
echo " - Document performance baselines for comparison"
echo " - Test profile changes in non-production environments first"
echo ""
echo "Best practices check completed"

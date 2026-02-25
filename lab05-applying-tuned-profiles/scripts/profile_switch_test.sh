#!/bin/bash
PROFILES=("balanced" "throughput-performance" "virtual-guest")
echo "=== Profile Switching Test ==="
for profile in "${PROFILES[@]}"; do
  echo "Testing profile: $profile"

  # Apply profile
  sudo tuned-adm profile $profile

  # Verify application
  if tuned-adm verify > /dev/null 2>&1; then
    echo "✓ $profile applied and verified successfully"
  else
    echo "✗ $profile verification failed"
    tuned-adm verify
  fi

  # Check active profile
  active=$(tuned-adm active | cut -d: -f2 | xargs)
  if [ "$active" = "$profile" ]; then
    echo "✓ Active profile matches expected: $active"
  else
    echo "✗ Active profile mismatch. Expected: $profile, Got: $active"
  fi

  echo "---"
  sleep 2
done
echo "Profile switching test completed"

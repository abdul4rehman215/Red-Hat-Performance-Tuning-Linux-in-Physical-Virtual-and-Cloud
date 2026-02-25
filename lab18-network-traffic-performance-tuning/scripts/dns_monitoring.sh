#!/bin/bash
echo "DNS Performance Monitoring"
echo "========================="

# Test domains for DNS resolution time
DOMAINS=("google.com" "github.com" "stackoverflow.com" "redhat.com" "ubuntu.com")

echo "Testing DNS resolution times..."
for domain in "${DOMAINS[@]}"; do
  echo -n "Testing $domain: "
  dig +short +time=1 +tries=1 $domain > /dev/null
  if [ $? -eq 0 ]; then
    time_result=$(dig $domain | grep "Query time" | awk '{print $4}')
    echo "${time_result}ms"
  else
    echo "Failed"
  fi
done

echo ""
echo "DNS Cache Statistics:"
# systemd-resolve is not available here, so show dnsmasq status instead
sudo systemctl status dnsmasq --no-pager | head -15

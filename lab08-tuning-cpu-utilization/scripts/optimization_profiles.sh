#!/bin/bash
# CPU Optimization Profiles

apply_throughput_profile() {
  echo "Applying THROUGHPUT optimization profile..."

  sudo sysctl kernel.sched_min_granularity_ns=10000000
  sudo sysctl kernel.sched_wakeup_granularity_ns=15000000
  sudo sysctl kernel.sched_migration_cost_ns=5000000
  sudo sysctl kernel.sched_latency_ns=24000000

  echo "Throughput profile applied"
}

apply_latency_profile() {
  echo "Applying LATENCY optimization profile..."

  sudo sysctl kernel.sched_min_granularity_ns=1000000
  sudo sysctl kernel.sched_wakeup_granularity_ns=2000000
  sudo sysctl kernel.sched_migration_cost_ns=250000
  sudo sysctl kernel.sched_latency_ns=6000000

  echo "Latency profile applied"
}

apply_balanced_profile() {
  echo "Applying BALANCED optimization profile..."

  sudo sysctl kernel.sched_min_granularity_ns=3000000
  sudo sysctl kernel.sched_wakeup_granularity_ns=4000000
  sudo sysctl kernel.sched_migration_cost_ns=500000
  sudo sysctl kernel.sched_latency_ns=12000000

  echo "Balanced profile applied"
}

show_current_profile() {
  echo "Current scheduler settings:"
  echo " sched_min_granularity_ns: $(sysctl -n kernel.sched_min_granularity_ns)"
  echo " sched_wakeup_granularity_ns: $(sysctl -n kernel.sched_wakeup_granularity_ns)"
  echo " sched_migration_cost_ns: $(sysctl -n kernel.sched_migration_cost_ns)"
  echo " sched_latency_ns: $(sysctl -n kernel.sched_latency_ns)"
}

case "$1" in
  throughput)
    apply_throughput_profile
    ;;
  latency)
    apply_latency_profile
    ;;
  balanced)
    apply_balanced_profile
    ;;
  show)
    show_current_profile
    ;;
  *)
    echo "Usage: $0 {throughput|latency|balanced|show}"
    echo ""
    echo "Profiles:"
    echo " throughput - Optimize for maximum throughput"
    echo " latency - Optimize for low latency"
    echo " balanced - Balanced performance"
    echo " show - Show current settings"
    exit 1
    ;;
esac

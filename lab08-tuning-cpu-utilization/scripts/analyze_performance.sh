#!/bin/bash
RESULTS_FILE="performance_analysis.txt"

analyze_cpu_usage() {
  echo "=== CPU Usage Analysis ===" >> $RESULTS_FILE
  echo "Date: $(date)" >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE

  echo "Current CPU Utilization:" >> $RESULTS_FILE
  top -bn1 | grep "Cpu(s)" >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE

  echo "Load Average:" >> $RESULTS_FILE
  uptime >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE

  echo "Per-CPU Statistics:" >> $RESULTS_FILE
  mpstat -P ALL 1 1 >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE
}

analyze_scheduler_performance() {
  echo "=== Scheduler Performance ===" >> $RESULTS_FILE

  echo "Context Switches per second:" >> $RESULTS_FILE
  vmstat 1 5 | tail -1 | awk '{print "Context switches: " $12}' >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE

  echo "Run Queue Statistics:" >> $RESULTS_FILE
  vmstat 1 5 | tail -1 | awk '{print "Processes waiting: " $1}' >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE
}

generate_recommendations() {
  echo "=== Performance Recommendations ===" >> $RESULTS_FILE

  NCPUS=$(nproc)
  LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')

  echo "System Configuration:" >> $RESULTS_FILE
  echo " CPU Cores: $NCPUS" >> $RESULTS_FILE
  echo " Current Load: $LOAD_AVG" >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE

  echo "Recommendations:" >> $RESULTS_FILE

  if (( $(echo "$LOAD_AVG > $NCPUS" | bc -l) )); then
    echo " - System is overloaded (load > cores)" >> $RESULTS_FILE
    echo " - Consider reducing concurrent processes" >> $RESULTS_FILE
    echo " - Implement CPU affinity to reduce context switching" >> $RESULTS_FILE
  else
    echo " - System load is acceptable" >> $RESULTS_FILE
    echo " - Consider CPU affinity for CPU-intensive applications" >> $RESULTS_FILE
  fi

  echo " - Monitor context switches - high values indicate scheduling overhead" >> $RESULTS_FILE
  echo " - Use CPU affinity for processes with specific performance requirements" >> $RESULTS_FILE
  echo " - Consider NUMA topology for multi-socket systems" >> $RESULTS_FILE
  echo "" >> $RESULTS_FILE
}

echo "Performing performance analysis..."
analyze_cpu_usage
analyze_scheduler_performance
generate_recommendations
echo "Analysis complete. Results saved to $RESULTS_FILE"
cat $RESULTS_FILE

#!/bin/bash
# Lab 20: Comprehensive Performance Review - commands.sh
# Note: This file lists the commands executed in serial order (as performed in the lab).

# =========================
# Task 1: Setup + Baseline
# =========================

# Create workspace
sudo mkdir -p /opt/performance-review
cd /opt/performance-review

# Create subdirectories
sudo mkdir -p baseline monitoring reports scripts

# Fix permissions so current user can write
sudo chown -R "$USER:$USER" /opt/performance-review

# Verify tools exist
which top iostat sar htop vmstat free df

# Create baseline file (created via nano in lab)
# nano baseline/system_info.txt
cat baseline/system_info.txt

# ==========================================
# Task 1.2: Create + Run monitoring script
# ==========================================

# Create monitoring script (created via nano in lab)
# nano scripts/performance_monitor.sh
chmod +x scripts/performance_monitor.sh

# Run monitoring (5 minutes)
./scripts/performance_monitor.sh

# Verify monitoring output files
ls -lh /opt/performance-review/monitoring/ | head
ls -lh /opt/performance-review/monitoring/20260225_192950 | head

# ==========================================
# Task 1.3: Stress generation (CPU + I/O)
# ==========================================

# Create CPU stress script (created via nano in lab)
# nano scripts/cpu_stress.sh
chmod +x scripts/cpu_stress.sh

# Create I/O stress script (created via nano in lab)
# nano scripts/io_stress.sh
chmod +x scripts/io_stress.sh

# Run CPU stress in background
./scripts/cpu_stress.sh &
sleep 30

# Run I/O stress in background
./scripts/io_stress.sh &
echo "Stress tests initiated. Monitor system performance."

# Wait for jobs by PID (example PIDs from lab)
wait 13218
wait 13288

# ==========================================
# Task 2.1: Analyze collected monitoring data
# ==========================================

# Create analysis script (created via nano in lab)
# nano scripts/analyze_performance.sh
chmod +x scripts/analyze_performance.sh

# Run analysis
./scripts/analyze_performance.sh

# ==========================================
# Task 2.2: Identify bottlenecks + tunables
# ==========================================

# Create bottleneck identification script (created via nano in lab)
# nano scripts/identify_bottlenecks.sh
chmod +x scripts/identify_bottlenecks.sh

# Install bc (used by script for numeric comparisons)
sudo apt-get install -y bc >/dev/null 2>&1 || true

# Run bottleneck script
./scripts/identify_bottlenecks.sh

# ==========================================
# Task 3.1: Tuning recommendations
# ==========================================

# Create tuning recommendations script (created via nano in lab)
# nano scripts/tuning_recommendations.sh
chmod +x scripts/tuning_recommendations.sh

# Run tuning recommendations
./scripts/tuning_recommendations.sh

# ==========================================
# Task 3.2: Apply tuning (requires sudo)
# ==========================================

# Create apply tuning script (created via nano in lab)
# nano scripts/apply_tuning.sh
chmod +x scripts/apply_tuning.sh

# Apply tuning
sudo ./scripts/apply_tuning.sh

# ==========================================
# Task 3.3: Verify tuning
# ==========================================

# Create verify script (created via nano in lab)
# nano scripts/verify_tuning.sh
chmod +x scripts/verify_tuning.sh

# Verify tuning
./scripts/verify_tuning.sh

# ==========================================
# Task 4.1: Post-tuning performance test
# ==========================================

# Create post tuning test script (created via nano in lab)
# nano scripts/post_tuning_test.sh
chmod +x scripts/post_tuning_test.sh

# Run post tuning tests
./scripts/post_tuning_test.sh

# ==========================================
# Task 4.2: Compare baseline vs post-tuning
# ==========================================

# Create compare script (created via nano in lab)
# nano scripts/compare_performance.sh
chmod +x scripts/compare_performance.sh

# Run comparison
./scripts/compare_performance.sh

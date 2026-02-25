#!/bin/bash
echo "=== Performance Tuning Results Comparison ==="
echo "Date: $(date)"
echo

echo "=== System Configuration Changes ==="
echo "Memory Settings:"
echo " vm.swappiness: $(sysctl -n vm.swappiness)"
echo " vm.dirty_ratio: $(sysctl -n vm.dirty_ratio)"
echo " vm.dirty_background_ratio: $(sysctl -n vm.dirty_background_ratio)"
echo

echo "I/O Scheduler:"
cat /sys/block/sda/queue/scheduler
echo

echo "Network Buffers:"
echo " net.core.rmem_max: $(sysctl -n net.core.rmem_max)"
echo " net.core.wmem_max: $(sysctl -n net.core.wmem_max)"
echo

echo "=== PostgreSQL Configuration ==="
sudo -u postgres psql testdb -c "
SELECT name, setting, unit
FROM pg_settings
WHERE name IN (
 'shared_buffers',
 'effective_cache_size',
 'work_mem',
 'maintenance_work_mem',
 'max_connections'
);
"
echo

echo "=== Performance Metrics ==="
echo "Current Cache Hit Ratio:"
sudo -u postgres psql testdb -c "
SELECT
 ROUND(
 (blks_hit::float / (blks_hit + blks_read)) * 100, 2
 ) as cache_hit_ratio_percent
FROM pg_stat_database
WHERE datname = 'testdb' AND (blks_hit + blks_read) > 0;
"
echo

echo "=== Recommendations ==="
echo "1. Monitor cache hit ratio - should be > 95%"
echo "2. Watch for excessive sequential scans"
echo "3. Monitor I/O wait times during peak loads"
echo "4. Consider additional indexes for frequently queried columns"
echo "5. Regular VACUUM and ANALYZE operations"

#!/bin/bash
echo "=== Database Performance Analysis ==="
echo "Date: $(date)"
echo

echo "=== System Resource Usage ==="
echo "Memory Usage:"
free -h
echo

echo "Disk Usage:"
df -h
echo

echo "CPU Load:"
uptime
echo

echo "=== Database Statistics ==="
sudo -u postgres psql testdb -c "
SELECT
 'Cache Hit Ratio' as metric,
 ROUND(
 (blks_hit::float / (blks_hit + blks_read)) * 100, 2
 ) as percentage
FROM pg_stat_database
WHERE datname = 'testdb' AND (blks_hit + blks_read) > 0;
"
echo

sudo -u postgres psql testdb -c "
SELECT
 schemaname,
 tablename,
 seq_scan,
 seq_tup_read,
 idx_scan,
 idx_tup_fetch,
 n_tup_ins,
 n_tup_upd,
 n_tup_del
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;
"
echo

echo "=== Top Slow Queries ==="
sudo -u postgres psql testdb -c "
SELECT
 LEFT(query, 80) as query_snippet,
 calls,
 ROUND(total_time::numeric, 2) as total_time_ms,
 ROUND(mean_time::numeric, 2) as avg_time_ms,
 ROUND((100.0 * total_time / sum(total_time) OVER())::numeric, 2) as percentage
FROM pg_stat_statements
WHERE calls > 10
ORDER BY total_time DESC
LIMIT 10;
"
echo

echo "=== Index Usage Analysis ==="
sudo -u postgres psql testdb -c "
SELECT
 schemaname,
 tablename,
 indexname,
 idx_scan,
 idx_tup_read,
 idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
"

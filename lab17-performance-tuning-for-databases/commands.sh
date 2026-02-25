# commands.sh
# Lab 17: Performance Tuning for Databases (PostgreSQL on RHEL 8/9)


# ----------------------------
# Task 1.1 - Baseline system checks (memory + disk + kernel)
# ----------------------------
free -h
swapon --show
sysctl vm.swappiness
sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio

lsblk
cat /sys/block/sda/queue/scheduler
df -h
mount | grep -E "(ext4|xfs)"

# ----------------------------
# Task 1.1 - Baseline PostgreSQL memory settings
# ----------------------------
sudo -u postgres psql -c "SHOW shared_buffers;"
sudo -u postgres psql -c "SHOW effective_cache_size;"
sudo -u postgres psql -c "SHOW work_mem;"
sudo -u postgres psql -c "SHOW maintenance_work_mem;"

# ----------------------------
# Task 1.2 - Kernel memory tuning (sysctl)
# ----------------------------
sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
sudo nano /etc/sysctl.conf
sudo sysctl -p

# ----------------------------
# Task 1.2 - PostgreSQL memory config tuning
# ----------------------------
TOTAL_MEM=$(free -b | awk 'NR==2{print $2}')
SHARED_BUFFERS=$((TOTAL_MEM / 4))
EFFECTIVE_CACHE=$((TOTAL_MEM * 3 / 4))
sudo cp /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.conf.backup
sudo nano /var/lib/pgsql/data/postgresql.conf

# ----------------------------
# Task 1.3 - Disk scheduler + persistence (udev)
# ----------------------------
echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler
cat /sys/block/sda/queue/scheduler
echo 'ACTION=="add|change", KERNEL=="sda", ATTR{queue/scheduler}="mq-deadline"' | sudo tee /etc/udev/rules.d/60-scheduler.rules

# ----------------------------
# Task 1.3 - Filesystem mount options (fstab)
# ----------------------------
mount | grep "on / "
sudo cp /etc/fstab /etc/fstab.backup
sudo sed -i 's/defaults/defaults,noatime,nodiratime/' /etc/fstab
grep -v '^#' /etc/fstab | sed '/^$/d'

# ----------------------------
# Task 1.3 - Readahead tuning + persistence (systemd oneshot)
# ----------------------------
sudo blockdev --getra /dev/sda
sudo blockdev --setra 8192 /dev/sda
sudo nano /etc/systemd/system/database-tuning.service
sudo systemctl enable database-tuning.service

# ----------------------------
# Task 2.1 - Deadline (mq-deadline) scheduler parameters
# ----------------------------
echo 1 | sudo tee /sys/block/sda/queue/iosched/front_merges
echo 150 | sudo tee /sys/block/sda/queue/iosched/read_expire
echo 1500 | sudo tee /sys/block/sda/queue/iosched/write_expire
echo 6 | sudo tee /sys/block/sda/queue/iosched/writes_starved

sudo nano /usr/local/bin/database-io-tuning.sh
sudo chmod +x /usr/local/bin/database-io-tuning.sh
echo '/usr/local/bin/database-io-tuning.sh' | sudo tee -a /etc/rc.local
sudo chmod +x /etc/rc.local

# Attempted ext4 journaling mode tweak (expected to fail on some systems)
sudo tune2fs -o journal_data_writeback /dev/sda1

# ----------------------------
# Task 2.2 - Network buffers tuning (sysctl)
# ----------------------------
sudo nano /etc/sysctl.conf
sudo sysctl -p

# PostgreSQL connection settings
sudo nano /var/lib/pgsql/data/postgresql.conf

# ----------------------------
# Task 2.3 - PgBouncer install + configuration
# ----------------------------
sudo dnf install -y pgbouncer
sudo nano /etc/pgbouncer/pgbouncer.ini
sudo nano /etc/pgbouncer/userlist.txt
sudo chown postgres:postgres /etc/pgbouncer/pgbouncer.ini
sudo chown postgres:postgres /etc/pgbouncer/userlist.txt
sudo chmod 640 /etc/pgbouncer/pgbouncer.ini
sudo chmod 640 /etc/pgbouncer/userlist.txt
sudo systemctl start pgbouncer
sudo systemctl enable pgbouncer

# ----------------------------
# Task 3.1 - Install monitoring tools + enable sysstat
# ----------------------------
sudo dnf install -y htop iotop sysstat postgresql-contrib
sudo systemctl enable sysstat
sudo systemctl start sysstat

# PostgreSQL monitoring settings (pg_stat_statements + logs)
sudo nano /var/lib/pgsql/data/postgresql.conf
sudo systemctl restart postgresql

# Create DB + extensions
sudo -u postgres createdb testdb
sudo -u postgres psql testdb -c "CREATE EXTENSION pg_stat_statements;"
sudo -u postgres psql testdb -c "CREATE EXTENSION pgstattuple;"

# ----------------------------
# Task 3.2 - Load sample schema + data + indexes
# ----------------------------
sudo -u postgres psql testdb << 'EOF'
-- Create sample tables
CREATE TABLE customers (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100),
 email VARCHAR(100),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
 id SERIAL PRIMARY KEY,
 customer_id INTEGER REFERENCES customers(id),
 amount DECIMAL(10,2),
 order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO customers (name, email)
SELECT
 'Customer ' || generate_series,
 'customer' || generate_series || '@example.com'
FROM generate_series(1, 100000);

INSERT INTO orders (customer_id, amount)
SELECT
 (random() * 100000)::integer + 1,
 (random() * 1000)::decimal(10,2)
FROM generate_series(1, 500000);

-- Create indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);

-- Update statistics
ANALYZE customers;
ANALYZE orders;
EOF

# Create workload script
sudo mkdir -p /home/student
sudo nano /home/student/db_workload_test.sh
sudo chmod +x /home/student/db_workload_test.sh

# ----------------------------
# Task 3.3 - Baseline measurement + monitoring
# ----------------------------
sudo systemctl restart postgresql
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
sudo -u postgres psql testdb -c "SELECT pg_stat_reset();"
sudo -u postgres psql testdb -c "SELECT pg_stat_statements_reset();"

iostat -x 1 > /tmp/iostat_baseline.log &
IOSTAT_PID=$!
vmstat 1 > /tmp/vmstat_baseline.log &
VMSTAT_PID=$!

sudo -u postgres psql testdb << 'EOF' > /tmp/pg_baseline_start.log
SELECT now() as start_time;
\timing on
EOF

echo "Running baseline performance test..."
/home/student/db_workload_test.sh

kill $IOSTAT_PID $VMSTAT_PID

sudo -u postgres psql testdb -c "
SELECT now() as end_time;
SELECT * FROM pg_stat_database WHERE datname = 'testdb';
" > /tmp/pg_baseline_end.log
head -30 /tmp/pg_baseline_end.log

# ----------------------------
# Task 3.4 - Analyze query performance (pg_stat_statements, pg_stat_database)
# ----------------------------
sudo -u postgres psql testdb -c "
SELECT
 query,
 calls,
 total_time,
 mean_time,
 rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
"

sudo -u postgres psql testdb -c "
SELECT
 datname,
 numbackends,
 xact_commit,
 xact_rollback,
 blks_read,
 blks_hit,
 tup_returned,
 tup_fetched,
 tup_inserted,
 tup_updated,
 tup_deleted
FROM pg_stat_database
WHERE datname = 'testdb';
"

# Analysis script
sudo nano /home/student/analyze_performance.sh
sudo chmod +x /home/student/analyze_performance.sh
/home/student/analyze_performance.sh > /tmp/performance_analysis.txt
cat /tmp/performance_analysis.txt

# ----------------------------
# Task 3.5 - Compare tuning results
# ----------------------------
sudo nano /home/student/performance_comparison.sh
sudo chmod +x /home/student/performance_comparison.sh
/home/student/performance_comparison.sh

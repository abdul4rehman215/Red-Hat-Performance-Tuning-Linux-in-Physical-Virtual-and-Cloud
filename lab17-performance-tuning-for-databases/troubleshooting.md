# Troubleshooting Guide - Lab 17: Performance Tuning for Databases (PostgreSQL)

## Issue 1: PostgreSQL fails to start after config changes
### Symptoms
- `systemctl status postgresql` shows failed
- Database refuses connections
- Errors after editing `postgresql.conf`

### Checks
```bash
sudo systemctl status postgresql --no-pager
sudo tail -n 100 /var/lib/pgsql/data/pg_log/postgresql-*.log 2>/dev/null || sudo journalctl -u postgresql --no-pager | tail -100
````

### Fix

1. Validate the last configuration edits (common issues: units, typos).
2. Restore backup if needed:

```bash
sudo cp /var/lib/pgsql/data/postgresql.conf.backup /var/lib/pgsql/data/postgresql.conf
sudo systemctl restart postgresql
```

---

## Issue 2: `sysctl -p` errors (some parameters not available)

### Symptoms

* `sysctl: cannot stat ...` messages
* Not all kernel parameters exist on that kernel/version

### Fix

This is common across kernels/cloud images. Keep only supported parameters:

```bash
sudo sysctl -a | grep -E "vm.swappiness|vm.dirty_ratio|vm.dirty_background_ratio|net.core.rmem_max"
```

Then remove unsupported lines from `/etc/sysctl.conf` and re-apply:

```bash
sudo sysctl -p
```
---

## Issue 3: Changes to `/etc/fstab` cause boot/mount issues

### Symptoms

* After reboot, system drops to emergency shell
* Root filesystem fails to mount due to syntax error

### Fix (best practice)

Always validate `/etc/fstab` edits before reboot:

```bash
sudo mount -a
```

Rollback (if needed):

```bash
sudo cp /etc/fstab.backup /etc/fstab
sudo mount -a
```

---

## Issue 4: `blockdev --setra` not persistent after reboot

### Symptoms

* Readahead reverts after reboot

### Fix

Ensure the service is enabled and runs:

```bash
sudo systemctl daemon-reload
sudo systemctl enable database-tuning.service
sudo systemctl start database-tuning.service
sudo systemctl status database-tuning.service --no-pager
```

Confirm value:

```bash
sudo blockdev --getra /dev/sda
```

---

## Issue 5: I/O scheduler setting does not change or reverts

### Symptoms

* `cat /sys/block/sda/queue/scheduler` still shows old selection
* After reboot, scheduler resets

### Fix

1. Confirm supported schedulers:

```bash
cat /sys/block/sda/queue/scheduler
```

2. Set the scheduler (use correct scheduler name for kernel):

```bash
echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler
```

3. Persist via udev rule and reload:

```bash
sudo cat /etc/udev/rules.d/60-scheduler.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
cat /sys/block/sda/queue/scheduler
```

---

## Issue 6: `tune2fs -o journal_data_writeback` fails (not supported)

### Symptoms

* `Setting filesystem feature 'journal_data_writeback' not supported.`

### Explanation

Modern ext4 behavior differs; many tuning knobs are done via mount options (`data=writeback`) rather than tune2fs “-o” style features.

### Fix (optional, if you intentionally want writeback mode)

Use mount option instead (HIGH RISK for DB integrity; not recommended for production unless you fully understand durability tradeoffs):

```bash
# Example only — do not apply blindly
# /etc/fstab: add data=writeback
```

---

## Issue 7: Peer authentication blocks `psql -U postgres` from normal user

### Symptoms

* `psql: FATAL: Peer authentication failed for user "postgres"`

### Fix

Run commands as postgres OS user (used in this lab):

```bash
sudo -u postgres psql -d testdb -c "SELECT 1;"
```

Alternative: change `pg_hba.conf` (NOT recommended in a basic lab unless required).

---

## Issue 8: PgBouncer fails to start

### Symptoms

* `systemctl status pgbouncer` shows failed
* Connections to port 6432 fail

### Checks

```bash
sudo systemctl status pgbouncer --no-pager
sudo tail -n 100 /var/log/pgbouncer/pgbouncer.log 2>/dev/null || sudo journalctl -u pgbouncer --no-pager | tail -100
sudo ss -lntp | grep 6432
```

### Fix

1. Validate config syntax:

```bash
sudo cat /etc/pgbouncer/pgbouncer.ini
sudo cat /etc/pgbouncer/userlist.txt
```

2. Permissions:

```bash
sudo chown postgres:postgres /etc/pgbouncer/pgbouncer.ini /etc/pgbouncer/userlist.txt
sudo chmod 640 /etc/pgbouncer/pgbouncer.ini /etc/pgbouncer/userlist.txt
```

3. Restart:

```bash
sudo systemctl restart pgbouncer
sudo systemctl status pgbouncer --no-pager
```

---

## Issue 9: `pg_stat_statements` does not show data

### Symptoms

* Query to `pg_stat_statements` returns empty or errors
* Extension missing

### Fix

1. Ensure preload library is enabled:

```bash
sudo -u postgres psql -c "SHOW shared_preload_libraries;"
```

2. Ensure extension exists in database:

```bash
sudo -u postgres psql testdb -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
```

3. Restart PostgreSQL after changing preload libraries:

```bash
sudo systemctl restart postgresql
```

---

## Issue 10: High sequential scans still happening after tuning

### Symptoms

* `pg_stat_user_tables` shows high `seq_scan` on large tables

### Fix approach

1. Identify the queries causing it:

```bash
sudo -u postgres psql testdb -c "
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;"
```

2. Inspect indexes and stats:

```bash
sudo -u postgres psql testdb -c "\d orders"
sudo -u postgres psql testdb -c "ANALYZE orders;"
```

3. Consider adding the right index (based on WHERE/JOIN patterns), then re-test workload.

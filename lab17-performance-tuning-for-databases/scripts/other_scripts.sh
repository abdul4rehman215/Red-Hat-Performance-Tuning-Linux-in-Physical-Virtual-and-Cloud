# ============================================================
# 6) /etc/udev/rules.d/60-scheduler.rules
# ============================================================
ACTION=="add|change", KERNEL=="sda", ATTR{queue/scheduler}="mq-deadline"


# ============================================================
# 7) /etc/rc.local  (line appended)
# ============================================================
/usr/local/bin/database-io-tuning.sh


# ============================================================
# 8) /etc/pgbouncer/pgbouncer.ini
# ============================================================
[databases]
testdb = host=localhost port=5432 dbname=testdb

[pgbouncer]
listen_port = 6432
listen_addr = *
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
logfile = /var/log/pgbouncer/pgbouncer.log
pidfile = /var/run/pgbouncer/pgbouncer.pid
admin_users = postgres
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
reserve_pool_size = 5


# ============================================================
# 9) /etc/pgbouncer/userlist.txt
# ============================================================
"postgres" "md5d41d8cd98f00b204e9800998ecf8427e"

# commands.sh
# Lab 16: Implementing Performance Monitoring with sar (sysstat)
# Note: Commands are captured in the same sequence they were executed in the lab.

# -----------------------------
# Task 1: Install & Enable sar
# -----------------------------

which sar
sar -V

sudo yum install -y sysstat

which sar
sar -V

sudo systemctl enable sysstat
sudo systemctl start sysstat
sudo systemctl status sysstat

# -----------------------------------------
# Task 1.2: Configure sysstat collection
# -----------------------------------------

sudo nano /etc/sysconfig/sysstat
sudo nano /etc/cron.d/sysstat

# -----------------------------------------
# Task 1.2: Custom data collection script
# -----------------------------------------

sudo nano /usr/local/bin/custom-sar-collect.sh
sudo chmod +x /usr/local/bin/custom-sar-collect.sh
sudo /usr/local/bin/custom-sar-collect.sh
sudo ls -la /var/log/sar-custom | head

# -----------------------------------------
# Task 1.3: Verify sar is collecting data
# -----------------------------------------

ls -la /var/log/sa/
ls -lt /var/log/sa/ | head -5

# -----------------------------------------
# Generate workload for testing (install tools)
# -----------------------------------------

stress-ng --version

sudo yum install -y epel-release
sudo yum install -y stress-ng

# Workload generation
stress-ng --cpu 2 --timeout 60s &
stress-ng --vm 1 --vm-bytes 512M --timeout 60s &
dd if=/dev/zero of=/tmp/testfile bs=1M count=100

# -----------------------------------------
# Verify sar outputs (live + historical)
# -----------------------------------------

sar -u 1 5
sar -u -f /var/log/sa/sa$(date +%d)

# -----------------------------------------
# Task 2: CPU utilization analysis
# -----------------------------------------

sar -u
sar -u -s 09:00:00 -e 17:00:00
sar -u -f /var/log/sa/sa$(date +%d)

nano cpu-analysis.sh
chmod +x cpu-analysis.sh
./cpu-analysis.sh

# -----------------------------------------
# Task 2.2: Memory utilization analysis
# -----------------------------------------

sar -r
sar -S
sar -r -s 08:00:00 -e 18:00:00

nano memory-analysis.sh
chmod +x memory-analysis.sh
./memory-analysis.sh

# -----------------------------------------
# Task 2.3: Disk I/O analysis
# -----------------------------------------

sar -d
sar -d | grep -E "(DEV|Average)"
sar -d -p | grep sda

nano disk-analysis.sh
chmod +x disk-analysis.sh
./disk-analysis.sh

# -----------------------------------------
# Task 2.4: Network analysis
# -----------------------------------------

sar -n DEV
sar -n EDEV
sar -n TCP

nano network-analysis.sh
chmod +x network-analysis.sh
./network-analysis.sh

# -----------------------------------------
# Task 3: Reporting & automation
# -----------------------------------------

bc --version
sudo yum install -y bc

nano performance-report.sh
chmod +x performance-report.sh
./performance-report.sh
cat /tmp/performance-report-$(date +%Y-%m-%d).txt

nano historical-analysis.sh
chmod +x historical-analysis.sh
./historical-analysis.sh
cat /tmp/historical-trends-$(date +%Y-%m-%d).txt

sudo nano /usr/local/bin/daily-performance-report.sh
sudo chmod +x /usr/local/bin/daily-performance-report.sh
echo "0 6 * * * root /usr/local/bin/daily-performance-report.sh" | sudo tee -a /etc/crontab
sudo /usr/local/bin/daily-performance-report.sh
sudo head -40 /var/log/performance-reports/daily-report-$(date +%Y-%m-%d).txt

nano performance-dashboard.sh
chmod +x performance-dashboard.sh
./performance-dashboard.sh

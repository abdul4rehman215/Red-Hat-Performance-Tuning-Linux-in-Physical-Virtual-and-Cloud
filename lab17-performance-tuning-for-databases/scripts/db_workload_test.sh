#!/bin/bash
# Database Performance Test Script

DB_NAME="testdb"
DB_USER="postgres"
DURATION=300 # 5 minutes
CONNECTIONS=20

echo "Starting database performance test..."
echo "Duration: ${DURATION} seconds"
echo "Concurrent connections: ${CONNECTIONS}"

# Function to run concurrent queries
run_queries() {
 local conn_id=$1
 local end_time=$(($(date +%s) + DURATION))

 while [ $(date +%s) -lt $end_time ]; do
   # Mix of different query types
   sudo -u postgres psql -d $DB_NAME -c "
   SELECT c.name, COUNT(o.id) as order_count, SUM(o.amount) as total_amount
   FROM customers c
   LEFT JOIN orders o ON c.id = o.customer_id
   WHERE c.created_at > NOW() - INTERVAL '30 days'
   GROUP BY c.id, c.name
   ORDER BY total_amount DESC
   LIMIT 100;
   " > /dev/null 2>&1

   sudo -u postgres psql -d $DB_NAME -c "
   SELECT * FROM orders
   WHERE order_date BETWEEN NOW() - INTERVAL '7 days' AND NOW()
   ORDER BY amount DESC
   LIMIT 50;
   " > /dev/null 2>&1

   # Small delay between queries
   sleep 0.1
 done
}

# Start concurrent connections
for i in $(seq 1 $CONNECTIONS); do
 run_queries $i &
done

# Wait for all background jobs to complete
wait
echo "Performance test completed!"

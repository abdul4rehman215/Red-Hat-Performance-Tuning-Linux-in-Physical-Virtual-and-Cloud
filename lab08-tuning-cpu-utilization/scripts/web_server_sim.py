#!/usr/bin/env python3
import time
import threading
import random
import os
import sys

class WebServerSimulator:
    def __init__(self, num_workers=4, duration=60):
        self.num_workers = num_workers
        self.duration = duration
        self.request_count = 0
        self.start_time = time.time()
        self.lock = threading.Lock()

    def process_request(self, worker_id):
        """Simulate processing a web request"""
        calculation_result = 0
        for i in range(random.randint(10000, 50000)):
            calculation_result += i ** 0.5

        # Simulate I/O operations
        time.sleep(random.uniform(0.001, 0.01))
        return calculation_result

    def worker_thread(self, worker_id):
        """Worker thread that processes requests"""
        local_count = 0
        print(f"Worker {worker_id} (PID: {os.getpid()}, TID: {threading.get_ident()}) started")

        while time.time() - self.start_time < self.duration:
            self.process_request(worker_id)
            local_count += 1
            with self.lock:
                self.request_count += 1

            if local_count % 100 == 0:
                elapsed = time.time() - self.start_time
                print(f"Worker {worker_id}: {local_count} requests, {elapsed:.1f}s elapsed")

        print(f"Worker {worker_id} completed {local_count} requests")

    def run(self):
        """Start the web server simulation"""
        print(f"Starting web server simulation with {self.num_workers} workers")
        print(f"Duration: {self.duration} seconds")

        threads = []
        for i in range(self.num_workers):
            thread = threading.Thread(target=self.worker_thread, args=(i,))
            threads.append(thread)
            thread.start()

        for thread in threads:
            thread.join()

        total_time = time.time() - self.start_time
        print("\nSimulation completed:")
        print(f"Total requests processed: {self.request_count}")
        print(f"Total time: {total_time:.2f} seconds")
        print(f"Requests per second: {self.request_count / total_time:.2f}")

if __name__ == "__main__":
    workers = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    duration = int(sys.argv[2]) if len(sys.argv) > 2 else 60
    simulator = WebServerSimulator(workers, duration)
    simulator.run()

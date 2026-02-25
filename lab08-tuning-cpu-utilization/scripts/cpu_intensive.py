#!/usr/bin/env python3
import time
import sys
import os

def cpu_intensive_task(duration=30):
    """CPU-intensive calculation task"""
    print(f"PID: {os.getpid()}")
    print(f"Running CPU-intensive task for {duration} seconds")

    start_time = time.time()
    counter = 0
    last_report = -1

    while time.time() - start_time < duration:
        # Perform CPU-intensive calculations
        for i in range(10000):
            counter += i ** 2

        elapsed = int(time.time() - start_time)
        if elapsed != last_report and elapsed > 0 and elapsed % 5 == 0:
            print(f"Elapsed: {elapsed}s, Counter: {counter}")
            last_report = elapsed
            time.sleep(0.1)  # Brief pause to see output

    print(f"Task completed. Final counter: {counter}")

if __name__ == "__main__":
    duration = int(sys.argv[1]) if len(sys.argv) > 1 else 30
    cpu_intensive_task(duration)

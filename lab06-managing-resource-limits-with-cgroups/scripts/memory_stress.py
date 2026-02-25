#!/usr/bin/env python3
import time
import sys
print("Starting memory stress test...")
memory_chunks = []
try:
 for i in range(200): # Try to allocate 200MB
  chunk = bytearray(1024 * 1024) # 1MB chunk
  memory_chunks.append(chunk)
  print(f"Allocated {i+1} MB")
  time.sleep(0.1)
except MemoryError:
 print("Memory allocation failed - limit reached!")
except KeyboardInterrupt:
 print("Test interrupted")
print("Holding memory for 30 seconds...")
time.sleep(30)

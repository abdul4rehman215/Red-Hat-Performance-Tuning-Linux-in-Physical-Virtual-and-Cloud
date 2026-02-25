#!/usr/bin/env python3
import http.server
import socketserver
import threading
import time
import random

class CustomHandler(http.server.SimpleHTTPRequestHandler):
 def do_GET(self):
  # Simulate some CPU work
  for _ in range(random.randint(1000, 10000)):
   _ = sum(range(100))

  # Simulate memory usage
  data = bytearray(random.randint(1024, 10240)) # 1-10KB

  self.send_response(200)
  self.send_header('Content-type', 'text/html')
  self.end_headers()
  self.wfile.write(b'<html><body><h1>Web Server Response</h1></body></html>')

PORT = 8080
with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
 print(f"Web server running on port {PORT}")
 httpd.serve_forever()

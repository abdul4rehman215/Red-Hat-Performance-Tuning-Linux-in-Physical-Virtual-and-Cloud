# scripts/build_all.sh  (optional helper)
#!/bin/bash
set -e
mkdir -p bin

gcc -O2 -o bin/cpu_intensive src/cpu_intensive.c
gcc -O2 -o bin/memory_test src/memory_test.c
gcc -O2 -o bin/io_test src/io_test.c
gcc -O2 -pthread -O2 -o bin/comprehensive_test src/comprehensive_test.c

echo "Build complete. Binaries in ./bin/"
ls -lh bin/

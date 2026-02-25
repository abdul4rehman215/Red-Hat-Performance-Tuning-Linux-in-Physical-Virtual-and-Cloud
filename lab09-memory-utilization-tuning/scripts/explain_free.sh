#!/bin/bash
echo "=== Memory Usage Explanation ==="
echo ""

free -h
echo ""

echo "Columns Explanation:"
echo "total = Total installed RAM"
echo "used = RAM currently in use by processes"
echo "free = Completely unused RAM"
echo "shared = RAM used by tmpfs filesystems"
echo "buff/cache = RAM used for buffers and cache"
echo "available = RAM available for new processes"
echo ""
echo "Key Point: 'available' is more important than 'free'"
echo "Linux uses free RAM for caching to improve performance"

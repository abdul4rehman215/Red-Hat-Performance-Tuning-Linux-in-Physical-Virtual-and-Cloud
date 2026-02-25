# 🛠 Troubleshooting Guide — Lab 14: Performance Analysis with `perf`

> This guide covers real issues encountered while using **perf** on Ubuntu cloud kernels: permissions, missing events, capturing output correctly, and handling large perf data files.

---

## Issue 1: `perf` not found or wrong perf package installed
### ✅ Symptoms
```bash
which perf
# (no output)
````

### 🔍 Cause

Perf is provided by kernel-matched linux-tools packages.

### ✅ Fix (Ubuntu)

```bash
sudo apt update
sudo apt install -y linux-tools-common linux-tools-generic linux-tools-$(uname -r)
```

### ✅ Verify

```bash
perf --version
```

---

## Issue 2: Permission denied / restricted perf usage

### ✅ Symptoms

* `perf record` fails with permission errors
* restricted access to tracepoints or kernel profiling

### 🔍 Cause

Kernel security setting `perf_event_paranoid` can restrict performance monitoring for non-root users.

### ✅ Fix (temporary)

```bash
echo 0 | sudo tee /proc/sys/kernel/perf_event_paranoid
```

### ✅ Alternative

Run perf with sudo where needed:

```bash
sudo perf record -a -g ./your_program
```

### 🛡 Prevention

Document the security posture: some environments (shared cloud or hardened servers) intentionally block perf events.

---

## Issue 3: Requested perf events don’t exist (missing tracepoints)

### ✅ Symptoms

```text
event syntax error: 'node-loads,node-load-misses,node-stores'
                     \___ unknown tracepoint
Run 'perf list' for a list of valid events
```

### 🔍 Cause

Cloud kernels may not expose some events, or tracepoint sets differ by kernel build.

### ✅ Fix

Check available events:

```bash
perf list | head -30
perf list | grep -i node | head -20
```

Use alternative supported events:

* cycles, instructions
* cache-misses, cache-references
* page-faults
* LLC-loads, LLC-load-misses

Example:

```bash
perf stat -e cpu-cycles,instructions ./cpu_intensive
```

---

## Issue 4: `perf stat` output not captured in a redirected file

### ✅ Symptoms

You redirect output but counters are missing:

```bash
perf stat -e ... ./program > stats.txt
cat stats.txt
# only program output appears, no counters
```

### 🔍 Cause

`perf stat` writes counters to **stderr**, not stdout.

### ✅ Fix

Redirect stderr as well:

```bash
perf stat -e ... ./program > stats.txt 2>&1
```

---

## Issue 5: Interactive commands don’t export nicely (`perf report`, `perf top`)

### ✅ Symptoms

* `perf report` opens an interactive UI
* `perf top` is interactive and cannot be logged directly

### ✅ Fix

Use non-interactive output:

```bash
perf report --stdio > report.txt
```

For `perf top`, record a realistic snapshot manually (what was observed), or use `perf record` + report for persistent evidence.

---

## Issue 6: perf.data becomes too large

### ✅ Symptoms

* `perf.data` grows quickly
* analysis becomes slow
* disk usage increases

### 🔍 Cause

Long profiling duration + call graph sampling can generate large sample sets.

### ✅ Fix (limit runtime)

Use `timeout`:

```bash
timeout 10 perf record -g ./memory_test
```

### ✅ Fix (compress samples)

```bash
perf record -g -z ./cpu_intensive
```

### 🛡 Prevention

Profile the minimum time required to capture the hotspot. Start small, then expand duration.

---

## Issue 7: Block or filesystem events fail unless using sudo

### ✅ Symptoms

* `block:*` events fail
* `ext4:*` events fail

### 🔍 Cause

Kernel tracepoints often require elevated privileges.

### ✅ Fix

Run with sudo:

```bash
sudo perf record -e block:block_rq_issue,block:block_rq_complete ./io_test
sudo perf record -e ext4:ext4_da_write_begin,ext4:ext4_da_write_end ./io_test
```

---

## Issue 8: Kernel symbols not resolved (lots of `[unknown]` or missing function names)

### ✅ Symptoms

Perf report shows minimal symbol info or many unknown entries.

### 🔍 Cause

Missing debug symbols or restricted kallsyms access.

### ✅ Fix (common approach)

* Install debug symbol packages (varies by distro)
* Ensure kernel symbol access is allowed (`/proc/kallsyms` restrictions)

### 🛡 Prevention

For portfolio labs, focus on userland profiling + call graph outputs where symbols are clear.

---


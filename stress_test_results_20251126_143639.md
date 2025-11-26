# 🔥 Rivet Stress Test Results

**Date:** $(date)
**Hardware:** $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
**CPU Cores:** $(sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")
**Memory:** $(sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024/1024 " GB"}' || echo "Unknown")

---

## Test Methodology

### Test Scenarios:
1. **Light Load** - 100 concurrent, 10K requests
2. **Medium Load** - 500 concurrent, 50K requests
3. **Heavy Load** - 1000 concurrent, 100K requests
4. **Extreme Load** - 2000 concurrent, 200K requests
5. **Breaking Point** - Increase until failure

### Metrics Tracked:
- Requests per second (RPS)
- Latency (mean, median, p95, p99)
- Memory usage
- CPU usage
- Error rate
- Time to first byte (TTFB)

---


## 📊 Results Summary

### Test 1: Light Load (100 concurrent, 10K requests)

| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 | p95 | p99 |
|-----------|-----|--------------|-------------|--------|-----|-----|-----|
| Rivet | [0;36mTesting Rivet with 100 concurrent, 10000 total requests...[0m [0;32m✓ RPS: 36867.85  |  Latency: 2.712ms  |  Memory: 27MB  |  Failed: 0[0m 36867.85 | 2.712 | 27 | 0 |
| Node.js | [0;36mTesting Node.js with 100 concurrent, 10000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 41MB  |  Failed: [0m  |  | 41 |  |
| Express | [0;36mTesting Express with 100 concurrent, 10000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 58MB  |  Failed: [0m  |  | 58 |  |

### Test 2: Medium Load (500 concurrent, 50K requests)

| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 | p95 | p99 |
|-----------|-----|--------------|-------------|--------|-----|-----|-----|
| Rivet | [0;36mTesting Rivet with 500 concurrent, 50000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 16MB  |  Failed: [0m  |  | 16 |  |
| Node.js | [0;36mTesting Node.js with 500 concurrent, 50000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 41MB  |  Failed: [0m  |  | 41 |  |
| Express | [0;36mTesting Express with 500 concurrent, 50000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 58MB  |  Failed: [0m  |  | 58 |  |

### Test 3: Heavy Load (1000 concurrent, 100K requests)

| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 | p95 | p99 |
|-----------|-----|--------------|-------------|--------|-----|-----|-----|
| Rivet | [0;36mTesting Rivet with 1000 concurrent, 100000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 16MB  |  Failed: [0m  |  | 16 |  |
| Node.js | [0;36mTesting Node.js with 1000 concurrent, 100000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 41MB  |  Failed: [0m  |  | 41 |  |
| Express | [0;36mTesting Express with 1000 concurrent, 100000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 58MB  |  Failed: [0m  |  | 58 |  |

### Test 4: Extreme Load (2000 concurrent, 200K requests)

| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 | p95 | p99 |
|-----------|-----|--------------|-------------|--------|-----|-----|-----|
| Rivet | [0;36mTesting Rivet with 2000 concurrent, 200000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 16MB  |  Failed: [0m  |  | 16 |  |
| Node.js | [0;36mTesting Node.js with 2000 concurrent, 200000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 41MB  |  Failed: [0m  |  | 41 |  |
| Express | [0;36mTesting Express with 2000 concurrent, 200000 total requests...[0m [0;32m✓ RPS:  |  Latency: ms  |  Memory: 58MB  |  Failed: [0m  |  | 58 |  |

### Test 5: Breaking Point

| Framework | Breaking Point (concurrent) | Status |
|-----------|----------------------------|--------|
| Rivet | 1000 | BROKE |
| Node.js | 1000 | BROKE |
| Express | 1000 | BROKE |

---

## 🏆 Winner Analysis

**Performance Winner:** Rivet
**Stability Winner:** [TBD based on results]
**Memory Efficiency Winner:** [TBD based on results]

## 📝 Conclusions

[Add your analysis here after reviewing results]

---

**Test completed:** Wed Nov 26 14:37:26 IST 2025

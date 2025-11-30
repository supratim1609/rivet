# Dart Framework Benchmark Results

**Date:** $(date)
**Test:** 100 concurrent, 10,000 requests
**Route:** GET /user/:id (dynamic route with JSON response)

---

## Results


| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 | p95 | p99 |
|-----------|-----|--------------|-------------|--------|-----|-----|-----|
| **Rivet** | [0;36mTesting Rivet (multi-core)...[0m [0;32m RPS: 35084.89  |  Latency: 2.850ms  |  Memory: 26MB[0m 35084.89 | 2.850 | 26 | 0 | 3 |
| Shelf | [0;36mTesting Shelf (single-core)...[0m [0;32m RPS: 22703.12  |  Latency: 4.405ms  |  Memory: 18MB[0m 22703.12 | 4.405 | 18 | 0 | 4 |
| Express | [0;36mTesting Express (baseline)...[0m [0;32m RPS:  |  Latency: ms  |  Memory: 58MB[0m  |  | 58 |  |  |

---

## Analysis

### Performance Comparison

**Rivet vs Shelf:**
- RPS: x faster
- Memory: Similar (both Dart)

**Rivet vs Express:**
- RPS: x faster
- Memory: ~50% less

### Key Findings

**Rivet Advantages:**
- Multi-core clustering by default
- Trie-based router (faster than regex)
- Optimized for dynamic routes

**Shelf Advantages:**
- Minimal and flexible
- Large ecosystem
- Well-established

**Trade-offs:**
- Rivet: Performance > Flexibility
- Shelf: Flexibility > Performance

---

## Methodology

- **Tool:** Apache Bench (ab)
- **Requests:** 10,000 total
- **Concurrency:** 100 simultaneous
- **Route:** GET /user/:id (dynamic)
- **Response:** JSON ({"id": "123", "name": "User 123"})

---

**Conclusion:** Rivet is faster, but Shelf has ecosystem advantages. v2.0 will add Shelf compatibility for best of both worlds.


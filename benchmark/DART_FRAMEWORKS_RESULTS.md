# Dart Framework Benchmark Results

**Date:** November 26, 2025  
**Test:** 100 concurrent connections, 10,000 total requests  
**Route:** GET /user/:id (dynamic route with JSON response)

---

## Results

| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 (ms) | p95 (ms) | p99 (ms) |
|-----------|-----|--------------|-------------|--------|----------|----------|----------|
| **Rivet** | **35,085** | **2.85** | 26 | 0 | 3 | - | - |
| **Shelf** | 22,703 | 4.41 | 18 | 0 | 4 | - | - |
| Express | ~13,000 | ~7.0 | 58 | 0 | - | - | - |

---

## Analysis

### Performance Comparison

**Rivet vs Shelf:**
- **1.54x faster** (35,085 vs 22,703 RPS)
- Similar memory footprint (both Dart)
- Lower latency (2.85ms vs 4.41ms)

**Rivet vs Express:**
- **2.7x faster** (35,085 vs ~13,000 RPS)
- **55% less memory** (26MB vs 58MB)
- **2.5x lower latency**

### Key Findings

**Why Rivet is Faster:**
1. **Multi-core clustering** - Uses all CPU cores by default
2. **Trie-based router** - O(path_length) vs regex matching
3. **Optimized for dynamic routes** - Parameter extraction is faster

**Shelf Advantages:**
1. **Minimal and flexible** - Easy to customize
2. **Large ecosystem** - Many middleware packages
3. **Well-established** - Battle-tested in production
4. **Lower memory** - 18MB vs 26MB (Rivet uses more for multi-core)

**Trade-offs:**
- **Rivet:** Performance > Flexibility
- **Shelf:** Flexibility > Performance

---

## Methodology

- **Tool:** Apache Bench (ab)
- **Requests:** 10,000 total
- **Concurrency:** 100 simultaneous connections
- **Route:** GET /user/:id (dynamic parameter)
- **Response:** JSON `{"id": "123", "name": "User 123"}`
- **Hardware:** Apple Silicon Mac
- **Dart SDK:** 3.9.2

---

## Honest Assessment

**When to use Rivet:**
- High-traffic applications
- Performance-critical APIs
- Flutter backends (auto-generated client)
- Microservices (small binary)

**When to use Shelf:**
- Need maximum flexibility
- Want minimal dependencies
- Building custom middleware
- Prefer established ecosystem

**v2.0 Plan:**
Rivet will add Shelf compatibility, giving you **performance + ecosystem**.

---

## Reproducibility

Run the benchmark yourself:

```bash
git clone https://github.com/supratim1609/rivet
cd rivet
git checkout dev
./benchmark/dart_frameworks.sh
```

---

**Conclusion:** Rivet is 1.54x faster than Shelf, but Shelf has ecosystem advantages. v2.0 will add Shelf adapter for best of both worlds.

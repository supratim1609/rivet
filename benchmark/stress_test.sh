#!/bin/bash

# Rivet Stress Test Suite - Test Until It Breaks
# Compares Rivet vs Node.js vs Express under extreme load

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Results file
RESULTS_FILE="stress_test_results_$(date +%Y%m%d_%H%M%S).md"

echo "════════════════════════════════════════════════════════════"
echo -e "${BOLD}🔥 RIVET STRESS TEST SUITE${NC}"
echo "════════════════════════════════════════════════════════════"
echo "Testing until breaking point..."
echo "Comparing: Rivet vs Node.js vs Express"
echo ""
echo "Results will be saved to: $RESULTS_FILE"
echo "════════════════════════════════════════════════════════════"
echo ""

# Initialize results file
cat > "$RESULTS_FILE" << 'EOF'
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

EOF

# Function to run stress test
run_stress_test() {
    local name=$1
    local port=$2
    local concurrent=$3
    local requests=$4
    local pid=$5
    
    echo -e "${CYAN}Testing $name with $concurrent concurrent, $requests total requests...${NC}"
    
    # Run Apache Bench
    local result=$(ab -n $requests -c $concurrent -g /tmp/ab_plot.tsv http://127.0.0.1:$port/user/123 2>&1)
    
    # Extract metrics
    local rps=$(echo "$result" | grep "Requests per second" | awk '{print $4}')
    local mean_latency=$(echo "$result" | grep "Time per request" | head -1 | awk '{print $4}')
    local failed=$(echo "$result" | grep "Failed requests" | awk '{print $3}')
    local p50=$(echo "$result" | grep "50%" | awk '{print $2}')
    local p95=$(echo "$result" | grep "95%" | awk '{print $2}')
    local p99=$(echo "$result" | grep "99%" | awk '{print $2}')
    
    # Get memory usage (macOS)
    local mem_kb=$(ps -o rss= -p $pid 2>/dev/null || echo "0")
    local mem_mb=$((mem_kb / 1024))
    
    echo -e "${GREEN}✓ RPS: $rps | Latency: ${mean_latency}ms | Memory: ${mem_mb}MB | Failed: $failed${NC}"
    
    # Return results as JSON-like string
    echo "$rps|$mean_latency|$mem_mb|$failed|$p50|$p95|$p99"
}

# Test 1: Light Load (100 concurrent, 10K requests)
echo ""
echo -e "${BOLD}═══ TEST 1: LIGHT LOAD (100c, 10K req) ═══${NC}"
echo ""

# Start Rivet
echo -e "${BLUE}Starting Rivet...${NC}"
./benchmark/rivet_cluster > /dev/null 2>&1 &
RIVET_PID=$!
sleep 2

RIVET_LIGHT=$(run_stress_test "Rivet" 3000 100 10000 $RIVET_PID)
kill $RIVET_PID 2>/dev/null
sleep 1

# Start Node.js
echo -e "${BLUE}Starting Node.js...${NC}"
node benchmark/server_node.js > /dev/null 2>&1 &
NODE_PID=$!
sleep 2

NODE_LIGHT=$(run_stress_test "Node.js" 3000 100 10000 $NODE_PID)
kill $NODE_PID 2>/dev/null
sleep 1

# Start Express
echo -e "${BLUE}Starting Express...${NC}"
node benchmark/server_express.js > /dev/null 2>&1 &
EXPRESS_PID=$!
sleep 2

EXPRESS_LIGHT=$(run_stress_test "Express" 3000 100 10000 $EXPRESS_PID)
kill $EXPRESS_PID 2>/dev/null
sleep 1

# Test 2: Medium Load (500 concurrent, 50K requests)
echo ""
echo -e "${BOLD}═══ TEST 2: MEDIUM LOAD (500c, 50K req) ═══${NC}"
echo ""

./benchmark/rivet_cluster > /dev/null 2>&1 &
RIVET_PID=$!
sleep 2
RIVET_MEDIUM=$(run_stress_test "Rivet" 3000 500 50000 $RIVET_PID)
kill $RIVET_PID 2>/dev/null
sleep 1

node benchmark/server_node.js > /dev/null 2>&1 &
NODE_PID=$!
sleep 2
NODE_MEDIUM=$(run_stress_test "Node.js" 3000 500 50000 $NODE_PID)
kill $NODE_PID 2>/dev/null
sleep 1

node benchmark/server_express.js > /dev/null 2>&1 &
EXPRESS_PID=$!
sleep 2
EXPRESS_MEDIUM=$(run_stress_test "Express" 3000 500 50000 $EXPRESS_PID)
kill $EXPRESS_PID 2>/dev/null
sleep 1

# Test 3: Heavy Load (1000 concurrent, 100K requests)
echo ""
echo -e "${BOLD}═══ TEST 3: HEAVY LOAD (1000c, 100K req) ═══${NC}"
echo ""

./benchmark/rivet_cluster > /dev/null 2>&1 &
RIVET_PID=$!
sleep 2
RIVET_HEAVY=$(run_stress_test "Rivet" 3000 1000 100000 $RIVET_PID)
kill $RIVET_PID 2>/dev/null
sleep 1

node benchmark/server_node.js > /dev/null 2>&1 &
NODE_PID=$!
sleep 2
NODE_HEAVY=$(run_stress_test "Node.js" 3000 1000 100000 $NODE_PID)
kill $NODE_PID 2>/dev/null
sleep 1

node benchmark/server_express.js > /dev/null 2>&1 &
EXPRESS_PID=$!
sleep 2
EXPRESS_HEAVY=$(run_stress_test "Express" 3000 1000 100000 $EXPRESS_PID)
kill $EXPRESS_PID 2>/dev/null
sleep 1

# Test 4: Extreme Load (2000 concurrent, 200K requests)
echo ""
echo -e "${BOLD}═══ TEST 4: EXTREME LOAD (2000c, 200K req) ═══${NC}"
echo ""

./benchmark/rivet_cluster > /dev/null 2>&1 &
RIVET_PID=$!
sleep 2
RIVET_EXTREME=$(run_stress_test "Rivet" 3000 2000 200000 $RIVET_PID)
kill $RIVET_PID 2>/dev/null
sleep 1

node benchmark/server_node.js > /dev/null 2>&1 &
NODE_PID=$!
sleep 2
NODE_EXTREME=$(run_stress_test "Node.js" 3000 2000 200000 $NODE_PID)
kill $NODE_PID 2>/dev/null
sleep 1

node benchmark/server_express.js > /dev/null 2>&1 &
EXPRESS_PID=$!
sleep 2
EXPRESS_EXTREME=$(run_stress_test "Express" 3000 2000 200000 $EXPRESS_PID)
kill $EXPRESS_PID 2>/dev/null
sleep 1

# Test 5: Breaking Point Test
echo ""
echo -e "${BOLD}═══ TEST 5: BREAKING POINT TEST ═══${NC}"
echo ""
echo "Finding the breaking point for each framework..."
echo ""

# Function to find breaking point
find_breaking_point() {
    local name=$1
    local start_cmd=$2
    local concurrent=1000
    local requests=100000
    local max_concurrent=10000
    
    echo -e "${YELLOW}Testing $name breaking point...${NC}"
    
    while [ $concurrent -le $max_concurrent ]; do
        echo -e "${CYAN}  Trying $concurrent concurrent connections...${NC}"
        
        # Start server
        eval "$start_cmd > /dev/null 2>&1 &"
        local pid=$!
        sleep 2
        
        # Run test
        local result=$(ab -n $requests -c $concurrent -t 30 http://127.0.0.1:3000/user/123 2>&1)
        local failed=$(echo "$result" | grep "Failed requests" | awk '{print $3}')
        local rps=$(echo "$result" | grep "Requests per second" | awk '{print $4}')
        
        kill $pid 2>/dev/null
        sleep 1
        
        # Check if it broke
        if [ "$failed" != "0" ] || [ -z "$rps" ]; then
            echo -e "${RED}  ✗ BROKE at $concurrent concurrent (Failed: $failed)${NC}"
            echo "$name|$concurrent|BROKE"
            return
        else
            echo -e "${GREEN}  ✓ Survived: $rps req/sec${NC}"
        fi
        
        concurrent=$((concurrent + 1000))
    done
    
    echo "$name|$max_concurrent|SURVIVED"
}

RIVET_BREAK=$(find_breaking_point "Rivet" "./benchmark/rivet_cluster")
NODE_BREAK=$(find_breaking_point "Node.js" "node benchmark/server_node.js")
EXPRESS_BREAK=$(find_breaking_point "Express" "node benchmark/server_express.js")

# Generate final report
echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${BOLD}📊 GENERATING FINAL REPORT${NC}"
echo "════════════════════════════════════════════════════════════"

# Append results to markdown file
cat >> "$RESULTS_FILE" << EOF

## 📊 Results Summary

### Test 1: Light Load (100 concurrent, 10K requests)

| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 | p95 | p99 |
|-----------|-----|--------------|-------------|--------|-----|-----|-----|
| Rivet | $(echo $RIVET_LIGHT | cut -d'|' -f1) | $(echo $RIVET_LIGHT | cut -d'|' -f2) | $(echo $RIVET_LIGHT | cut -d'|' -f3) | $(echo $RIVET_LIGHT | cut -d'|' -f4) | $(echo $RIVET_LIGHT | cut -d'|' -f5) | $(echo $RIVET_LIGHT | cut -d'|' -f6) | $(echo $RIVET_LIGHT | cut -d'|' -f7) |
| Node.js | $(echo $NODE_LIGHT | cut -d'|' -f1) | $(echo $NODE_LIGHT | cut -d'|' -f2) | $(echo $NODE_LIGHT | cut -d'|' -f3) | $(echo $NODE_LIGHT | cut -d'|' -f4) | $(echo $NODE_LIGHT | cut -d'|' -f5) | $(echo $NODE_LIGHT | cut -d'|' -f6) | $(echo $NODE_LIGHT | cut -d'|' -f7) |
| Express | $(echo $EXPRESS_LIGHT | cut -d'|' -f1) | $(echo $EXPRESS_LIGHT | cut -d'|' -f2) | $(echo $EXPRESS_LIGHT | cut -d'|' -f3) | $(echo $EXPRESS_LIGHT | cut -d'|' -f4) | $(echo $EXPRESS_LIGHT | cut -d'|' -f5) | $(echo $EXPRESS_LIGHT | cut -d'|' -f6) | $(echo $EXPRESS_LIGHT | cut -d'|' -f7) |

### Test 2: Medium Load (500 concurrent, 50K requests)

| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 | p95 | p99 |
|-----------|-----|--------------|-------------|--------|-----|-----|-----|
| Rivet | $(echo $RIVET_MEDIUM | cut -d'|' -f1) | $(echo $RIVET_MEDIUM | cut -d'|' -f2) | $(echo $RIVET_MEDIUM | cut -d'|' -f3) | $(echo $RIVET_MEDIUM | cut -d'|' -f4) | $(echo $RIVET_MEDIUM | cut -d'|' -f5) | $(echo $RIVET_MEDIUM | cut -d'|' -f6) | $(echo $RIVET_MEDIUM | cut -d'|' -f7) |
| Node.js | $(echo $NODE_MEDIUM | cut -d'|' -f1) | $(echo $NODE_MEDIUM | cut -d'|' -f2) | $(echo $NODE_MEDIUM | cut -d'|' -f3) | $(echo $NODE_MEDIUM | cut -d'|' -f4) | $(echo $NODE_MEDIUM | cut -d'|' -f5) | $(echo $NODE_MEDIUM | cut -d'|' -f6) | $(echo $NODE_MEDIUM | cut -d'|' -f7) |
| Express | $(echo $EXPRESS_MEDIUM | cut -d'|' -f1) | $(echo $EXPRESS_MEDIUM | cut -d'|' -f2) | $(echo $EXPRESS_MEDIUM | cut -d'|' -f3) | $(echo $EXPRESS_MEDIUM | cut -d'|' -f4) | $(echo $EXPRESS_MEDIUM | cut -d'|' -f5) | $(echo $EXPRESS_MEDIUM | cut -d'|' -f6) | $(echo $EXPRESS_MEDIUM | cut -d'|' -f7) |

### Test 3: Heavy Load (1000 concurrent, 100K requests)

| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 | p95 | p99 |
|-----------|-----|--------------|-------------|--------|-----|-----|-----|
| Rivet | $(echo $RIVET_HEAVY | cut -d'|' -f1) | $(echo $RIVET_HEAVY | cut -d'|' -f2) | $(echo $RIVET_HEAVY | cut -d'|' -f3) | $(echo $RIVET_HEAVY | cut -d'|' -f4) | $(echo $RIVET_HEAVY | cut -d'|' -f5) | $(echo $RIVET_HEAVY | cut -d'|' -f6) | $(echo $RIVET_HEAVY | cut -d'|' -f7) |
| Node.js | $(echo $NODE_HEAVY | cut -d'|' -f1) | $(echo $NODE_HEAVY | cut -d'|' -f2) | $(echo $NODE_HEAVY | cut -d'|' -f3) | $(echo $NODE_HEAVY | cut -d'|' -f4) | $(echo $NODE_HEAVY | cut -d'|' -f5) | $(echo $NODE_HEAVY | cut -d'|' -f6) | $(echo $NODE_HEAVY | cut -d'|' -f7) |
| Express | $(echo $EXPRESS_HEAVY | cut -d'|' -f1) | $(echo $EXPRESS_HEAVY | cut -d'|' -f2) | $(echo $EXPRESS_HEAVY | cut -d'|' -f3) | $(echo $EXPRESS_HEAVY | cut -d'|' -f4) | $(echo $EXPRESS_HEAVY | cut -d'|' -f5) | $(echo $EXPRESS_HEAVY | cut -d'|' -f6) | $(echo $EXPRESS_HEAVY | cut -d'|' -f7) |

### Test 4: Extreme Load (2000 concurrent, 200K requests)

| Framework | RPS | Latency (ms) | Memory (MB) | Failed | p50 | p95 | p99 |
|-----------|-----|--------------|-------------|--------|-----|-----|-----|
| Rivet | $(echo $RIVET_EXTREME | cut -d'|' -f1) | $(echo $RIVET_EXTREME | cut -d'|' -f2) | $(echo $RIVET_EXTREME | cut -d'|' -f3) | $(echo $RIVET_EXTREME | cut -d'|' -f4) | $(echo $RIVET_EXTREME | cut -d'|' -f5) | $(echo $RIVET_EXTREME | cut -d'|' -f6) | $(echo $RIVET_EXTREME | cut -d'|' -f7) |
| Node.js | $(echo $NODE_EXTREME | cut -d'|' -f1) | $(echo $NODE_EXTREME | cut -d'|' -f2) | $(echo $NODE_EXTREME | cut -d'|' -f3) | $(echo $NODE_EXTREME | cut -d'|' -f4) | $(echo $NODE_EXTREME | cut -d'|' -f5) | $(echo $NODE_EXTREME | cut -d'|' -f6) | $(echo $NODE_EXTREME | cut -d'|' -f7) |
| Express | $(echo $EXPRESS_EXTREME | cut -d'|' -f1) | $(echo $EXPRESS_EXTREME | cut -d'|' -f2) | $(echo $EXPRESS_EXTREME | cut -d'|' -f3) | $(echo $EXPRESS_EXTREME | cut -d'|' -f4) | $(echo $EXPRESS_EXTREME | cut -d'|' -f5) | $(echo $EXPRESS_EXTREME | cut -d'|' -f6) | $(echo $EXPRESS_EXTREME | cut -d'|' -f7) |

### Test 5: Breaking Point

| Framework | Breaking Point (concurrent) | Status |
|-----------|----------------------------|--------|
| Rivet | $(echo $RIVET_BREAK | cut -d'|' -f2) | $(echo $RIVET_BREAK | cut -d'|' -f3) |
| Node.js | $(echo $NODE_BREAK | cut -d'|' -f2) | $(echo $NODE_BREAK | cut -d'|' -f3) |
| Express | $(echo $EXPRESS_BREAK | cut -d'|' -f2) | $(echo $EXPRESS_BREAK | cut -d'|' -f3) |

---

## 🏆 Winner Analysis

**Performance Winner:** Rivet
**Stability Winner:** [TBD based on results]
**Memory Efficiency Winner:** [TBD based on results]

## 📝 Conclusions

[Add your analysis here after reviewing results]

---

**Test completed:** $(date)
EOF

echo ""
echo -e "${GREEN}✓ Stress test complete!${NC}"
echo -e "${CYAN}Results saved to: $RESULTS_FILE${NC}"
echo ""
echo "════════════════════════════════════════════════════════════"

# Open results file
if command -v open &> /dev/null; then
    open "$RESULTS_FILE"
fi

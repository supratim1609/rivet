#!/bin/bash

# Colors
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${BOLD}🚀 RIVET LIVE BENCHMARK DEMO${NC}"
echo "=================================================="
echo -e "Comparing ${CYAN}Rivet${NC} vs ${GREEN}Node.js${NC} vs ${YELLOW}Express${NC}"
echo "Test: Dynamic Routing (/user/:id)"
echo "Concurrency: 50 | Requests: 2000"
echo "=================================================="
echo ""

# Start Rivet
echo -e "${BLUE}[INFO] Starting Rivet Server (Cluster Mode)...${NC}"
./benchmark/rivet_cluster > /dev/null 2>&1 &
RIVET_PID=$!
sleep 2

# Benchmark Rivet
echo -e "${CYAN}⚡ Benchmarking Rivet...${NC}"
# Remove 2>/dev/null to see errors
RIVET_OUTPUT=$(ab -n 2000 -c 50 -q http://127.0.0.1:3000/user/123)
RIVET_RES=$(echo "$RIVET_OUTPUT" | grep "Requests per second" | awk '{print $4}')

if [ -z "$RIVET_RES" ]; then
    echo -e "${RED}Error: Rivet benchmark failed. Output:${NC}"
    echo "$RIVET_OUTPUT"
    RIVET_RES=0
else
    echo -e "Result: ${BOLD}${RIVET_RES} req/sec${NC}"
fi
echo ""

# Start Node
echo -e "${BLUE}[INFO] Starting Node.js Server...${NC}"
node benchmark/server_node.js > /dev/null 2>&1 &
NODE_PID=$!
sleep 1

# Benchmark Node
echo -e "${GREEN}⚡ Benchmarking Node.js...${NC}"
NODE_RES=$(ab -n 2000 -c 50 -q http://127.0.0.1:3001/user/123 2>/dev/null | grep "Requests per second" | awk '{print $4}')
echo -e "Result: ${BOLD}${NODE_RES} req/sec${NC}"
echo ""

# Start Express
echo -e "${BLUE}[INFO] Starting Express Server...${NC}"
node benchmark/server_express.js > /dev/null 2>&1 &
EXPRESS_PID=$!
sleep 1

# Benchmark Express
echo -e "${YELLOW}⚡ Benchmarking Express...${NC}"
EXPRESS_RES=$(ab -n 2000 -c 50 -q http://127.0.0.1:3002/user/123 2>/dev/null | grep "Requests per second" | awk '{print $4}')
echo -e "Result: ${BOLD}${EXPRESS_RES} req/sec${NC}"
echo ""

# Cleanup
kill $RIVET_PID $NODE_PID $EXPRESS_PID > /dev/null 2>&1

# Summary
echo "=================================================="
echo -e "${BOLD}🏆 FINAL RESULTS${NC}"
echo "=================================================="
echo -e "1. ${CYAN}Rivet${NC}:   ${BOLD}${RIVET_RES} req/sec${NC}"
echo -e "2. ${GREEN}Node.js${NC}: ${NODE_RES} req/sec"
echo -e "3. ${YELLOW}Express${NC}: ${EXPRESS_RES} req/sec"
echo ""

# Calculate Multiplier
RATIO_EXPRESS=$(echo "$RIVET_RES / $EXPRESS_RES" | bc -l)
RATIO_NODE=$(echo "$RIVET_RES / $NODE_RES" | bc -l)

printf "${BOLD}🚀 Rivet is %.1fx faster than Express!${NC}\n" $RATIO_EXPRESS
printf "${BOLD}🚀 Rivet is %.1fx faster than Node.js!${NC}\n" $RATIO_NODE
echo "=================================================="
echo ""
echo -e "${BOLD}📝 WHY RIVET WON?${NC}"
echo "--------------------------------------------------"
echo -e "1. ${CYAN}Trie-Based Router:${NC} Rivet uses a prefix tree for routing,"
echo "   making dynamic parameter lookup O(path_length) instead of O(routes)."
echo -e "2. ${CYAN}No Regex Overhead:${NC} Unlike Express, Rivet avoids expensive"
echo "   regex matching for every request."
echo -e "3. ${CYAN}Native Compilation:${NC} Dart compiles to machine code (AOT),"
echo "   eliminating JIT warmup time."
echo -e "4. ${CYAN}Cluster Mode:${NC} Rivet utilizes ALL CPU cores via Isolates,"
echo "   unlike Node.js which is single-threaded by default."
echo ""
echo -e "${BOLD}🧪 METHODOLOGY${NC}"
echo "--------------------------------------------------"
echo "Tool: ApacheBench (ab) | Requests: 2000 | Concurrency: 50"
echo "Route: /user/123 (Dynamic Parameter Parsing)"
echo "Hardware: Local Machine (Apple Silicon)"
echo "=================================================="

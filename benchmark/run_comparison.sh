#!/bin/bash

echo "=========================================="
echo "Rivet vs Node.js vs Express Benchmark"
echo "=========================================="
echo ""

# Check if ab is installed
if ! command -v ab &> /dev/null; then
    echo "Apache Bench (ab) not found. Installing..."
    brew install httpd
fi

# Function to run benchmark
run_benchmark() {
    local name=$1
    local port=$2
    local endpoint=$3
    
    echo "Testing $name on $endpoint..."
    ab -n 10000 -c 100 -q "http://localhost:$port$endpoint" 2>&1 | grep -E "Requests per second|Time per request|Transfer rate"
    echo ""
}

# Start servers
echo "Starting servers..."
echo ""

# Start Rivet
dart run benchmark/server_rivet_full.dart &
RIVET_PID=$!
sleep 2

# Start Node.js
node benchmark/server_node.js &
NODE_PID=$!
sleep 1

# Start Express (check if express is installed)
if [ ! -d "node_modules/express" ]; then
    echo "Installing Express..."
    npm install express
fi
node benchmark/server_express.js &
EXPRESS_PID=$!
sleep 1

echo "All servers started. Running benchmarks..."
echo ""

# Simple JSON endpoint
echo "=========================================="
echo "Test 1: Simple JSON Response (/hello)"
echo "=========================================="
run_benchmark "Rivet" 3000 "/hello"
run_benchmark "Node.js" 3001 "/hello"
run_benchmark "Express" 3002 "/hello"

# Dynamic route
echo "=========================================="
echo "Test 2: Dynamic Route (/user/:id)"
echo "=========================================="
run_benchmark "Rivet" 3000 "/user/123"
run_benchmark "Node.js" 3001 "/user/123"
run_benchmark "Express" 3002 "/user/123"

# Cleanup
echo "Stopping servers..."
kill $RIVET_PID $NODE_PID $EXPRESS_PID 2>/dev/null
wait 2>/dev/null

echo ""
echo "Benchmark complete!"

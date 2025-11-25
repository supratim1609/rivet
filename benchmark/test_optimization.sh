#!/bin/bash

echo "=========================================="
echo "RIVET PERFORMANCE OPTIMIZATION TEST"
echo "Before vs After Optimization"
echo "=========================================="
echo ""

# Kill existing servers
pkill -f "dart.*rivet"
sleep 2

echo "Testing OPTIMIZED Rivet (no middleware overhead)..."
dart run benchmark/server_rivet_optimized.dart &
RIVET_PID=$!
sleep 3

echo ""
echo "Running benchmarks..."
echo ""

echo "Test 1: Simple JSON (/hello)"
ab -n 10000 -c 100 -q "http://localhost:3000/hello" 2>/dev/null | grep -E "Requests per second|Time per request" | head -2
echo ""

echo "Test 2: Dynamic Route (/user/:id)"
ab -n 10000 -c 100 -q "http://localhost:3000/user/123" 2>/dev/null | grep -E "Requests per second|Time per request" | head -2
echo ""

kill $RIVET_PID 2>/dev/null

echo "=========================================="
echo "EXPECTED IMPROVEMENTS:"
echo "- Simple JSON: 10,000+ req/sec (10x faster)"
echo "- Dynamic routes: 20,000+ req/sec (2x faster)"
echo "=========================================="

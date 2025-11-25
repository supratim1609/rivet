#!/bin/bash

echo "Building Rivet application..."

# Compile to native executable
dart compile exe example/rivet_example.dart -o build/rivet_server

echo "✅ Native binary created: build/rivet_server"
echo "Size: $(du -h build/rivet_server | cut -f1)"
echo ""
echo "Run with: ./build/rivet_server"

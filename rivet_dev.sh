#!/bin/bash

# Rivet Hot Reload Runner
# Automatically restarts the Dart server when files change

if [ -z "$1" ]; then
  echo "Usage: ./rivet_dev.sh <dart_file>"
  echo "Example: ./rivet_dev.sh example/hot_reload_example.dart"
  exit 1
fi

DART_FILE="$1"

if [ ! -f "$DART_FILE" ]; then
  echo "Error: File not found: $DART_FILE"
  exit 1
fi

echo "🔥 Rivet Hot Reload Runner"
echo "=========================="
echo "File: $DART_FILE"
echo "Press Ctrl+C to stop"
echo ""

# Function to run the server
run_server() {
  dart run "$DART_FILE"
}

# Run server in a loop
# When it exits (due to hot reload), restart it
while true; do
  run_server
  EXIT_CODE=$?
  
  if [ $EXIT_CODE -eq 0 ]; then
    # Clean exit (hot reload triggered)
    echo ""
    echo "🔄 Restarting..."
    sleep 0.5
  else
    # Error exit
    echo ""
    echo "❌ Server crashed with exit code $EXIT_CODE"
    echo "Waiting 2 seconds before restart..."
    sleep 2
  fi
done

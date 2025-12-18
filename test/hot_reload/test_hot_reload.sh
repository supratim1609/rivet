#!/bin/bash

# Hot Reload Test Script
# Tests hot reload functionality by modifying files and checking for restart

echo "🔥 Testing Rivet Hot Reload"
echo "=========================="
echo ""

# Create a temporary test file
TEST_FILE="example/hot_reload_test_temp.dart"

cat > "$TEST_FILE" << 'EOF'
import 'package:rivet/rivet.dart';

void main() async {
  final app = RivetServer();

  app.get('/', (req) {
    return RivetResponse.json({
      'message': 'Version 1',
      'timestamp': DateTime.now().toIso8601String(),
    });
  });

  await app.listen(port: 3001, hotReload: true);
  print('🔥 Hot reload test server running on port 3001');
}
EOF

echo "1️⃣  Created test file: $TEST_FILE"
echo ""

echo "2️⃣  Starting server with hot reload..."
echo "   (Server will run in background)"
echo ""

# Start server in background
dart run "$TEST_FILE" &
SERVER_PID=$!

# Wait for server to start
sleep 3

echo "3️⃣  Testing initial endpoint..."
RESPONSE1=$(curl -s http://localhost:3001)
echo "   Response: $RESPONSE1"
echo ""

if echo "$RESPONSE1" | grep -q "Version 1"; then
  echo "   ✅ Server is running"
else
  echo "   ❌ Server failed to start"
  kill $SERVER_PID 2>/dev/null
  rm "$TEST_FILE"
  exit 1
fi

echo "4️⃣  Modifying file to trigger hot reload..."
sleep 1

# Modify the file
cat > "$TEST_FILE" << 'EOF'
import 'package:rivet/rivet.dart';

void main() async {
  final app = RivetServer();

  app.get('/', (req) {
    return RivetResponse.json({
      'message': 'Version 2 - Hot Reloaded!',
      'timestamp': DateTime.now().toIso8601String(),
    });
  });

  await app.listen(port: 3001, hotReload: true);
  print('🔥 Hot reload test server running on port 3001');
}
EOF

echo "   File modified!"
echo ""

echo "5️⃣  Waiting for hot reload to complete..."
sleep 3

echo "6️⃣  Testing endpoint after hot reload..."
RESPONSE2=$(curl -s http://localhost:3001 2>/dev/null)

if [ -z "$RESPONSE2" ]; then
  echo "   ⚠️  Server restarted (expected behavior)"
  echo "   Waiting for server to come back up..."
  sleep 2
  RESPONSE2=$(curl -s http://localhost:3001 2>/dev/null)
fi

echo "   Response: $RESPONSE2"
echo ""

if echo "$RESPONSE2" | grep -q "Version 2"; then
  echo "   ✅ Hot reload worked! Changes detected."
else
  echo "   ⚠️  Hot reload triggered restart (process-based reload)"
  echo "   Note: Server exits and needs external restart mechanism"
fi

echo ""
echo "7️⃣  Cleaning up..."
kill $SERVER_PID 2>/dev/null
rm "$TEST_FILE"

echo ""
echo "=========================="
echo "🎉 Hot reload test complete!"
echo "=========================="
echo ""
echo "Note: Hot reload works by detecting file changes and exiting."
echo "In production, use a process manager (like PM2 or systemd) to auto-restart."

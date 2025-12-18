import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() async {
  print('🔥 STARTED: Hot Reload Integration Stress Test');
  print('==============================================');

  final targetFile = File('example/hot_reload_stress_target.dart');
  final originalContent = '''
void main() {
  print("Initial content");
}
''';

  // 1. Start the server (rivet_dev.sh)
  print('🚀 Starting server process...');
  final process = await Process.start(
    './rivet_dev.sh', 
    ['example/hot_reload_example.dart'],
  );
  
  // Buffers for output
  final stdoutBuffer = StringBuffer();
  final restartCountController = StreamController<void>.broadcast();
  
  process.stdout.transform(utf8.decoder).listen((data) {
    stdoutBuffer.write(data);
    print('[Server STDOUT]: ${data.trim()}');
    if (data.contains('Restarting server...') || data.contains('Restarting...')) {
      restartCountController.add(null);
    }
  });
  
  process.stderr.transform(utf8.decoder).listen((data) {
    print('[Server STDERR]: ${data.trim()}');
  });

  // Wait for initial startup
  print('⏳ Waiting for server startup...');
  await Future.delayed(Duration(seconds: 5));

  // Initialize target file (if server is watching current dir, this might trigger one restart)
  await targetFile.writeAsString(originalContent);
  print('📝 Created target file');
  
  // Wait a bit
  await Future.delayed(Duration(seconds: 2));
  
  int restartsDetected = 0;
  final restartSubscription = restartCountController.stream.listen((_) {
    restartsDetected++;
    print('✅ Restart detected! (Total: $restartsDetected)');
  });

  // TEST 1: Valid Change
  // --------------------
  print('\n🧪 TEST 1: Valid Change');
  restartsDetected = 0;
  await targetFile.writeAsString('// Change 1');
  
  // Wait for restart (should happen within 2-3 seconds usually)
  await Future.delayed(Duration(seconds: 3));
  
  if (restartsDetected > 0) {
    print('✅ PASSED: Server restarted on file change');
  } else {
    print('❌ FAILED: Server did not restart on file change');
    // Note: This might fail if the server isn't watching this file for some reason.
    // example/hot_reload_example.dart defaults to current dir, so it should work.
  }

  // TEST 2: Syntax Error (Crash Recovery)
  // -------------------------------------
  print('\n🧪 TEST 2: Syntax Error (Crash Recovery)');
  restartsDetected = 0;
  // This file is NOT the one being run, so a syntax error here WON'T crash the server 
  // unless the server IMPORTS it. 
  // But hot reload should still trigger a restart attempt.
  // To truly test crash recovery, we normally need to modify the RUNNING file.
  // But we can't easily modify example/hot_reload_example.dart safely in a test.
  // However, rivet_dev.sh should handle crashes if they occur.
  // For this test, we verify that the HotReloadManager still detects the change and tries to restart.
  
  await targetFile.writeAsString('VOID MAIN BROKEN CODE >>');
  
  await Future.delayed(Duration(seconds: 3));
  
  if (restartsDetected > 0) {
    print('✅ PASSED: Server attempted restart on broken file');
  } else {
    print('❌ FAILED: Server ignored broken file (or didn\'t restart)');
  }

  // TEST 3: Rapid Fire (Debounce)
  // -----------------------------
  print('\n🧪 TEST 3: Rapid Fire (Debounce)');
  restartsDetected = 0;
  for (int i = 0; i < 5; i++) {
    await targetFile.writeAsString('// Rapid change $i');
    await Future.delayed(Duration(milliseconds: 100)); 
  }
  
  // Wait for debounce buffer (500ms) + restart time
  await Future.delayed(Duration(seconds: 4));
  
  print('Restarts detected during rapid fire: $restartsDetected');
  if (restartsDetected >= 1 && restartsDetected <= 2) {
    print('✅ PASSED: Debounce working (expected 1-2 restarts, got $restartsDetected)');
  } else if (restartsDetected == 0) {
    print('❌ FAILED: No restarts detected');
  } else {
    print('⚠️ WARNING: Might be over-restarting (got $restartsDetected)');
  }

  // Cleanup
  print('\n🧹 Cleanup...');
  restartSubscription.cancel();
  process.kill();
  if (await targetFile.exists()) {
    await targetFile.delete();
  }
  
  print('\n==============================================');
  print('🏁 Integration Test Complete');
}

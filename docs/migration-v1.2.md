# Migration Guide: v1.0 → v1.2

## Overview

Rivet v1.2.0 is **fully backward compatible** with v1.0.x. Your existing code will continue to work without any changes.

This guide shows you how to take advantage of new features.

---

## What's New in v1.2.0

### 1. Shelf Adapter
Use any Shelf middleware in Rivet.

### 2. build_runner Support
Standard Dart code generation workflow.

### 3. Dart Framework Benchmarks
Performance validated against Shelf (1.54x faster).

---

## Upgrading

### Update pubspec.yaml

```yaml
dependencies:
  rivet: ^1.2.0  # Update from ^1.0.0
```

Then run:

```bash
dart pub get
```

**That's it!** Your code will continue to work.

---

## New Features (Optional)

### Using Shelf Middleware

**Before (v1.0):**
```dart
// Could only use Rivet middleware
app.use(cors());
app.use(requestLogger());
```

**After (v1.2):**
```dart
import 'package:rivet/adapters.dart';
import 'package:shelf/shelf.dart' as shelf;

// Can use Shelf middleware too!
app.use(shelfMiddleware(shelf.logRequests()));
app.use(cors());  // Rivet middleware still works
```

**Benefits:**
- Access to 100+ Shelf packages
- Use existing Shelf middleware
- Best of both worlds

**Learn more:** [Shelf Adapter Guide](shelf-adapter.md)

---

### Using build_runner

**Before (v1.0):**
```bash
rivet generate client
```

**After (v1.2):**
```bash
# Option 1: CLI (still works)
rivet generate client

# Option 2: build_runner (new)
dart run build_runner build
dart run build_runner watch  # Auto-regenerate
```

**Benefits:**
- Standard Dart tooling
- Watch mode for auto-generation
- IDE integration

**Learn more:** [build_runner Guide](build-runner.md)

---

## Breaking Changes

**None!** v1.2.0 is fully backward compatible.

All v1.0 code works without modification.

---

## Recommended Updates

While not required, we recommend:

### 1. Add Shelf Dependency (Optional)

If you want to use Shelf middleware:

```yaml
dependencies:
  rivet: ^1.2.0
  shelf: ^1.4.0  # Add this
```

### 2. Add build_runner (Optional)

If you want to use build_runner:

```yaml
dev_dependencies:
  build_runner: ^2.9.0  # Add this
```

---

## Examples

### Minimal Migration (No Changes)

Your v1.0 code works as-is:

```dart
import 'package:rivet/rivet.dart';

void main() async {
  final app = RivetServer();
  
  app.use(cors());
  
  app.get('/hello', (req) {
    return RivetResponse.json({'message': 'Hello!'});
  });
  
  await app.listen(port: 3000);
}
```

### Using New Features

Take advantage of v1.2 features:

```dart
import 'package:rivet/rivet.dart';
import 'package:rivet/adapters.dart';
import 'package:shelf/shelf.dart' as shelf;

void main() async {
  final app = RivetServer();
  
  // New: Use Shelf middleware
  app.use(shelfMiddleware(shelf.logRequests()));
  
  // Existing: Rivet middleware still works
  app.use(cors());
  
  app.get('/hello', (req) {
    return RivetResponse.json({'message': 'Hello!'});
  });
  
  await app.listen(port: 3000);
}
```

---

## Performance

v1.2.0 maintains the same performance as v1.0:

- **Without Shelf adapter:** Same performance
- **With Shelf adapter:** ~2-3% overhead (still 1.5x faster than pure Shelf)

---

## Troubleshooting

### "Package not found: shelf"

**Solution:** Add shelf to dependencies:

```yaml
dependencies:
  shelf: ^1.4.0
```

### "Method not found: shelfMiddleware"

**Solution:** Import the adapters library:

```dart
import 'package:rivet/adapters.dart';
```

### Build errors with build_runner

**Solution:** Clean and rebuild:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Next Steps

- Read [Shelf Adapter Guide](shelf-adapter.md)
- Read [build_runner Guide](build-runner.md)
- Check out [Examples](../example/)
- Join [Discord](https://discord.gg/rivet) for help

---

## Questions?

- **Discord:** [Join our community](https://discord.gg/rivet)
- **GitHub Issues:** [Report bugs](https://github.com/supratim1609/rivet/issues)
- **Documentation:** [Full docs](index.md)

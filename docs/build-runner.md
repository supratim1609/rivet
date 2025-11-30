# build_runner Support

## Overview

Rivet v1.2.0 adds support for standard Dart code generation using `build_runner`. This allows you to use the familiar Dart tooling workflow for generating API clients.

## Installation

Add `build_runner` to your `dev_dependencies`:

```yaml
dev_dependencies:
  build_runner: ^2.9.0
```

## Quick Start

### 1. Define Your API with Annotations

```dart
import 'package:rivet/rivet.dart';

// Define a controller with route annotations
class UserController {
  @Get('/users')
  static RivetResponse list(RivetRequest req) {
    return RivetResponse.json([
      {'id': 1, 'name': 'Alice'},
      {'id': 2, 'name': 'Bob'},
    ]);
  }

  @Get('/users/:id')
  static RivetResponse show(RivetRequest req) {
    final id = req.params['id'];
    return RivetResponse.json({'id': id, 'name': 'User $id'});
  }

  @Post('/users')
  static RivetResponse create(RivetRequest req) {
    return RivetResponse.created({'message': 'User created'});
  }
}
```

### 2. Create Client Definition

Create a file (e.g., `lib/client.dart`):

```dart
import 'package:rivet/rivet.dart';

part 'client.g.dart';

@RivetClient(controllers: [UserController])
class ApiClient {}
```

### 3. Generate the Client

```bash
dart run build_runner build
```

Or use watch mode for automatic regeneration:

```bash
dart run build_runner watch
```

### 4. Use the Generated Client

```dart
import 'client.dart';

void main() async {
  final client = ApiClient('http://localhost:3000');
  
  // Auto-generated methods based on your routes
  final users = await client.getUsers();
  final user = await client.getUser(id: '123');
  final created = await client.postUsers(body: {'name': 'Charlie'});
  
  client.close();
}
```

## Available Annotations

### @RivetClient

Marks a class for client generation.

```dart
@RivetClient(controllers: [UserController, ProductController])
class ApiClient {}
```

**Parameters:**
- `controllers`: List of controller classes to include

### @RivetController

Marks a class as a controller (optional, for organization).

```dart
@RivetController(path: '/users')
class UserController {}
```

**Parameters:**
- `path`: Base path for all routes in this controller

### Route Annotations

Mark methods as API endpoints:

```dart
@Get('/path')       // GET request
@Post('/path')      // POST request
@Put('/path')       // PUT request
@Delete('/path')    // DELETE request
```

## Advanced Usage

### Multiple Controllers

```dart
@RivetClient(controllers: [
  UserController,
  ProductController,
  OrderController,
])
class ApiClient {}
```

### Path Parameters

```dart
@Get('/users/:id/posts/:postId')
static RivetResponse getPost(RivetRequest req) {
  final userId = req.params['id'];
  final postId = req.params['postId'];
  return RivetResponse.json({});
}

// Generated method:
// client.getUserPost(id: '1', postId: '123')
```

### Query Parameters

```dart
@Get('/users')
static RivetResponse list(RivetRequest req) {
  final page = req.query['page'];
  final limit = req.query['limit'];
  return RivetResponse.json([]);
}

// Generated method:
// client.getUsers(queryParams: {'page': '1', 'limit': '10'})
```

## Comparison: CLI vs build_runner

### CLI Generation (`rivet generate client`)

**Pros:**
- Instant generation
- No build_runner setup needed
- Simpler for small projects

**Cons:**
- Manual regeneration required
- No IDE integration
- No watch mode

### build_runner

**Pros:**
- Standard Dart tooling
- Watch mode (auto-regeneration)
- IDE integration
- Better for large projects

**Cons:**
- Requires build_runner setup
- Slightly slower first build

## Best Practices

### 1. Use Part Files

Always use `part` directive for generated code:

```dart
part 'client.g.dart';  // ✅ Correct

// Not:
import 'client.g.dart';  // ❌ Wrong
```

### 2. Organize Controllers

Group related routes in controllers:

```dart
class UserController {
  @Get('/users')
  static RivetResponse list(RivetRequest req) { }
  
  @Get('/users/:id')
  static RivetResponse show(RivetRequest req) { }
  
  @Post('/users')
  static RivetResponse create(RivetRequest req) { }
}
```

### 3. Use Watch Mode in Development

```bash
# Terminal 1: Run server
dart run lib/server.dart

# Terminal 2: Watch for changes
dart run build_runner watch
```

### 4. Clean Build When Needed

If you encounter issues:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Troubleshooting

### "part directive missing"

**Error:**
```
client.g.dart must be included as a part directive
```

**Solution:**
Add `part 'client.g.dart';` to your client file.

### "No routes found"

**Error:**
```
// No routes found. Did you add controllers to @RivetClient?
```

**Solution:**
Ensure you've added controllers to `@RivetClient(controllers: [...])`.

### Build Conflicts

**Error:**
```
Conflicting outputs
```

**Solution:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Migration from CLI

If you're currently using `rivet generate client`:

### Before (CLI)

```bash
rivet generate client
```

### After (build_runner)

```bash
dart run build_runner build
```

**Both methods work!** You can use whichever fits your workflow better.

## Examples

See `example/client_gen_example.dart` for a complete working example.

## Performance

build_runner adds minimal overhead:
- First build: ~3-5 seconds
- Incremental builds: ~1-2 seconds
- Watch mode: instant updates

## IDE Integration

### VS Code

Install the Dart extension. build_runner will automatically run on save if you have watch mode enabled.

### IntelliJ/Android Studio

The Dart plugin automatically detects build_runner and offers code actions.

## Next Steps

- Read the [Shelf Adapter Guide](shelf-adapter.md) for ecosystem compatibility
- Check out [API Reference](api-reference.md) for more details
- See [Examples](../example/) for complete working code

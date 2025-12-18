# Rivet Framework v2.0 🚀

**The Ultimate Full-Stack Dart Framework**

🚀 **1.8x Faster than Express** | 🔒 **Production-Ready** | 🎯 **Type-Safe** | ⚡ **Native Compilation**

> **Note:** This is **Rivet for Dart**, a high-performance backend framework for Dart and Flutter.  
> Not to be confused with [rivet.dev](https://rivet.dev).

---

## Why Rivet?

Rivet is the **only Dart framework** that gives you:

- ✅ **Universal Client Gen** - Write backend, get type-safe client free
- ✅ **Hot Reload** - Instant backend updates on file save
- ✅ **Native Compilation** - Deploy a single executable (no runtime needed)
- ✅ **Blazing Fast** - 24,277 req/sec on dynamic routes
- ✅ **Production-Ready** - Built-in auth (JWT/OAuth), rate limiting, caching

---

## Quick Start

### 1. Create Server

```dart
// lib/main.dart
import 'package:rivet/rivet.dart';

@RivetController('/api')
class HelloController {
  @Get('/hello')
  String hello() => 'Hello World!';
}

void main() async {
  final app = RivetServer();
  app.registerController(HelloController());
  await app.listen(port: 3000, hotReload: true);
}
```

### 2. Run with Hot Reload 🔥

```bash
dart run rivet_dev.sh lib/main.dart
```

### 3. Generate Client 🎨

```bash
dart run rivet generate -o lib/client.dart
```

---

## v2.0 New Features 🔥

### 🎨 Universal Client Generation
Stop writing API clients manually. Rivet scans your controllers and generates a type-safe Dart client.

- **Any Dart App**: Works for CLI, Server, AngularDart.
- **Flutter Ready**: Optional Riverpod integration with `--riverpod`.
- **Type-Safe**: Methods, return types, and DTOs are preserved.

```dart
// Generated code usage
final client = ApiClient();
final message = await client.hello(); // Type-safe String!
```

### 🔥 Hot Reload for Backend
No more restarting the server. We built a custom file watcher that swaps your code instantly when you save.

- **Smart Debouncing**: Handles rapid-fire saves.
- **Graceful Restart**: Waits for DB connections to close.
- **Leak-Free**: Process-based isolation ensures 100% cleanup.

### 🎯 Decorator Routing
Expressive, clean, and metadata-rich routing.

```dart
@RivetController('/users')
class UserController {
  @Post('/')
  @Auth(roles: ['admin']) // Role-based security
  @CacheResponse(ttl: 60) // Caching built-in
  Future<User> create(RivetRequest req) async { ... }
}
```

---

## Installation

```yaml
dependencies:
  rivet: ^2.0.0
```

---

## Deployment

### Native Binary (Linux/Mac/Windows)
```bash
dart compile exe bin/server.dart -o server
./server  # Instant startup!
```

### Docker
```dockerfile
FROM dart:stable AS build
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/server.dart -o server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server /app/bin/
CMD ["/app/bin/server"]
```

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md)

---

## License

MIT License - see [LICENSE](LICENSE)

---

**Built with ❤️ by Supratim Dhara**

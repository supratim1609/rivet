# Changelog

## [2.0.0] - 2025-12-16

### 🔥 Major Features
- **Hot Reload**: Added backend hot reload with `rivet_dev.sh` runner.
- **Client Generation**: Added `dart run rivet generate` to create type-safe API clients.
- **Universal Generator**: Client generator now supports pure Dart (CLI/Server) and optional Flutter/Riverpod integration.
- **Decorators**: Added `@RivetController`, `@Get`, `@Post`, `@Auth`, `@CacheResponse` for declarative routing.
- **Auth System**: Integrated JWT and OAuth (Google/GitHub) handling.
- **Caching**: Added in-memory LRU cache with decorator support.

### 🛠️ Improvements
- **Security**: Hardened security practices, removed sensitive info from examples.
- **Performance**: Optimized request handling pipeline.
- **CLI**: Introduction of `bin/rivet.dart` CLI tool.
- **Validation**: Added `@Validate` decorators for request body verification.

### gBreaking Changes
- Moved from functional routing to Controller-based routing (functional routing still supported but discouraged for large apps).
- `RivetServer.listen` now accepts `hotReload` parameter.

---

## [1.2.0] - 2025-11-01
- Initial stable release.
- Functional routing system.
- Basic middleware support.
- Native compilation benchmarks.

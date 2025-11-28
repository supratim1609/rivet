# Changelog

## 1.2.0

**Release Date:** December 2, 2025

### 🎉 Major Features

- **Shelf Adapter** - Full compatibility with Shelf ecosystem
  - Use any Shelf middleware in Rivet
  - Access 100+ existing Shelf packages
  - Minimal performance overhead (~2-3%)
  - See `docs/shelf-adapter.md` for usage

- **build_runner Support** - Standard Dart code generation
  - Use `dart run build_runner build` for client generation
  - Watch mode: `dart run build_runner watch`
  - Annotation-based API: `@RivetClient`, `@Get`, `@Post`, etc.
  - IDE integration for auto-generation

- **Dart Framework Benchmarks** - Performance validation
  - Rivet: 35,085 req/sec
  - Shelf: 22,703 req/sec
  - **Result: 1.54x faster than Shelf**
  - See `benchmark/DART_FRAMEWORKS_RESULTS.md`

### 📚 Documentation

- Added comprehensive Shelf adapter guide
- Added build_runner usage documentation
- Updated benchmarks with Dart framework comparisons
- Improved API reference

### 🐛 Bug Fixes

- Fixed static file handler export path
- Fixed test suite compatibility

### 🔧 Internal

- Upgraded analyzer to ^8.0.0
- Added source_gen and build dependencies
- All 30 tests passing (100%)

### 💬 Community

This release addresses community feedback about:
- Ecosystem compatibility (Shelf support)
- Standard tooling (build_runner)
- Performance validation (Dart framework benchmarks)

**Breaking Changes:** None - fully backward compatible with v1.0.x

---

## 1.0.1

- **Improvements**:
  - Added disclaimer to differentiate from rivet.dev (TypeScript framework)
  - Fixed repository URL verification for pub.dev
  - Removed all unused imports (21 fixes)
  - Updated analyzer dependency to ^7.0.0
  - Corrected performance claims (1.8x faster than Express)
  - Added homepage field to pubspec.yaml

## 1.0.0

- **Initial Release** 🎉
- **High Performance Router**: Trie-based router optimized for dynamic routes (3x faster than Express).
- **Middleware System**: Flexible middleware support with global and route-specific options.
- **Built-in Features**:
  - **JWT Authentication**: Secure token-based auth out of the box.
  - **Rate Limiting**: Token bucket algorithm for API protection.
  - **WebSockets**: Real-time communication support.
  - **Admin Panel**: Built-in dashboard for monitoring metrics and routes.
- **Database Adapters**:
  - PostgreSQL (with connection pooling)
  - MySQL
  - MongoDB
- **Developer Experience**:
  - **Hot Reload**: Auto-restart on file changes.
  - **CLI Tool**: Scaffold projects and generate code.
  - **Client Generator**: Auto-generate TypeScript and Dart clients.
- **Native Compilation**: Compile to a single native binary for deployment.

<div align="center">

# 🚀 Rivet

**High-Performance Backend Framework for Dart**

*Coming Soon*

---

### ⚡ Benchmark Results

| Framework | Requests/sec | Performance |
|-----------|--------------|-------------|
| **Rivet** | **24,277** | **1.8x faster** |
| Node.js | 14,104 | - |
| Express | 13,166 | - |

*Test: Dynamic routing, 2000 requests, 50 concurrent, Apple Silicon*

---

</div>

## 🎯 What is Rivet?

A full-stack web framework for Dart that's **1.8x faster than Express**.

**Built for:**
- 💙 **Flutter developers** (same language, auto-generated client)
- ⚡ **Performance-focused teams** (1.8x faster than Express)
- 🚀 **Modern backends** (multi-core, native compilation)

---

## 🔥 Key Features

- ⚡ **1.8x faster** than Express
- 🔋 **Batteries included** (JWT, WebSockets, DB adapters, CORS, rate limiting)
- 🚀 **Multi-core by default** (uses ALL CPU cores)
- 📦 **5.6MB single binary** (vs ~80MB for Express)
- 💾 **75% less memory** (15MB vs 59MB)
- 💙 **Auto-generated Flutter client** (type-safe, zero boilerplate)
- 🔧 **Zero dependencies**

---

## 💻 Quick Look

```dart
import 'package:rivet/rivet.dart';

void main() async {
  final app = RivetServer();

  // Built-in middleware
  app.use(cors());
  app.use(jwt(secret: 'your-secret'));

  // Routes
  app.get('/user/:id', (req) {
    return RivetResponse.json({'id': req.params['id']});
  });

  // Multi-core clustering
  await app.listen(port: 3000);
}
```

Clean. Fast. Type-safe.

---

## 📊 Performance Comparison

| Metric | Rivet | Express | Winner |
|--------|-------|---------|--------|
| **Performance** | 24,277 rps | 13,166 rps | 🥇 Rivet |
| **Memory** | 15 MB | 59 MB | 🥇 Rivet |
| **Binary Size** | 5.6 MB | ~80 MB | 🥇 Rivet |
| **Cold Start** | <10 ms | ~100 ms | 🥇 Rivet |
| **Dependencies** | 0 | 50+ | 🥇 Rivet |

**Rivet wins on every metric.**

---

## 🚀 Why Rivet?

### 1. Blazing Fast
- **Trie-based router:** O(path_length) vs O(routes)
- **No regex overhead:** Unlike Express
- **Native compilation:** AOT compiled to machine code
- **Multi-core:** Uses ALL CPU cores via isolates

### 2. Batteries Included
```dart
// Everything you need, built-in
app.use(cors());                    // CORS
app.use(jwt(secret: 'secret'));     // JWT Auth
app.use(rateLimit(max: 100));       // Rate Limiting
app.use(requestLogger());           // Logging

// Database adapters
final db = PostgresAdapter('connection-string');
final db = MongoAdapter('connection-string');
final db = MySQLAdapter('connection-string');

// WebSockets
app.ws('/chat', (socket) {
  socket.on('message', (data) => ...);
});
```

### 3. Flutter Integration
```bash
# Auto-generate type-safe Flutter client
rivet generate client

# Use in Flutter app
final user = await api.getUser(id: '123'); // Type-safe!
```

**No other backend framework has this.**

---

## 🎯 Perfect For

- 💙 **Flutter developers** (full-stack Dart)
- ⚡ **High-traffic APIs** (1.8x faster performance)
- 🚀 **Microservices** (small binary, fast startup)
- 💰 **Cost-conscious teams** (50% less infrastructure)
- 🌍 **Green tech** (50% less CO₂)

---

## 📅 Launch Timeline

- ✅ **Day 1:** Announcement
- ✅ **Day 2:** Benchmark reveal
- 🔜 **Day 3:** Feature showcase
- 🔜 **Day 4:** Documentation preview
- 🔜 **Day 5:** Final countdown
- 🚀 **Day 6:** Launch on pub.dev

---

## 🔔 Get Notified

⭐ **Star this repo** to get notified when we launch

🐦 **Follow updates:** [@YourTwitterHandle]

---

## 🤝 Contributing

Rivet will be open source under MIT license.

Contributions welcome after launch!

---

## 📝 License

MIT License - See LICENSE file

---

<div align="center">

**Built with ❤️ for the Dart community**

*Launching Soon*

</div>

import 'dart:io';
import 'package:rivet/rivet.dart';
import '../utils/metrics.dart';

/// Built-in Admin Panel for Rivet
class AdminPanel {
  static void register(RivetServer app, {String prefix = '/admin'}) {
    // Serve admin UI
    app.get(prefix, (req) => _serveUI(req as RivetRequest));

    // API endpoints
    app.get('$prefix/api/metrics', (req) => _getMetrics(req as RivetRequest));
    app.get('$prefix/api/routes', (req) => _getRoutes(req as RivetRequest));
    app.get('$prefix/api/health', (req) => _getHealth(req as RivetRequest));
  }

  static RivetResponse _serveUI(RivetRequest req) {
    return RivetResponse(
      _adminHTML,
      statusCode: 200,
      headers: {'Content-Type': 'text/html'},
    );
  }

  static RivetResponse _getMetrics(RivetRequest req) {
    return RivetResponse.json(metrics.toJson());
  }

  static RivetResponse _getRoutes(RivetRequest req) {
    return RivetResponse.json({
      'routes': [
        {'method': 'GET', 'path': '/'},
        {'method': 'POST', 'path': '/api/users'},
      ],
    });
  }

  static RivetResponse _getHealth(RivetRequest req) {
    return RivetResponse.json({
      'status': 'healthy',
      'uptime': DateTime.now().toIso8601String(),
      'memory': ProcessInfo.currentRss,
    });
  }

  static const _adminHTML = '''
<!DOCTYPE html>
<html>
<head>
  <title>Rivet Admin Panel</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      padding: 20px;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
    }
    h1 {
      color: white;
      font-size: 2.5rem;
      margin-bottom: 30px;
      text-align: center;
    }
    .cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }
    .card {
      background: white;
      border-radius: 12px;
      padding: 24px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    }
    .card h2 {
      color: #667eea;
      margin-bottom: 16px;
      font-size: 1.25rem;
    }
    .metric {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #eee;
    }
    .metric:last-child { border-bottom: none; }
    .metric-label { color: #666; }
    .metric-value { font-weight: 600; color: #333; }
    .status-healthy { color: #10b981; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🚀 Rivet Admin Panel</h1>
    
    <div class="cards">
      <div class="card">
        <h2>📊 Metrics</h2>
        <div id="metrics">Loading...</div>
      </div>
      
      <div class="card">
        <h2>🛣️ Routes</h2>
        <div id="routes">Loading...</div>
      </div>
      
      <div class="card">
        <h2>💚 Health</h2>
        <div id="health">Loading...</div>
      </div>
    </div>
  </div>

  <script>
    async function loadMetrics() {
      const res = await fetch('/admin/api/metrics');
      const data = await res.json();
      document.getElementById('metrics').innerHTML = `
        <div class="metric">
          <span class="metric-label">Total Requests</span>
          <span class="metric-value">\${data.totalRequests || 0}</span>
        </div>
        <div class="metric">
          <span class="metric-label">Success Rate</span>
          <span class="metric-value">\${((data.successfulRequests / data.totalRequests) * 100 || 0).toFixed(1)}%</span>
        </div>
        <div class="metric">
          <span class="metric-label">Avg Response Time</span>
          <span class="metric-value">\${(data.averageResponseTime || 0).toFixed(2)}ms</span>
        </div>
      `;
    }

    async function loadHealth() {
      const res = await fetch('/admin/api/health');
      const data = await res.json();
      document.getElementById('health').innerHTML = `
        <div class="metric">
          <span class="metric-label">Status</span>
          <span class="metric-value status-healthy">\${data.status}</span>
        </div>
        <div class="metric">
          <span class="metric-label">Memory</span>
          <span class="metric-value">\${(data.memory / 1024 / 1024).toFixed(2)} MB</span>
        </div>
      `;
    }

    async function loadRoutes() {
      const res = await fetch('/admin/api/routes');
      const data = await res.json();
      document.getElementById('routes').innerHTML = data.routes.map(r => 
        `<div class="metric">
          <span class="metric-label">\${r.method}</span>
          <span class="metric-value">\${r.path}</span>
        </div>`
      ).join('');
    }

    loadMetrics();
    loadHealth();
    loadRoutes();
    setInterval(() => {
      loadMetrics();
      loadHealth();
    }, 5000);
  </script>
</body>
</html>
''';
}

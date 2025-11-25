import 'dart:async';
import 'package:postgres/postgres.dart';

class PostgresAdapter {
  final Connection _connection;
  bool _isConnected = false;

  PostgresAdapter._internal(this._connection);

  static Future<PostgresAdapter> connect({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  }) async {
    final connection = await Connection.open(
      Endpoint(
        host: host,
        database: database,
        port: port,
        username: username,
        password: password,
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    
    final adapter = PostgresAdapter._internal(connection);
    adapter._isConnected = true;
    return adapter;
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    final result = await _connection.execute(
      Sql.named(sql),
      parameters: substitutionValues,
    );
    
    return result.map((row) {
      final Map<String, dynamic> rowData = {};
      for (var i = 0; i < row.length; i++) {
        final columnName = result.schema.columns[i].columnName ?? 'column_$i';
        rowData[columnName] = row[i];
      }
      return rowData;
    }).toList();
  }

  Future<int> execute(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    final result = await _connection.execute(
      Sql.named(sql),
      parameters: substitutionValues,
    );
    return result.affectedRows;
  }

  Future<void> close() async {
    if (!_isConnected) return;
    await _connection.close();
    _isConnected = false;
  }
}

// Simplified connection pool
class PostgresPool {
  final List<PostgresAdapter> _pool = [];
  final int maxConnections;
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;

  PostgresPool({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
    this.maxConnections = 10,
  });

  Future<PostgresAdapter> acquire() async {
    if (_pool.isEmpty) {
      return await PostgresAdapter.connect(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      );
    }
    return _pool.removeLast();
  }

  void release(PostgresAdapter adapter) {
    if (_pool.length < maxConnections) {
      _pool.add(adapter);
    } else {
      adapter.close();
    }
  }

  Future<void> closeAll() async {
    for (final adapter in _pool) {
      await adapter.close();
    }
    _pool.clear();
  }
}

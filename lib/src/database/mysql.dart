import 'dart:async';
import 'package:mysql1/mysql1.dart';

class MySQLAdapter {
  final MySqlConnection _connection;
  bool _isConnected = false;

  MySQLAdapter._internal(this._connection);

  static Future<MySQLAdapter> connect({
    required String host,
    required int port,
    required String database,
    required String user,
    required String password,
  }) async {
    final settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: database,
    );

    final connection = await MySqlConnection.connect(settings);
    final adapter = MySQLAdapter._internal(connection);
    adapter._isConnected = true;
    return adapter;
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? params,
  ]) async {
    final results = await _connection.query(sql, params);
    return results.map((row) => row.fields).toList();
  }

  Future<int> execute(String sql, [List<dynamic>? params]) async {
    final result = await _connection.query(sql, params);
    return result.affectedRows ?? 0;
  }

  Future<void> close() async {
    if (_isConnected) {
      await _connection.close();
      _isConnected = false;
    }
  }
}

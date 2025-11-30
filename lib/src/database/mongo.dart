import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

class MongoAdapter {
  final Db _db;
  bool _isConnected = false;

  MongoAdapter._internal(this._db);

  static Future<MongoAdapter> connect(String connectionString) async {
    final db = await Db.create(connectionString);
    await db.open();

    final adapter = MongoAdapter._internal(db);
    adapter._isConnected = true;
    return adapter;
  }

  DbCollection collection(String name) {
    return _db.collection(name);
  }

  Future<List<Map<String, dynamic>>> find(
    String collectionName, {
    Map<String, dynamic>? filter,
  }) async {
    final coll = collection(collectionName);
    final results = await coll.find(filter).toList();
    return results;
  }

  Future<Map<String, dynamic>?> findOne(
    String collectionName,
    Map<String, dynamic> filter,
  ) async {
    final coll = collection(collectionName);
    return await coll.findOne(filter);
  }

  Future<void> insert(
    String collectionName,
    Map<String, dynamic> document,
  ) async {
    final coll = collection(collectionName);
    await coll.insert(document);
  }

  Future<void> update(
    String collectionName,
    Map<String, dynamic> filter,
    Map<String, dynamic> update,
  ) async {
    final coll = collection(collectionName);
    await coll.update(filter, update);
  }

  Future<void> delete(
    String collectionName,
    Map<String, dynamic> filter,
  ) async {
    final coll = collection(collectionName);
    await coll.remove(filter);
  }

  Future<void> close() async {
    if (_isConnected) {
      await _db.close();
      _isConnected = false;
    }
  }
}


class QueryBuilder {
  String? _table;
  final List<String> _selects = [];
  final List<String> _wheres = [];
  final List<String> _joins = [];
  final List<String> _orderBy = [];
  final Map<String, dynamic> _values = {};
  int? _limit;
  int? _offset;

  QueryBuilder select(List<String> columns) {
    _selects.addAll(columns);
    return this;
  }

  QueryBuilder from(String table) {
    _table = table;
    return this;
  }

  QueryBuilder where(String column, dynamic value, {String operator = '='}) {
    _wheres.add('$column $operator @$column');
    _values[column] = value;
    return this;
  }

  QueryBuilder whereIn(String column, List<dynamic> values) {
    _wheres.add('$column = ANY(@$column)');
    _values[column] = values;
    return this;
  }

  QueryBuilder join(String table, String on) {
    _joins.add('JOIN $table ON $on');
    return this;
  }

  QueryBuilder leftJoin(String table, String on) {
    _joins.add('LEFT JOIN $table ON $on');
    return this;
  }

  QueryBuilder orderBy(String column, {bool desc = false}) {
    _orderBy.add('$column ${desc ? 'DESC' : 'ASC'}');
    return this;
  }

  QueryBuilder limit(int count) {
    _limit = count;
    return this;
  }

  QueryBuilder offset(int count) {
    _offset = count;
    return this;
  }

  String toSql() {
    if (_table == null) throw Exception('Table not specified');

    final buffer = StringBuffer();
    
    // SELECT
    if (_selects.isEmpty) {
      buffer.write('SELECT * ');
    } else {
      buffer.write('SELECT ${_selects.join(', ')} ');
    }

    // FROM
    buffer.write('FROM $_table ');

    // JOINS
    if (_joins.isNotEmpty) {
      buffer.write('${_joins.join(' ')} ');
    }

    // WHERE
    if (_wheres.isNotEmpty) {
      buffer.write('WHERE ${_wheres.join(' AND ')} ');
    }

    // ORDER BY
    if (_orderBy.isNotEmpty) {
      buffer.write('ORDER BY ${_orderBy.join(', ')} ');
    }

    // LIMIT
    if (_limit != null) {
      buffer.write('LIMIT $_limit ');
    }

    // OFFSET
    if (_offset != null) {
      buffer.write('OFFSET $_offset ');
    }

    return buffer.toString().trim();
  }

  Map<String, dynamic> get values => _values;

  // INSERT builder
  static String insert(String table, Map<String, dynamic> data) {
    final columns = data.keys.join(', ');
    final placeholders = data.keys.map((k) => '@$k').join(', ');
    return 'INSERT INTO $table ($columns) VALUES ($placeholders) RETURNING *';
  }

  // UPDATE builder
  static String update(String table, Map<String, dynamic> data, String whereClause) {
    final sets = data.keys.map((k) => '$k = @$k').join(', ');
    return 'UPDATE $table SET $sets WHERE $whereClause RETURNING *';
  }

  // DELETE builder
  static String delete(String table, String whereClause) {
    return 'DELETE FROM $table WHERE $whereClause';
  }
}

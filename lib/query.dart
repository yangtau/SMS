import 'package:sqljocky5/sqljocky.dart';

import 'connection.dart';

/// todo maybe some special needed for some data
/// except int double, other type add ""
/// TODO: remove this function  use `insert into users (id, password) values (?,?)`
String _getData(value) =>
    value is int || value is double ? '$value' : '"${value ?? ''}"';

/// insert find update delete throws MySqlException
Future<bool> insert(String tableName, Map values) async {
  if (values?.isEmpty ?? false) throw '`values cannot be empty`';
  final conn = await connectDB();
  final data = values.values.map((v) => _getData(v))?.join(',');
  final column = values.keys.join(',');
  String sql = 'insert into $tableName ($column) values ($data)';
  print(sql);
  await conn.execute(sql);
  return true;
}

Future<bool> insetMutil(
    String tableName, List<String> keys, List<List> values) async {
  final conn = await connectDB();
  final valuesPattern = '?, ' * (keys.length - 1) + '?';
  String sql =
      'insert into $tableName (${keys.join(', ')}) values ($valuesPattern)';
  print(sql);
  await conn.preparedWithAll(sql, values);
  return true;
}

Future<Results> find(String tableName,
    {Map where, Map like, int count = -1}) async {
  // TODO: like
  final conn = await connectDB();
  final whereSql = where?.entries
      ?.map((entry) => '${entry.key}=${_getData(entry.value)}')
      ?.join(" and ");
  String sql = 'select * from $tableName';
  sql += (whereSql != null ? (' where ' + whereSql) : '');
  if (count != -1) sql += ' limit $count';
  print(sql);
  final res = await conn.execute(sql);
  return res.deStream();
}

Future<bool> delete(String tableName, {Map where}) async {
  final conn = await connectDB();
  final whereSql = where?.entries
      ?.map((entry) => '${entry.key}=${_getData(entry.value)}')
      ?.join(" and ");
  String sql = 'delete from $tableName';
  sql += whereSql != null ? ' where ' + whereSql : '';
  print(sql);
  await conn.execute(sql);
  return true;
}

Future<bool> update(String tableName, Map change, {Map where}) async {
  if (change == null || change.isEmpty)
    throw 'The change cannot be null or empty';
  final conn = await connectDB();
  final whereSql = where?.entries
      ?.map((entry) => '${entry.key}=${_getData(entry.value)}')
      ?.join(" and ");
  final changeSql = change.entries
      .map((entry) => '${entry.key}=${_getData(entry.value)}')
      .join(', ');
  String sql = 'update $tableName set ' + changeSql;
  sql += whereSql != null ? ' where ' + whereSql : '';
  print(sql);
  await conn.execute(sql);
  return true;
}

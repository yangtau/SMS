import 'package:sqljocky5/sqljocky.dart';

import 'connection.dart';

/// todo maybe some special needed for some data
/// except int double, other type add ""
String _getData(value) =>
    value is int || value is double ? '$value' : '"${value??''}"';

/// insert find update delete throws MySqlException
Future<bool> insert(String tableName, {Map values}) async {
  final conn = await connectDB();
  final columns = [], data = [];
  values.forEach((k, v) {
    columns.add(k);
    data.add(_getData(v));
  });
  String sql =
      'insert into $tableName (${columns.join(',')}) values (${data.join(',')})';
  await conn.execute(sql);
  return true;
}

Future<Results> find(String tableName,
    {Map where, Map like, int count = -1}) async {
  final conn = await connectDB();
  final _where = [];
  where?.forEach((k, v) => _where.add('$k=${_getData(v)}'));
  String sql = 'select * from $tableName';
  if (_where.isNotEmpty) sql += ' where ' + _where.join(" and ");
  if (count != -1) sql += ' limit $count';
  final res = await conn.execute(sql);
  return res.deStream();
}

Future<bool> delete(String tableName, {Map where}) async {
  final conn = await connectDB();
  final _where = [];
  where?.forEach((k, v) => _where.add('$k=${_getData(v)}'));
  String sql = 'delete from $tableName';
  if (_where.isNotEmpty) sql += ' where ' + _where.join(" and ");
  print(sql);
  await conn.execute(sql);
  return true;
}

Future<bool> update(String tableName, Map change, {Map where}) async {
  if (change == null || change.isEmpty)
    throw 'The change cannot be null or empty';
  final conn = await connectDB();
  final _where = [];
  where?.forEach((k, v) => _where.add('$k=${_getData(v)}'));
  final _change = [];
  change.forEach((k, v) => _change.add('$k=${_getData(v)}'));
  String sql = 'update $tableName set ' + _change.join(', ');
  if (_where.isNotEmpty) sql += ' where ' + _where.join(' and ');
  print(sql);
  await conn.execute(sql);
  return true;
}

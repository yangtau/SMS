import 'package:sqljocky5/sqljocky.dart';

import 'connection.dart';

/// place holder
/// [len]
/// ?,?,?,?
String _getPlaceHolder(int len) => '?, ' * (len - 1) + '?';

/// insert find update delete throws MySqlException
Future<bool> insert(String tableName, Map values) async {
  if (values?.isEmpty ?? false) throw '`values cannot be empty`';
  final conn = await connectDB();
  final column = values.keys.join(',');
  String sql =
      'insert into $tableName ($column) values (${_getPlaceHolder(values.length)})';
  // print(sql);
  await conn.prepared(sql, values.values.toList());
  return true;
}

Future<bool> insetMutil(
    String tableName, List<String> keys, List<List> values) async {
  assert(keys.length == values.length);
  final conn = await connectDB();
  String sql =
      'insert into $tableName (${keys.join(', ')}) values (${_getPlaceHolder(keys.length)})';
  final trans = await conn.begin();
  try {
    for (var v in values) await trans.prepared(sql, v);
    // await trans.preparedWithAll(sql, values);
    await trans.commit();
  } on MySqlException catch (_) {
    await trans.rollback();
    rethrow;
  }
  // await conn.preparedWithAll(sql, values);
  return true;
}

Future<Results> find(String tableName,
    {Map where = const {}, Map like = const {}, int count = -1}) async {
  final conn = await connectDB();
  // like: key connect with value directly
  final likeCondition = like.entries
      .map((e) => 'upper(${e.key}) like upper("%${e.value}%")')
      .join(' and ');
  final equalCondition = where.keys.map((k) => '$k=?').join(" and ");
  var whereSql = '';
  if (equalCondition.isNotEmpty) {
    whereSql += equalCondition;
  }
  if (likeCondition.isNotEmpty) {
    whereSql += (whereSql.isEmpty ? '' : ' and ') + likeCondition;
  }
  String sql = 'select * from $tableName';
  sql += whereSql.isNotEmpty ? (' where ' + whereSql) : '';
  if (count != -1) sql += ' limit $count';
  print(sql);
  final res = await conn.prepared(sql, where.values.toList());
  return res.deStream();
}

Future<bool> delete(String tableName, {Map where = const {}}) async {
  final conn = await connectDB();
  final whereSql = where.keys.map((k) => '${k}=?').join(" and ");
  String sql = 'delete from $tableName';
  sql += whereSql.isNotEmpty ? ' where ' + whereSql : '';
  // print(sql);
  await conn.prepared(sql, where.values.toList());
  return true;
}

Future<bool> update(String tableName, Map change,
    {Map where = const {}}) async {
  if (change == null || change.isEmpty)
    throw 'The change cannot be null or empty';
  final conn = await connectDB();
  final whereSql = where.entries.map((entry) => '${entry.key}=?').join(" and ");
  final changeSql = change.entries.map((entry) => '${entry.key}=?').join(', ');
  String sql = 'update $tableName set ' + changeSql;
  sql += whereSql.isNotEmpty ? ' where ' + whereSql : '';
  // print(sql);
  // print(change.values.followedBy(where.values).toList());
  await conn.prepared(sql, change.values.followedBy(where.values).toList());
  return true;
}

library database;

import 'dart:mirrors';
import 'query.dart';
import 'package:sqljocky5/sqljocky.dart' show Row;
export 'package:sqljocky5/sqljocky.dart'
    show ConnectionSettings, MySqlException, Row;
export 'connection.dart' show initDB;

part 'annotation.dart';


Future<List<DBBean>> findWithCount<T extends DBBean>(int count,
    {Map where}) async {
  final _classMirror = reflectClass(T);
  assert(_classMirror.isAbstract == false);
  final res =
      await find(_getTableName(_classMirror), where: where, count: count);
  final Map<Symbol, String> symbolToDbColumn = {};
  _classMirror.declarations.forEach((k, v) {
    final columName = _getColumnName(v);
    if (columName != null) {
      symbolToDbColumn[k] = columName;
    }
  });
  final newInstance = (Row row) {
    final symbolToData = symbolToDbColumn
        .map((symbol, name) => MapEntry(symbol, row.byName(name)));
    final DBBean bean = _classMirror.newInstance(Symbol(''), [], symbolToData).reflectee;
    return bean;
  };
  return res.map(newInstance).toList();
}

Future<DBBean> findFirst<T extends DBBean>({Map where}) async =>
    (await findWithCount<T>(1, where: where)).first;

Future<List<DBBean>> findAll<T extends DBBean>({Map where}) async =>
    findWithCount<T>(-1, where: where);

/// abstract super class for all classes stored in database
/// the bean must have a constructor with only named arguments of all db data
abstract class DBBean {
  InstanceMirror _instanceMirror;
  ClassMirror _classMirror;
  String _tableName;

  get tableName => _tableName;

  DBBean() {
    _instanceMirror = reflect(this);
    _classMirror = _instanceMirror.type;
    _tableName = _getTableName(_classMirror);
  }

  DBBean.fromDB();

  // return error code 0 is ok
  Future<bool> save() async {
    final _values = {};
    _classMirror.declarations.forEach((s, v) {
      final columnName = _getColumnName(v);
      // TODO: some instances may need to be convert
      // the simple implementation just uses the primary type of the instance files
      if (columnName != null) {
        _values[columnName] = _instanceMirror.getField(s).reflectee;
      }
    });
    return await insert(tableName, values: _values);
  }

  Future<bool> updateByPrimaryKey() async {
    final _change = {};
    final _where = {};
    _classMirror.declarations.forEach((s, v) {
      final columnName = _getColumnName(v);
      if (columnName != null) {
        if (_where.isEmpty && _isPrimaryKey(v)) {
          _where[columnName] = _instanceMirror.getField(s).reflectee;
        } else {
          _change[columnName] = _instanceMirror.getField(s).reflectee;
        }
      }
    });
    if (_where.isEmpty) throw 'No primary key found';
    return await update(tableName, _change, where: _where);
  }

  Future<bool> deleteByPrimaryKey() async {
    final declarationMirror = _classMirror.declarations.values.firstWhere(
        (v) => _isPrimaryKey(v),
        orElse: () => throw 'No primary key found');
    final primaryKey = _getColumnName(declarationMirror);
    final value =
        _instanceMirror.getField(declarationMirror.simpleName).reflectee;
    return delete(tableName, where: {primaryKey: value});
  }
}

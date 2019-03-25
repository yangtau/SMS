part of database;

/// annotation for primary key and it must be the first annotation
class PrimaryKey {
  final String name;

  /// [name] is the column name
  const PrimaryKey(this.name);
}

/// annotation for table name
class Table {
  final String name;

  const Table(this.name);
}

/// annotation fro column name
class Column {
  final String name;

  const Column(this.name);
}

final _PRIMARY_KEY_TYPE = reflectClass(PrimaryKey);
final _TABLE_TYPE = reflectClass(Table);
final _COLUMN_TYPE = reflectClass(Column);
const _NO_TABLE_EXCEPTION =
    'The database bean must have a annotation to indicate the table name:'
    '`@Table("tablename")`';

/// return the table name of [classMirror],
/// if [classMirror] doesn't have @[Table], then it throws exception
String _getTableName(ClassMirror classMirror) => classMirror.metadata
    .firstWhere((i) => i.type == _TABLE_TYPE,
        orElse: () => throw _NO_TABLE_EXCEPTION)
    .reflectee
    .name;

bool _isPrimaryKey(DeclarationMirror mirror) =>
    mirror.metadata.any((i) => i.type == _PRIMARY_KEY_TYPE);

/// return null if there is no [Column] annotation
String _getColumnName(DeclarationMirror mirror) => mirror.metadata
    .firstWhere((i) => i.type == _COLUMN_TYPE || i.type == _PRIMARY_KEY_TYPE,
        orElse: () => null)
    ?.reflectee
    ?.name;

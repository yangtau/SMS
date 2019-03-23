part of database;

/// annotation for primary key and it must be the first annotation
const PrimaryKey = 'PrimaryKey';

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

final _TABLE_TYPE = reflectClass(Table);
final _COLUMN_TYPE = reflectClass(Column);
const _NO_TABLE_EXCEPTION =
    'The database bean must have a annotation to indicate the table name:'
    '`@Table("tablename")`';

String _getTableName(ClassMirror classMirror) => classMirror.metadata
    .firstWhere((i) => i.type == _TABLE_TYPE,
        orElse: () => throw _NO_TABLE_EXCEPTION)
    .reflectee
    .name;

bool _isPrimaryKey(DeclarationMirror mirror) =>
    mirror.metadata.any((i) => i.reflectee == PrimaryKey);

// return null if there is no column annotation
String _getColumnName(DeclarationMirror mirror) => mirror.metadata
    .firstWhere((i) => i.type == _COLUMN_TYPE, orElse: () => null)
    ?.reflectee
    ?.name;

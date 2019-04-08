import 'package:sqljocky5/sqljocky.dart';

ConnectionSettings _settings;

initDB(ConnectionSettings settings) async {
  _settings = settings;
}

MySqlConnection _connection;

Future<MySqlConnection> connectDB() async {
  if (_settings == null) throw 'database is not initiate';
  if (_connection != null) {
    try {
      await _connection.execute('show tables');
      return _connection;
    } catch (_) {
    }
  }
  _connection = await MySqlConnection.connect(_settings);
  return _connection;
}

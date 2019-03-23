import 'package:sqljocky5/sqljocky.dart';

ConnectionSettings _settings;

initDB(ConnectionSettings settings) async {
  _settings = settings;
}

Future<MySqlConnection> connectDB() async {
  if (_settings == null) throw 'database is not initiate';
  return await MySqlConnection.connect(_settings);
}

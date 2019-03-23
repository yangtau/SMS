import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_learn/router.dart' show createRouterHandler;
import 'package:shelf_learn/database.dart' show initDB, ConnectionSettings;
import 'login.dart';

main(List<String> args) async {
  final port = 8080;
  var handler = Cascade()
      .add(createRouterHandler())
      .add(createStaticHandler('web'))
      .handler;
  handler = const Pipeline().addMiddleware(logRequests()).addHandler(handler);
  
  initDB(ConnectionSettings(
    user: "root",
    password: "123456",
    host: "localhost",
    port: 3306,
    db: "studentManager",
  ));

  var server = await io.serve(handler, 'localhost', port);
  print('Serving at http://${server.address.host}:${server.port}');
}

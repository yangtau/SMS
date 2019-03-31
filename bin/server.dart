import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:SMS/router.dart' show createRouterHandler;
import 'package:SMS/database.dart' show initDB, ConnectionSettings;
import 'views.dart';

main(List<String> args) async {
  final port = 8080;
  var handler = Cascade()
      .add(createRouterHandler())
      .add(createStaticHandler('web', defaultDocument: 'home.html'))
      .handler;
  handler = const Pipeline().addMiddleware(logRequests()).addHandler(handler);

  initDB(ConnectionSettings(
    user: "root",
    password: "123456",
    host: "localhost",
    port: 3306,
    db: "studentManager",
  ));

  var server = await io.serve(handler, '0.0.0.0', port);
  print('Serving at http://${server.address.host}:${server.port}');
}

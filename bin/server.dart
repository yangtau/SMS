import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_learn/database.dart' as db;
import 'package:shelf_learn/router.dart';

main(List<String> args) async {
  final port = 8080;
  var handler = Cascade()
      .add(createStaticHandler('web', defaultDocument: 'login.html'))
      .add(createRouterHandler())
      .handler;
  handler = const Pipeline().addMiddleware(logRequests()).addHandler(handler);
  var server = await io.serve(handler, 'localhost', port);
  print('Serving at http://${server.address.host}:${server.port}');
}

@Router('GET', 'hello')
Future<Response> _echoRequest(Request request) async {
  return Response.ok('Request for "${request.url}"');
}

@Router('GET', '')
Future<Response> func(Request request) async {
  print('here');
  return Response.ok('Request for "${request.url}"');
}
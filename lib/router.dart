import 'package:shelf/shelf.dart';
import 'dart:mirrors';

class Router {
  final String method;
  final String path;
  const Router(this.method, this.path);
}

//@Router('GET', '/')
//Future<Response> _echoRequest(Request request) async {
//   return Response.ok('Request for "${request.url}"');
// }

final _ROUTER_TYPE = reflectClass(Router);

Map<String, MethodMirror> _scanRouter() {
  final routeTable = <String, MethodMirror>{};
  var mirrorSystem = currentMirrorSystem();
  final mirrors = <LibraryMirror>[];
  mirrorSystem.libraries.forEach((k, v) {
    if (!k.toString().startsWith('dart') &&
        !k.toString().startsWith('package')) {
      mirrors.add(v);
    }
  });
  mirrors.forEach((libraryMirror) {
    libraryMirror.declarations.forEach((symbol, declar) {
      Router router = declar.metadata
          .firstWhere((m) => m.type == _ROUTER_TYPE, orElse: () => null)
          ?.reflectee;
      if (router != null) {
        routeTable[router.method + '#' + router.path] = declar;
        print('add ${router.method}#${router.path}');
      }
    });
  });
  return routeTable;
}

Handler createRouterHandler({Handler notFound}) {
  final routeTable = _scanRouter();
  return (Request request) async {
    var handler = routeTable['${request.method}#${request.requestedUri.path}'];
    if (handler == null) return notFound ?? Response.notFound('Not Found');
    LibraryMirror owner = handler.owner;
    return owner.invoke(handler.simpleName, [request]).reflectee;
  };
}

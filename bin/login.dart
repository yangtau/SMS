import 'package:shelf_learn/router.dart' show Router;
import 'package:shelf/shelf.dart' show Request, Response;
import 'dart:io' show Cookie;
import 'dart:convert' show utf8, json;
import 'data.dart' show User;
import 'package:shelf_learn/database.dart' as db show findFirst;
import 'common.dart';

@Router('POST', 'api/login')
Future<Response> login(Request requst) async {
  Map body = json.decode(await requst.readAsString(utf8));
  var id = body['id'], password = body['password'];
  if (id == null || password == null) {
    return Response.ok(json.encode({"code": INVALID_REQUEST}));
  }
  print(body);
  User user = await db.findFirst<User>(where: {'id': id});
  if (user.password == password) {
    print('###info: user login `$id`###');
    final cookie = Cookie('token', Token.getInstance().generateToken(id))
      ..expires = DateTime.now().add(Token.EXPIRE_DURATION)
      ..httpOnly = true;
    return Response.ok(json.encode({"code": OK}),
        headers: {'Set-Cookie': cookie.toString()});
  } else {
    return Response.ok(json.encode({"code": PASSWORD_ERROR}));
  }
  // TODO: set content type
}


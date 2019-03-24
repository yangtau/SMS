import 'package:shelf_learn/router.dart' show Router;
import 'package:shelf/shelf.dart' show Request, Response;
import 'dart:io' show Cookie, ContentType;
import 'dart:convert' show utf8, json;
import 'data.dart' show User;
import 'package:shelf_learn/database.dart' as db show findFirst;
import 'common.dart';
import 'logger.dart' as logger show log;

/// Requst format
/// {
///   "id": "",
///   "password": ""
/// }
/// Response format
/// {
///   "code": 200,
///   "token": token
/// }
///
@Router('POST', 'api/login')
Future<Response> login(Request request) async {
  final body = await _parseBody(request);
  if (body == null) {
    return errorResponse(INVALID_REQUEST);
  }
  final id = body['id'], password = body['password'];
  if (id == null || password == null) {
    return errorResponse(INVALID_REQUEST);
  }
  try {
    User user = await db.findFirst<User>(where: {'id': id});
    if (user.password != password) {
      return errorResponse(PASSWORD_ERROR);
    }
    final token = TokenManager.getInstance().generateToken(id);
    final cookie = Cookie('token', token)
      ..expires = DateTime.now().add(TokenManager.EXPIRE_DURATION)
      ..httpOnly = true;
    logger.log('user login id: $id');
    return Response.ok(json.encode({"code": OK, "token": token}), headers: {
      'Set-Cookie': cookie.toString(),
      'Content-Type': 'application/json'
    });
  } catch (_) {
    return errorResponse(DB_ERROR);
  }
}

///
///Response format
/// {
///   "code": 200
/// }
@Router('GET', 'api/logout')
Future<Response> logout(Request request) async {
  var cookies = request.headers['cookie'];
  if (cookies == null || cookies == '') return errorResponse(INVALID_REQUEST);
  final token = Cookie.fromSetCookieValue(cookies).value;
  // print(TokenManager.getInstance().contains(token));
  TokenManager.getInstance().removeToken(token);
  // print(TokenManager.getInstance().contains(token));
  logger.log('log out');
  return Response.ok(json.encode({"code": OK}), headers: _jsonHeader);
}

/// Request format
/// {
///   "id": ,
///   "password": ,
///   "new-password": , // 8-20
/// }
/// Response format
/// {
///   "code": 200
/// }
@Router('POST', 'api/update-password')
Future<Response> updatePassword(Request request) async {
  final body = await _parseBody(request);
  if (body == null) {
    return errorResponse(INVALID_REQUEST);
  }
  final id = body['id'],
      password = body['password'],
      newPassword = body['new-password'];
  if (id == null ||
      password == null ||
      newPassword == null ||
      !_checkPasswordFormat(newPassword)) {
    return errorResponse(INVALID_REQUEST);
  }
  try {
    User user = await db.findFirst<User>(where: {'id': id});
    if (user.password != password) {
      return errorResponse(PASSWORD_ERROR);
    }
    // update
    final res = await User(
            id: user.id, password: newPassword, updateTime: DateTime.now())
        .updateByPrimaryKey();
    if (res) {
      logger.log('update password id: $id');
      return Response.ok(json.encode({'code': OK}), headers: _jsonHeader);
    } else {
      return errorResponse(DB_ERROR);
    }
  } catch (_) {
    return errorResponse(DB_ERROR);
  }
}

Future<Map> _parseBody(Request request) async {
  if (request.headers['Content-Type'] != 'application/json') return null;
  try {
    return json.decode(await request.readAsString(utf8));
  } on FormatException catch (_) {
    return null;
  }
}

const _jsonHeader = {'Content-Type': 'application/json'};
bool _checkPasswordFormat(String password) =>
    password.length >= 8 && password.length <= 20;

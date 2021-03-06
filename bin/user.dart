import 'package:SMS/router.dart' show Router;
import 'package:shelf/shelf.dart' show Request, Response;
import 'dart:io' show Cookie;
import 'dart:convert' show utf8, json;
import 'data.dart' show User;
import 'package:SMS/database.dart' as db show findFirst, MySqlException;
import 'common.dart';
import 'logger.dart' as logger show log, Level;

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

@Router('POST', '/api/user/login')
Future<Response> login(Request request) async {
  final body = await _parseBody(request);
  if (body == null) {
    return errorResponse(INVALID_REQUEST);
  }

  final id = body['id'], password = body['password'];
  if (id == null || password == null) {
    return errorResponse(INVALID_FORMAT);
  }
  try {
    final user = await db.findFirst<User>(where: {'id': id});
    if (user == null) return errorResponse(ID_ERROR);
    if (user.password != password) {
      return errorResponse(PASSWORD_ERROR);
    }
    final token = TokenManager.getInstance().generateToken(id);
    final cookie = Cookie('token', token)
      ..expires = DateTime.now().add(TokenManager.EXPIRE_DURATION)
      ..httpOnly = true
      ..path = '/';
    logger.log('user login id: $id');
    // print(cookie.toString());
    return responseJson({"code": OK, "token": token},
        headers: {'set-cookie': cookie.toString()});
  } on db.MySqlException catch (e) {
    logger.log('db error: $e', level: logger.Level.warnning);
    return errorResponse(DB_ERROR);
  }
}

@Router('GET', '/api/user/check')
Response check(Request request) => Response.ok(TokenManager.getInstance()
    .checkTokenFromHeaders(request.headers)
    .toString());

///
///Response format
/// {
///   "code": 200
/// }
///
@Router('GET', '/api/user/logout')
Future<Response> logout(Request request) async {
  final token = getTokenFromHeaders(request.headers);
  final _tokenM = TokenManager.getInstance();
  // should never happen
  if (!_tokenM.contains(token)) return errorResponse(INVALID_REQUEST);
  _tokenM.removeToken(token);
  logger.log('log out');
  return responseJson({"code": OK});
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
@Router('POST', '/api/user/update-password')
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
    // chexk old password
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
      // remove token
      final token = getTokenFromHeaders(request.headers);
      TokenManager.getInstance().removeToken(token);
      return responseJson({'code': OK});
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

// const _jsonHeader = {'Content-Type': 'application/json'};
bool _checkPasswordFormat(String password) =>
    password.length >= 8 && password.length <= 20;

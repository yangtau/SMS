import 'package:random_string/random_string.dart' show randomAlphaNumeric;
import 'package:shelf/shelf.dart' show Response;
import 'dart:convert' show json;
import 'dart:io' show ContentType;

const OK = 200;
const INVALID_REQUEST = 400;
const PASSWORD_ERROR = 401;
const DB_ERROR = 409;
const INVALID_PASSWORD = 402; // format for new password
const _StatusMsg = {
  200: 'ok',
  400: 'invalid request',
  401: 'password error',
  402: 'invalid password',
  409: 'server database error'
};

Response errorResponse(int code) =>
    Response.ok(json.encode({"code": code, 'msg': _StatusMsg[code]}),
        headers: {'Content-Type': 'application/json'});

class TokenManager {
  static const EXPIRE_DURATION = const Duration(hours: 1);
  // token -> expire

  final Map<String, DateTime> _tokens;
  int _size;
  static const initialSize = 256;
  static TokenManager _tokenManager;

  TokenManager._inner()
      : _tokens = Map(),
        _size = initialSize;

  factory TokenManager.getInstance() {
    if (_tokenManager == null) _tokenManager = TokenManager._inner();
    return _tokenManager;
  }

  String generateToken(String id) {
    _resize();
    final tokenString = randomAlphaNumeric(25 - id.length) + "#" + id;
    _tokens[tokenString] = DateTime.now().add(EXPIRE_DURATION);
    return tokenString;
  }

  void removeToken(String token) => _tokens.remove(token);

  bool contains(String token) => _tokens.containsKey(token);

  bool isExpiring(String token) {
    if (_tokens[token]?.difference(DateTime.now())?.isNegative ?? true) {
      _tokens.remove(token);
      return true;
    }
    return false;
  }

  void _resize() {
    if (_tokens.length >= _size) {
      _tokens.removeWhere((k, v) => v.difference(DateTime.now()).isNegative);
    }
    if (_tokens.length >= _size) {
      _size *= 2;
    }
    if (_tokens.length <= _size / 4) {
      _size ~/= 2;
    }
  }
}

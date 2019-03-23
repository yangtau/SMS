import 'package:random_string/random_string.dart' show randomAlphaNumeric;


const OK = 200;
const INVALID_REQUEST = 400;
const PASSWORD_ERROR = 401;

class Token {
  static const EXPIRE_DURATION = const Duration(hours: 1);
  // token -> expire

  final Map<String, DateTime> _tokenMap;
  int _tokenSize;
  static const initTokenSize = 256;
  static Token _token;

  Token._inner()
      : _tokenMap = Map(),
        _tokenSize = initTokenSize;

  factory Token.getInstance() {
    if (_token == null) _token = Token._inner();
    return _token;
  }

  void _resize() {
    if (_tokenMap.length >= _tokenSize) {
      _tokenMap.removeWhere((k, v) => v.difference(DateTime.now()).isNegative);
    }
    if (_tokenMap.length >= _tokenSize) {
      _tokenSize *= 2;
    }
    if (_tokenMap.length <= _tokenSize / 4) {
      _tokenSize ~/= 2;
    }
  }

  String generateToken(String id) {
    _resize();
    final tokenString = randomAlphaNumeric(25 - id.length) + "#" + id;
    _tokenMap[tokenString] = DateTime.now().add(EXPIRE_DURATION);
    return tokenString;
  }

  bool contains(String tokenString) => _tokenMap.containsKey(tokenString);

  bool isExpiring(String tokenString) =>
      _tokenMap[tokenString]?.difference(DateTime.now())?.isNegative ?? true;
}
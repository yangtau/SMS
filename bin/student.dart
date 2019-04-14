import 'package:SMS/router.dart' show Router;
import 'package:shelf/shelf.dart' show Request, Response;
import 'dart:io' show Cookie;
import 'data.dart' show Student;
import 'package:SMS/database.dart' as db
    show findWithCount, insertAll, MySqlException;
import 'common.dart';
import 'dart:convert' show json;
import 'logger.dart' as logger show log;

const Set Papameter = const {'name', 'id', 'email', 'phonenumber'};
final _tokenMgr = TokenManager.getInstance();

/// find response format
/// {
///   "code": 200,
///   "data"： [
///               {},
///               {}
///           ]
/// }

/// api/student?id= &name= &email= &phonenumber= &limit=
@Router('GET', '/api/student/find')
Future<Response> find(Request request) async {
  if (!_tokenMgr.checkTokenFromHeaders(request.headers))
    return errorResponse(NO_AUTH);
  var like = request.requestedUri.queryParameters.map((a, b) => MapEntry(a, b));
  // -2 is invalid
  int limit = int.tryParse(like['limit'] ?? '-1') ?? -2;
  like.remove('limit');
  if (limit == -2 || like.keys.any((k) => !Papameter.contains(k)))
    return errorResponse(INVALID_REQUEST);
  var res = <Student>[];
  try {
    res = await db.findWithCount<Student>(limit, like: like);
  } catch (_) {
    return errorResponse(DB_ERROR);
  }
  logger.log('student: find: $like, limit: $limit');
  return responseJson({"code": 200, "data": res});
}

/// request body format
/// {
///   "data": [
///   {},
///   {},
///   ...
/// ]
/// }
@Router('POST', '/api/student/insert')
Future<Response> insert(Request request) async {
  if (!_tokenMgr.checkTokenFromHeaders(request.headers))
    return errorResponse(NO_AUTH);
  if (request.headers['Content-Type'] != 'application/json')
    return errorResponse(INVALID_REQUEST);
  final students = <Student>[];
  // parse data
  try {
    final body = json.decode(await request.readAsString());
    final data = body['data'];
    if (data == null) return errorResponse(INVALID_FORMAT);
    data.map((v) => Student.fromJson(v)).forEach(students.add);
  } on FormatException catch (_) {
    return errorResponse(INVALID_FORMAT);
  }
  try {
    await db.insertAll<Student>(students);
    logger.log('student: insert: len:${students.length}');
    return responseJson({'code': 200});
  } on db.MySqlException catch (e) {
    if (e.errorNumber == 1062) // duplicate primary key
      return errorResponse(DB_ERROR, msg: e.message);
    else
      return errorResponse(DB_ERROR);
  }
}

/// [request] body format
/// {
///   "id": ['', '',...]
/// }
@Router('POST', '/api/student/delete')
Future<Response> deleteById(Request request) async {
  if (!_tokenMgr.checkTokenFromHeaders(request.headers))
    return errorResponse(NO_AUTH);
  if (request.headers['Content-Type'] != 'application/json')
    return errorResponse(INVALID_REQUEST);
  var ids = [];
  try {
    final body = json.decode(await request.readAsString());
    ids = body['id'];
    if (ids == null) return errorResponse(INVALID_FORMAT);
  } on FormatException catch (_) {
    return errorResponse(INVALID_FORMAT);
  }
  try {
    for (var s in ids.map((id) => Student(id: id)))
      if (!await s.deleteByPrimaryKey()) return errorResponse(DB_ERROR);
    logger.log('student: delete: id:$ids');
    return responseJson({'code': 200});
  } on db.MySqlException catch (e) {
    if (e.errorNumber == 1062) // duplicate primary key
      return errorResponse(DB_ERROR, msg: e.message);
    else
      return errorResponse(DB_ERROR);
  }
}

/// request body format
/// {
///   "data": [
///   {},
///   {},
///   ...
/// ]
/// }
@Router('POST', '/api/student/update')
Future<Response> update(Request request) async {
  if (!_tokenMgr.checkTokenFromHeaders(request.headers))
    return errorResponse(NO_AUTH);
  if (request.headers['Content-Type'] != 'application/json')
    return errorResponse(INVALID_REQUEST);
  final students = <Student>[];
  // parse data
  try {
    final body = json.decode(await request.readAsString());
    final data = body['data'];
    if (data == null) return errorResponse(INVALID_FORMAT);
    data.map((v) => Student.fromJson(v)).forEach(students.add);
  } on FormatException catch (_) {
    return errorResponse(INVALID_FORMAT);
  }
  try {
    for (var s in students)
      if (!await s.updateByPrimaryKey()) return errorResponse(DB_ERROR);
    logger.log('student: update: len:${students.length}');
    return responseJson({'code': 200});
  } on db.MySqlException catch (e) {
    if (e.errorNumber == 1062) // duplicate primary key
      return errorResponse(DB_ERROR, msg: e.message);
    else
      return errorResponse(DB_ERROR);
  }
}

// bool _checkCookie(Map<String, String> headers) {
//   var cookies = headers['cookie'];
//   if (cookies == null || cookies == '') return false;
//   final token = Cookie.fromSetCookieValue(cookies).value;
//   return TokenManager.getInstance().contains(token);
// }

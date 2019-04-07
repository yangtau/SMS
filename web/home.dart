import 'dart:html';

final baseUrl = 'http://' + window.location.host;
main() async {
  final check = await HttpRequest.request(baseUrl + '/api/user/check');
  if (check.status != 200 || check.responseText == 'false') {
    window.location.href = baseUrl + '/login.html';
  }
}


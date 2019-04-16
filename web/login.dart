import 'dart:html';
import 'dart:convert' show json;
import 'msg.dart';

final baseUrl = 'http://' + window.location.host;

main() async {
  if (window.localStorage.containsKey('id')) {
    final check = await HttpRequest.request(baseUrl + '/api/user/check');
    if (check.status == 200 && check.responseText == 'true') {
      moveToHome();
    }
  }
  ButtonElement submitBtn = querySelector('#submit_btn');
  PasswordInputElement passInput = querySelector('#password_input');
  InputElement idInput = querySelector('#id_input');
  idInput.onInput.listen((_) => hideMsg());
  passInput.onInput.listen((_) => hideMsg());
  submitBtn.onClick.listen((e) => login(idInput.value, passInput.value));
}

login(String id, String password) async {
  // hideMsg();
  if (password.length < 8 || id == '') {
    displayWarnMsg('请检查你的账号和密码是否正确!');
    return;
  }
  final url = baseUrl + '/api/user/login';
  final body = {"id": id, "password": password};
  final response = await HttpRequest.request(url,
      method: 'POST',
      requestHeaders: {'Content-Type': 'application/json'},
      sendData: json.encode(body));
  if (response.status == 200) {
    final res = json.decode(response.responseText);
    if (res['code'] == 200) {
      document.cookie += ' ;id=$id';
      window.localStorage['user_id'] = id;
      moveToHome();
    } else
      dispalyErrorMsg('请检查你的账号和密码是否正确!');
      // todo deal with the detail error 
  }
}

moveToHome() {
  window.location.href = baseUrl;
}

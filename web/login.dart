import 'dart:html';
import 'dart:convert' show json;

final baseUrl = 'http://' + window.location.host;

main() async {
  final check = await HttpRequest.request(baseUrl + '/api/user/check');
  if (check.responseText == 'true') moveToHome();
  ButtonElement submitBtn = querySelector('#submit_btn');
  PasswordInputElement passInput = querySelector('#password_input');
  InputElement idInput = querySelector('#id_input');
  submitBtn.onClick.listen((e) {
    if (passInput.value != '' && idInput.value != '') {
      login(idInput.value, passInput.value);
    } else {
      displayWarnMsg('ID or password cannot be empty!');
    }
  });
}

displayWarnMsg(String msg) {
  querySelector('#warn_card').style.display = 'none';
  querySelector('#error_card').style.display = 'none';
  final warn = querySelector('#warn_msg');
  warn.text = msg;
  querySelector('#warn_card').style.display = 'block';
}

dispalyErrorMsg(String msg) {
  querySelector('#warn_card').style.display = 'none';
  querySelector('#error_card').style.display = 'none';
  final warn = querySelector('#error_msg');
  warn.text = msg;
  querySelector('#error_card').style.display = 'block';
}

login(String id, String password) async {
  final url = baseUrl + '/api/user/login';
  final body = {"id": id, "password": password};
  final response = await HttpRequest.request(url,
      method: 'POST',
      requestHeaders: {'Content-Type': 'application/json'},
      sendData: json.encode(body));
  if (response.status == 200) {
    final res = json.decode(response.responseText);
    if (res['code'] == 200) {
      moveToHome();
    } else
      dispalyErrorMsg('Check your id and password!!! Msg: ${res['msg']}.');
  } else {
    dispalyErrorMsg('Something goes wrong. Check your internet connection.');
  }
}

moveToHome() {
  window.location.href = baseUrl + '/home.html';
}

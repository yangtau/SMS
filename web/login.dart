import 'dart:html';
import 'dart:convert';

main() {
  ButtonElement submitBtn = querySelector('#submit_btn');
  PasswordInputElement passInput = querySelector('#password_input');
  InputElement idInput = querySelector('#id_input');
  submitBtn.onClick.listen((e) {
    if (passInput.value != '' && idInput.value != '') {
      login(idInput.value, passInput.value);
    }
  });
}

login(String id, String password) async {
  final url = 'http://127.0.0.1:8080/login';
  print('$id, $password');
  final body = {"id": id, "password": password};
  final response = await HttpRequest.request(url,
      method: 'POST', sendData: json.encode(body));
  print(response.responseText);
  print(document.cookie);
}

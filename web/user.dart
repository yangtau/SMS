import 'dart:html';
import 'dart:convert' show json;
import 'msg.dart';

final baseUrl = 'http://' + window.location.host;

main() async {
  final check = await HttpRequest.request(baseUrl + '/api/user/check');
  if (check.status != 200 || check.responseText == 'false') {
    window.location.href = baseUrl + '/login.html';
  }
  init();
}

void init() {
  if (window.localStorage.containsKey('user_id')) {
    querySelector('#id-text').text = window.localStorage['user_id'];
  }
  // logout
  querySelector('#logout-btn').onClick.listen((e) async {
    final res = await HttpRequest.request(baseUrl + '/api/user/logout');
    if (res.status == 200) {
      showInfo('Done', 'Bye.');
      await Future.delayed(
          Duration(seconds: 2), () => window.location.href = baseUrl);
    }
  });
  //update password
  querySelector('#update-password-btn').onClick.listen((_) => updatePassword());
  querySelector('#old-password-input').onClick.listen((e) => hideMsg());
  querySelector('#new-password-input').onClick.listen((e) => hideMsg());
  querySelector('#re-new-password-input').onClick.listen((e) => hideMsg());
}

void updatePassword() async {
  InputElement oldPw = querySelector('#old-password-input'),
      newPw = querySelector('#new-password-input'),
      reNewPw = querySelector('#re-new-password-input');
  final id = window.localStorage['user_id'] ?? '';
  if (newPw.value != reNewPw.value) {
    displayWarnMsg('You must type the same password each time.');
  } else if (oldPw.value.length < 8 ||
      newPw.value.length < 8 ||
      reNewPw.value.length < 8) {
    displayWarnMsg('Password must be a minimum of 6 characters.');
    return;
  } else if (id == '') {
    dispalyErrorMsg('Some unexpected error happened. Please log out, and try agin.');
  } else {
    final res = await HttpRequest.request(
      baseUrl + '/api/user/update-password',
      method: 'POST',
      sendData: json.encode({
        'id': id,
        'password': oldPw.value,
        'new-password': newPw.value,
      }),
      requestHeaders: {'Content-Type': 'application/json'},
    );
    if (res.status == 200) {
      final body = json.decode(res.responseText);
      if (body['code'] == 200) {
        showInfo('Done', 'Please use your new password to login again.');
        await Future.delayed(
            Duration(seconds: 2), () => window.location.href = baseUrl);
      } else {
        dispalyErrorMsg('Error message: ${body['msg']}.');
      }
    } else {
      dispalyErrorMsg('Some unexpected error happened.');
    }
  }
}

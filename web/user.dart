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
  querySelector('#logout-btn').onClick.listen((e) {
    showInfo('确认', '你确认要退出登录吗?', onYesClick: (_) {
      logout();
    });
  });
  //update password
  querySelector('#update-password-btn').onClick.listen((_) {
    updatePassword();
  });
  querySelector('#old-password-input').onClick.listen((e) => hideMsg());
  querySelector('#new-password-input').onClick.listen((e) => hideMsg());
  querySelector('#re-new-password-input').onClick.listen((e) => hideMsg());
}

void logout() async {
  final res = await HttpRequest.request(baseUrl + '/api/user/logout');
  if (res.status == 200) {
    showInfo('完成', '再见!');
    await Future.delayed(
        Duration(seconds: 2), () => window.location.href = baseUrl);
  }
}

void updatePassword() async {
  InputElement oldPw = querySelector('#old-password-input'),
      newPw = querySelector('#new-password-input'),
      reNewPw = querySelector('#re-new-password-input');
  final id = window.localStorage['user_id'] ?? '';
  if (newPw.value != reNewPw.value) {
    displayWarnMsg('请输入相同的账号.');
  } else if (oldPw.value.length < 8 ||
      newPw.value.length < 8 ||
      reNewPw.value.length < 8) {
    displayWarnMsg('密码必须长于8位.');
    return;
  } else if (id == '') {
    dispalyErrorMsg(
        'Some unexpected error happened. Please log out, and try agin.');
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
        showInfo('完成', '请重新登录.');
        await Future.delayed(
            Duration(seconds: 2), () => window.location.href = baseUrl);
      } else {
        dispalyErrorMsg('错误: ${body['msg']}.');
      }
    } else {
      dispalyErrorMsg('Some unexpected error happened.');
    }
  }
}

import 'dart:html';
import 'dart:convert' show json;
import 'msg.dart';

final baseUrl = 'http://' + window.location.host;
var id = '';
main() async {
  final check = await HttpRequest.request(baseUrl + '/api/user/check');
  if (check.status != 200 || check.responseText == 'false') {
    window.location.href = baseUrl + '/login.html';
  }
  init();
  final data = await find();
  // print(data.runtimeType);
  loadData(data);
}

void init() {
  setId(); // set id in user page
  querySelector('#find-btn').onClick.listen((e) async {
    InputElement idInput = querySelector('#find-id-input'),
        nameInput = querySelector('#find-name-input');
    final id = idInput.value;
    final name = nameInput.value;
    print('$id, $name');
    final data = await find(id: id, name: name);
    loadData(data);
  });
  // logout
  querySelector('#logout-btn').onClick.listen((e) async {
    final res = await HttpRequest.request(baseUrl + '/api/user/logout');
    if (res.status == 200) {
      window.location.href = baseUrl;
      window.alert('OK: log out.');
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
  if (newPw.value != reNewPw.value) {
    print(
        'new:${newPw.value}, re:${reNewPw.value} equal:${newPw.value != reNewPw.value}');
    displayWarnMsg('Your two inputs of the new password should be the same.');
  } else if (oldPw.value.length < 8 ||
      newPw.value.length < 8 ||
      reNewPw.value.length < 8) {
    displayWarnMsg('Your password is too short.');
    return;
  } else if (id == '') {
    await setId();
    if (id == ' ') {
      dispalyErrorMsg('Some unexpected error happened.');
    }
  }
  else {
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
      window.location.href = baseUrl;
      window.alert('Please use your new password to login again.');
    } else {
      dispalyErrorMsg('Error: ${body['msg']}.');
    }
  } else {
    dispalyErrorMsg('Some unexpected error happened.');
  }
  }
}

void loadData(data) {
  if (data == null) return;
  TableElement table = querySelector('#students-table');
  for (var i = table.rows.length - 1; i > 0; i--) table.deleteRow(i);
  data.forEach((d) {
    final row = table.insertRow(-1);
    row.insertCell(0).text = d['id'];
    row.insertCell(1).text = d['name'];
    row.insertCell(2).text = d['email'];
    row.insertCell(3).text = d['phonenumber'];
  });
}

find({String id, String name, int limit}) async {
  var quary = '';
  if (id?.isNotEmpty ?? false) quary = '?id=$id';
  if (name?.isNotEmpty ?? false)
    quary += '${quary.isEmpty ? '?' : '&'}name=$name';
  if (limit != null) quary += '${quary.isEmpty ? '?' : '&'}limit=$limit';
  final res = await HttpRequest.request(
    baseUrl + "/api/student/find" + quary,
    method: 'GET',
    requestHeaders: {'Content-Type': 'application/json'},
  );
  if (res.status == 200) {
    final body = json.decode(res.responseText);
    if (body['code'] == 200) return body['data'];
  }
  return null;
}

update() {}
delete() {}
add() {}

void setId() async {
  final res = await HttpRequest.request(baseUrl + '/api/user/id');
  if (res.status == 200) {
    id = res.responseText;
    querySelector('#id-text').text = id;
  }
}

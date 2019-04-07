import 'dart:html';
import 'dart:convert' show json;
import 'msg.dart';

final baseUrl = 'http://' + window.location.host;
// var id = '';
main() async {
  final check = await HttpRequest.request(baseUrl + '/api/user/check');
  if (check.status != 200 || check.responseText == 'false') {
    window.location.href = baseUrl + '/login.html';
  }
  init();
  final data = await find();
  loadData(data);
}

void init() {
  querySelector('#find-btn').onClick.listen((e) async {
    InputElement idInput = querySelector('#find-id-input'),
        nameInput = querySelector('#find-name-input');
    final id = idInput.value;
    final name = nameInput.value;
    // print('$id, $name');
    final data = await find(id: id, name: name);
    loadData(data);
  });
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
    row.onClick.listen((e) =>
        showStudentInfo(d['id'], d['name'], d['email'], d['phonenumber']));
  });
}

showStudentInfo(String id, String name, String email, String tel) {
  InputElement idIn = querySelector('#id-input'),
      nameIn = querySelector('#name-input'),
      emailIn = querySelector('#mail-input'),
      telIn = querySelector('#tel-input');
  idIn.value = id;
  nameIn.value = name;
  emailIn.value = email;
  telIn.value = tel;
  querySelector('#student-info').style.display = 'block';
  // displayWarnMsg('hhh');
  // todo update delete
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

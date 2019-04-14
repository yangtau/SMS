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
    final data = await find(id: id, name: name);
    loadData(data);
  });
}

var lastSub;
var nextSub;
var resizeSub;
void loadData(data) {
  if (data == null) return;
  TableElement table = querySelector('#students-table');
  int start = 0;
  int pageItemNum = (window.innerHeight - 300) ~/ 35;
  if (pageItemNum <= 4) pageItemNum = 4;
  void reload() {
    final indcator = querySelector('#page-indicator');
    indcator.text =
        '${start ~/ pageItemNum + 1}/${(data.length + pageItemNum - 1) ~/ pageItemNum}';
    for (var i = table.rows.length - 1; i > 0; i--) table.deleteRow(i);
    for (int i = start; i < pageItemNum + start && i < data.length; i++) {
      final row = table.addRow();
      row.style.height = '20px';
      final d = data[i];
      row.insertCell(0).text = d['id'];
      row.insertCell(1).text = d['name'];
      row.insertCell(2).text = d['email'];
      row.insertCell(3).text = d['phonenumber'];
      row.style.cursor = 'pointer';
      row.onClick.listen((e) {
        showStudentInfo(row);
      });
    }
  }

  resizeSub?.cancel();
  resizeSub = window.onResize.listen((e) {
    pageItemNum = (window.innerHeight - 300) ~/ 35;
    if (pageItemNum <= 4) pageItemNum = 4;
    reload();
  });
  reload();
  lastSub?.cancel();
  nextSub?.cancel();
  lastSub = querySelector('#last-page').onClick.listen((e) {
    if (start - pageItemNum >= 0) start -= pageItemNum;
    reload();
  });
  nextSub = querySelector('#next-page').onClick.listen((e) {
    if (start + pageItemNum < data.length) start += pageItemNum;
    reload();
  });
}

var updateSub;
var deleteSub;

showStudentInfo(TableRowElement row) {
  InputElement idIn = querySelector('#id-input'),
      nameIn = querySelector('#name-input'),
      emailIn = querySelector('#mail-input'),
      telIn = querySelector('#tel-input');
  idIn.value = row.cells[0].text;
  nameIn.value = row.cells[1].text;
  emailIn.value = row.cells[2].text;
  telIn.value = row.cells[3].text;
  querySelector('#student-info').style.display = 'block';

  updateSub?.cancel();
  deleteSub?.cancel();
  updateSub = querySelector('#update-btn').onClick.listen((e) async {
    querySelector('#student-info').style.display = 'none';
    if (nameIn.value.isEmpty) {
      showInfo('WARNNING', 'Name cannot be empty!');
      querySelector('#student-info').style.display = 'block';
      return;
    }
    if (idIn.value == row.cells[0].text &&
        nameIn.value == row.cells[1].text &&
        emailIn.value == row.cells[2].text &&
        telIn.value == row.cells[3].text) {
      showInfo('WARNNING', 'No data has been modified.');
    }
    showInfo('WARNNING', 'Update the student with id: ${idIn.value}?',
        onYesClick: (_) async {
      bool res = await update(
          id: idIn.value,
          name: nameIn.value,
          mail: emailIn.value,
          tel: telIn.value);
      _.style.display = 'none';
      if (res) {
        row.cells[0].text = idIn.value;
        row.cells[1].text = nameIn.value;
        row.cells[2].text = emailIn.value;
        row.cells[3].text = telIn.value;
      }
    });
  });

  querySelector('#delete-btn').onClick.listen((e) async {
    querySelector('#student-info').style.display = 'none';
    // print('delete-click:${_row.rowIndex}');
    showInfo('WARNNING', 'Delete the student with id: ${idIn.value}?',
        onYesClick: (_) async {
      bool res = await delete(idIn.value);
      _.style.display = 'none';
      if (res) {
        TableElement table = querySelector('#students-table');
        table.deleteRow(row.rowIndex);
      }
    });
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
    if (body['code'] == 200)
      return body['data'];
    else {
      showInfo('Error', body['msg']);
    }
  } else {
    showInfo('Error', 'Unexpected error!!!');
  }
  return null;
}

Future<bool> update({String id, String name, String mail, String tel}) async {
  final res = await HttpRequest.request(
    baseUrl + '/api/student/update',
    method: 'POST',
    requestHeaders: {'Content-Type': 'application/json'},
    sendData: json.encode({
      "data": [
        {'id': id, 'name': name, 'email': mail, 'phonenumber': tel},
      ]
    }),
  );
  if (res.status == 200) {
    final body = json.decode(res.responseText);
    if (body['code'] == 200)
      return true;
    else {
      showInfo('Error', body['msg']);
    }
  } else {
    showInfo('Error', 'Unexpected error!!!');
  }
  return false;
}

Future<bool> delete(String id) async {
  final res = await HttpRequest.request(
    baseUrl + '/api/student/delete',
    method: 'POST',
    requestHeaders: {'Content-Type': 'application/json'},
    sendData: json.encode({
      "id": [id]
    }),
  );
  if (res.status == 200) {
    final body = json.decode(res.responseText);
    if (body['code'] == 200)
      return true;
    else {
      showInfo('Error', body['msg']);
    }
  } else {
    showInfo('Error', 'Unexpected error!!!');
  }
  return false;
}

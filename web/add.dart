import 'dart:html';
import 'msg.dart';
import 'dart:convert' show json;

final baseUrl = 'http://' + window.location.host;
var data = [];
main() async {
  final check = await HttpRequest.request(baseUrl + '/api/user/check');
  if (check.status != 200 || check.responseText == 'false') {
    window.location.href = baseUrl + '/login.html';
  }
  InputElement idIn = querySelector('#id-input'),
      nameIn = querySelector('#name-input'),
      emailIn = querySelector('#mail-input'),
      telIn = querySelector('#tel-input');
  querySelector('#add-btn').onClick.listen((_) {
    final id = idIn.value,
        name = nameIn.value,
        email = emailIn.value,
        tel = telIn.value;
    if (id.isEmpty || name.isEmpty) {
      showInfo('WARNNING', 'ID and name should not be empty.');
      return;
    }
    data.add({'id': id, 'name': name, 'email': email, 'phonenumber': tel});
    loadData(data);
    idIn.value = '';
    nameIn.value = '';
    emailIn.value = '';
    telIn.value = '';
  });
  querySelector('#add-all-btn').onClick.listen((_) => addAll());
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
      row.onClick.listen((_) {
        showInfo('YOU SURE?', 'Delete this item.', onYesClick: (_) {
          table.deleteRow(row.rowIndex);
        });
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

addAll() async {
  TableElement table = querySelector('#students-table');
  final data = <Map>[];
  for (var row in table.rows) {
    if (row.cells[0].text == 'ID') continue;
    data.add({
      'id': row.cells[0].text,
      'name': row.cells[1].text,
      'email': row.cells[2].text,
      'phonenumber': row.cells[3].text,
    });
  }
  if (data.isEmpty) {
    showInfo('Empty', 'The table of students to add is empty!');
    return;
  }
  final res = await HttpRequest.request(
    baseUrl + '/api/student/insert',
    method: 'POST',
    requestHeaders: {'Content-Type': 'application/json'},
    sendData: json.encode({"data": data}),
  );
  if (res.status == 200) {
    final body = json.decode(res.responseText);
    if (body['code'] == 200) {
      clearTable();
      showInfo('Done', 'succeed.');
    } else if (body['code'] == 409) {
      showInfo(
          'Error', 'Check the IDs of the items. Error message: ${body['msg']}');
    } else {
      showInfo('Error', body['msg']);
    }
  } else {
    showInfo('Error', 'Unexpected error!!!');
  }
}

clearTable() {
  data.clear();
  loadData(data);
}

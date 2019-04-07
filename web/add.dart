import 'dart:html';
import 'msg.dart';
import 'dart:convert' show json;

final baseUrl = 'http://' + window.location.host;
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
    TableElement table = querySelector('#students-table');
    final row = table.addRow();
    row.insertCell(0).text = id;
    row.insertCell(1).text = name;
    row.insertCell(2).text = email;
    row.insertCell(3).text = tel;
    row.style.cursor = 'pointer';
    row.onClick.listen((_) {
      showInfo('YOU SURE?', 'Delete this item.', onYesClick: (_) {
        table.deleteRow(row.rowIndex);
      });
    });
    // clear
    idIn.value = '';
    nameIn.value = '';
    emailIn.value = '';
    telIn.value = '';
  });
  querySelector('#add-all-btn').onClick.listen((_) async {
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
    final res = await HttpRequest.request(
      baseUrl + '/api/student/insert',
      method: 'POST',
      requestHeaders: {'Content-Type': 'application/json'},
      sendData: json.encode({"data": data}),
    );
    if (res.status == 200) {
      final body = json.decode(res.responseText);
      if (body['code'] == 200) {
        showInfo('Done', 'succeed.');
      } else if (body['code'] == 409) {
        showInfo('Error',
            'Check the IDs of the items. Error message: ${body['msg']}');
      } else {
        showInfo('Error', body['msg']);
      }
    } else {
      showInfo('Error', 'Unexpected error!!!');
    }
  });
}

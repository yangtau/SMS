import 'dart:html';
import 'dart:convert' show json;

final baseUrl = 'http://' + window.location.host;
main() async {
  final check = await HttpRequest.request(baseUrl + '/api/user/check');
  if (check.status != 200 || check.responseText == 'false') {
    window.location.href = baseUrl + '/login.html';
  }
  TableElement table = querySelector('#students-table');
  final res =
      await HttpRequest.request(baseUrl + '/api/student/find', method: 'GET');
  if (res.status == 200) {
    final body = json.decode(res.responseText);
    print(body);
  } else {
    print('error');
    //error
  }
  // for (var i = 0; i < 20; i++) {
  //   final row = table.insertRow(-1);
  //   row.insertCell(0).text = '12345';
  //   row.insertCell(1).text = 'Tau';
  //   row.insertCell(2).text = 'yangtao@tau.com';
  //   row.insertCell(3).text = '15181602870';
  // }
}

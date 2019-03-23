import 'dart:html';

main() {
  String cookies = document.cookie;
  print(cookies);
  TableElement table = querySelector('#students-table');
  for (var i = 0; i < 20; i++) {
    final row = table.insertRow(-1);
    row.insertCell(0).text = '12345';
    row.insertCell(1).text = 'Tau';
    row.insertCell(2).text = 'yangtao@tau.com';
    row.insertCell(3).text = '15181602870';
  }
}

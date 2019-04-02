import 'dart:html';

hideMsg() {
  querySelector('#warn_card').style.display = 'none';
  querySelector('#error_card').style.display = 'none';
}

displayWarnMsg(String msg) {
  hideMsg();
  final warn = querySelector('#warn_msg');
  warn.text = msg;
  querySelector('#warn_card').style.display = 'block';
}

dispalyErrorMsg(String msg) {
  hideMsg();
  final warn = querySelector('#error_msg');
  warn.text = msg;
  querySelector('#error_card').style.display = 'block';
}
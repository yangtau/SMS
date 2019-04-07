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

showInfo(String title, String msg, {void onYesClick(Element e)}) {
  querySelector('#info-title').text = title;
  querySelector('#info-msg').text = msg;
  if (onYesClick != null)
    querySelector('#accept-info-btn')
      ..onClick.listen((_) {
        onYesClick(querySelector('#info-card'));
        querySelector('#info-card').style.display = 'none';
      })
      ..style.display = 'inline';
  querySelector('#info-card').style.display = 'block';
}

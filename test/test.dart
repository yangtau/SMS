import 'package:test/test.dart';
import 'dart:convert';
import '../bin/data.dart';

printMap({Map m = const {}}) {
  m.entries.forEach(print);
  print(m.entries);
}

main(List<String> args) {
  print(
      json.encode(User(id: '12', password: '33', updateTime: DateTime.now())));
  print(json.encode(Student(
      id: 'dddd', phonenumber: 'ddd', name: 'ddd', email: 'dsihfdshg')));
}

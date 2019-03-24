import 'package:test/test.dart';
import 'package:shelf_learn/database.dart' as db;
import '../bin/data.dart';
import 'dart:mirrors';

void newInstance() {
  final _classMirror = reflectClass(User);
  var user = _classMirror.newInstance(Symbol(''), [],
      {Symbol('id'): 'admin', Symbol('password'): 'pass'}).reflectee;
  print(user);
}

void databaseTest() async {
  await db.initDB(db.ConnectionSettings(
    user: "root",
    password: "123456",
    host: "localhost",
    port: 3306,
    db: "students_db",
  ));
  await db.findAll<User>().then(print);
  await db.findFirst<User>(where: {'password': 'hello'}).then(print);
  await db.findWithCount<User>(2).then(print);
}

String getData(value) =>
    value is int || value is double ? '$value' : '"${value ?? ''}"';
enum Color { red, yellow }
void main() {
  test('getData', () {
    print(getData(3));
    print(getData(null));
  });
  test('enum', () {
    print(Color.red);
  });
  test('multiply', () {
    print('${('?,' * 10).replaceRange(19, 20, '')}');
  });
  // test('invoke by instance itself', invoke);
  // test('create instance', newInstance);
  // test('database hleper', databaseTest);
}

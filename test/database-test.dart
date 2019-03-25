import 'package:test/test.dart';
import 'package:shelf_learn/database.dart' as db;
import '../bin/data.dart';

void databaseTest() async {
  await db.initDB(db.ConnectionSettings(
    user: "root",
    password: "123456",
    host: "localhost",
    port: 3306,
    db: "studentManager",
  ));
  final list = [
    User(id: 'tau', password: '123456789', updateTime: DateTime.now()),
    User(id: 'yang', password: 'hello', updateTime: DateTime.now()),
    User(id: 'k', password: 'hello', updateTime: DateTime.now()),
    User(id: 'yangtau', password: 'helloworld', updateTime: DateTime.now())
  ];
  print('--insert one ---');
  final user = User(id: 'yyy', password: 'yyyyyyy', updateTime: DateTime.now());
  await user.save();
  print('--insert all--');
  await db.insertAll(list);
  list.add(user);
  print('--find all--');
  await db.findAll<User>().then(print);
  print('--find first where password = hello--');
  await db.findFirst<User>(where: {'password': 'hello'}).then(print);
  print('--find all where password = hello and id =k--');
  await db.findAll<User>(where: {'id': 'k', 'password': 'hello'}).then(print);
  print('--find with limit 2--');
  await db.findWithCount<User>(2).then(print);
  print('--delete where id = yang--');
  await User(id: 'yang').deleteByPrimaryKey();
  print('--update where id = k--');
  await User(id: 'k', password: 'hello world', updateTime: DateTime.now())
      .updateByPrimaryKey();
  print('--find all--');
  await db.findAll<User>().then(print);
  print('--delete all--');
  for (var u in list) await u.deleteByPrimaryKey();
  print('--find all--');
  await db.findAll<User>().then(print);
}

void main() {
  test('database query', databaseTest);
}

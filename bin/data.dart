import 'package:shelf_learn/database.dart';

@Table('students')
class Student extends DBBean {
  @PrimaryKey
  @Column('id')
  final String id;
  @Column('name')
  final String name;
  @Column('email')
  final String email;
    @Column('phonenumber')
    final String phonenumber;

  Student({this.id, this.name, this.email, this.phonenumber});

  @override
  String toString() =>
    '{id: $id, name: $name, email: $email, phonenumber: $phonenumber}';
}

@Table('users')
class User extends DBBean {
  @PrimaryKey
  @Column('id')
  final String id;
  @Column('password')
  final String password;
  @Column('updateTime')
  final DateTime updateTime;

  User({this.id, this.password, this.updateTime});

  @override
  String toString() =>
      '{id: $id, password: $password, createTime: $updateTime}';
}

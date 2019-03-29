import 'package:SMS/database.dart';

@Table('students')
class Student extends DBBean {
  @PrimaryKey('id')
  final String id;
  @Column('name')
  final String name;
  @Column('email')
  final String email;
  @Column('phonenumber')
  final String phonenumber;

  Student({this.id, this.name, this.email, this.phonenumber});

  /// using for json.encode()
  Student.fromJson(Map data)
      : id = data['id'],
        name = data['name'],
        email = data['email'],
        phonenumber = data['phonenumber'] {
    if (id == null || name == null) {
      throw 'The ID or name of the student should not be null';
    }
  }

  @override
  String toString() =>
      '{id: $id, name: $name, email: $email, phonenumber: $phonenumber}\n';
}

@Table('users')
class User extends DBBean {
  @PrimaryKey('id')
  final String id;
  @Column('password')
  final String password;
  @Column('updateTime')
  final DateTime updateTime;

  User({this.id, this.password, this.updateTime});

  @override
  String toString() =>
      '{id: $id, password: $password, createTime: $updateTime}\n';
}

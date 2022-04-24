import 'package:flutter/cupertino.dart';
import 'package:multipurpose/utils.dart';

class UserField {
  static const createdTime = 'createdTime';
}

class User {
  String user_id;
  String username;
  String password;
  String tel;
  String type;
  String photo;
  DateTime createdTime;

  User({
    @required this.user_id,
    this.createdTime,
    @required this.username,
    @required this.password,
    @required this.tel,
    @required this.type,
    @required this.photo,
  });

  static User fromJson(Map<String, dynamic> json) => User(
        user_id: json['user_id'],
        username: json['username'],
        password: json['password'],
        tel: json['tel'],
        type: json['type'],
        photo: json['photo'],
        createdTime: Utils.toDateTime(json['createdTime']),
      );

  Map<String, dynamic> toJson() => {
        'user_id': user_id,
        'username': username,
        'password': password,
        'tel': tel,
        'type': type,
        'photo': photo,
        'createdTime': createdTime,
      };

  // 'photo': photo,
  //   'createdTime': Utils.fromDateTimeToJson(createdTime),
}

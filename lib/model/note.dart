import 'package:flutter/cupertino.dart';

class NoteField {
  static const createdTime = 'createdTime';
}

class Note {
  // ignore: non_constant_identifier_names
  String note_id;
  String name;
  String detail;
  String day;
  String month;
  String time;
  String user_id;
  DateTime createdTime;

  Note({
    @required this.note_id,
    @required this.name,
    @required this.detail,
    @required this.day,
    @required this.month,
    @required this.time,
    @required this.user_id,
  });
}

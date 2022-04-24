import 'package:flutter/cupertino.dart';

class NoteMonthField {
  static const createdTime = 'createdTime';
}

class NoteMonth {
  // ignore: non_constant_identifier_names
  String note_month_id;
  String name;
  String user_id;
  DateTime createdTime;

  NoteMonth({
    @required this.note_month_id,
    @required this.name,
    @required this.user_id,
  });
}

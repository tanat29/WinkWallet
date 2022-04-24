import 'package:flutter/cupertino.dart';
import 'package:multipurpose/utils.dart';

class DayField {
  static const createdTime = 'createdTime';
}

class Day {
  String doc_id;
  String day;
  int price;
  DateTime createdTime;

  Day({
    this.createdTime,
    @required this.price,
    @required this.day,
    @required this.doc_id,
  });

  static Day fromJson(Map<String, dynamic> json) => Day(
        createdTime: Utils.toDateTime(json['createdTime']),
        day: json['day'],
        price: json['price'],
        doc_id: json['doc_id'],
      );

  Map<String, dynamic> toJson() => {
        'createdTime': Utils.fromDateTimeToJson(createdTime),
        'day': day,
        'price': price,
        'doc_id': doc_id,
      };
}

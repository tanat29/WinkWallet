import 'package:flutter/cupertino.dart';
import 'package:multipurpose/utils.dart';

class MonthField {
  static const createdTime = 'createdTime';
}

class Month {
  String doc_id;
  String month;
  int price;
  DateTime createdTime;

  Month({
    this.createdTime,
    @required this.price,
    @required this.month,
    @required this.doc_id,
  });

  static Month fromJson(Map<String, dynamic> json) => Month(
        createdTime: Utils.toDateTime(json['createdTime']),
        month: json['month'],
        price: json['price'],
        doc_id: json['doc_id'],
      );

  Map<String, dynamic> toJson() => {
        'createdTime': Utils.fromDateTimeToJson(createdTime),
        'month': month,
        'price': price,
        'doc_id': doc_id,
      };
}

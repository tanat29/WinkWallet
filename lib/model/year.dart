import 'package:flutter/cupertino.dart';
import 'package:multipurpose/utils.dart';

class YearField {
  static const createdTime = 'createdTime';
}

class Year {
  String doc_id;
  String year;
  int price;
  String land_id;
  DateTime createdTime;

  Year({
    this.createdTime,
    @required this.price,
    @required this.year,
    @required this.doc_id,
  });

  static Year fromJson(Map<String, dynamic> json) => Year(
        createdTime: Utils.toDateTime(json['createdTime']),
        year: json['year'],
        price: json['price'],
        doc_id: json['doc_id'],
      );

  Map<String, dynamic> toJson() => {
        'createdTime': Utils.fromDateTimeToJson(createdTime),
        'year': year,
        'price': price,
        'doc_id': doc_id,
      };
}

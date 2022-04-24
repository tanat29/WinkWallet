import 'package:flutter/cupertino.dart';
import 'package:multipurpose/utils.dart';

class ExpenseField {
  static const createdTime = 'createdTime';
}

class Expense {
  String expense_id;
  String name;
  String day;
  String month;
  String year;
  String time;
  String type;
  int price;
  String detail;
  DateTime createdTime;

  Expense({
    this.createdTime,
    @required this.price,
    @required this.detail,
    @required this.name,
    @required this.day,
    @required this.month,
    @required this.year,
    @required this.time,
    @required this.type,
    @required this.expense_id,
  });

  static Expense fromJson(Map<String, dynamic> json) => Expense(
        createdTime: Utils.toDateTime(json['createdTime']),
        name: json['name'],
        day: json['day'],
        month: json['month'],
        year: json['year'],
        time: json['time'],
        type: json['type'],
        price: json['price'],
        detail: json['detail'],
        expense_id: json['expense_id'],
      );

  Map<String, dynamic> toJson() => {
        'createdTime': Utils.fromDateTimeToJson(createdTime),
        'name': name,
        'day': day,
        'month': month,
        'year': year,
        'time': time,
        'type': type,
        'price': price,
        'detail': detail,
        'expense_id': expense_id,
      };
}

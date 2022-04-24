import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose/model/expense.dart';
import 'package:multipurpose/page/expense/expense_edit.dart';
import 'package:multipurpose/page/income/income_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:multipurpose/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multipurpose/api/firebase_api.dart';

import 'package:multipurpose/page/login.dart';

class ExpenseDetail extends StatefulWidget {
  // รับค่าจากหน้าก่อน
  String name;
  ExpenseDetail({Key key, @required this.name}) : super(key: key);
  @override
  _ExpenseDetail createState() => _ExpenseDetail();
}

class _ExpenseDetail extends State<ExpenseDetail> {
  // ประกาศตัวแปร
  String name;
  @override
  void initState() {
    super.initState();
    name = widget.name;
  }

  Future<bool> BackPress() async {
    return (await goBack(context)) ?? false;
  }

  @override // แสดง UI
  Widget build(BuildContext context) {
    final today = Utils.getDateThai();
    return Scaffold(
        appBar: AppBar(
          title: Text('หน้ารายการ'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // แสดงข้อมูลจาก expense
          stream: FirebaseFirestore.instance
              .collection('expense')
              .orderBy(ExpenseField.createdTime, descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: Text("ไม่มีข้อมูล"));
            } else
              return Container(
                child: Column(
                  children: [
                    ListView(
                      padding: EdgeInsets.all(10),
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      children: snapshot.data.docs.map((doc) {
                        // นำข้อมูลจาก firebase เก็บใน expense
                        Expense expense = Expense(
                            expense_id: doc['expense_id'],
                            price: doc['price'],
                            detail: doc['detail'],
                            name: doc['name'],
                            day: doc['day'],
                            month: doc['month'],
                            year: doc['year'],
                            time: doc['time'],
                            type: doc['type']);

                        return name == expense.name
                            ? ExpenseList(context, expense, today)
                            : Container();
                      }).toList(),
                    ),
                  ],
                ),
                // จัดสีพื้นหลัง
                // decoration: BoxDecoration(
                //   gradient: LinearGradient(
                //       begin: Alignment.bottomLeft,
                //       end: Alignment.topRight,
                //       colors: [
                //         Colors.yellow[100],
                //         Colors.pink[200],
                //         Colors.blue[300]
                //       ]),
                // ),
              );
          },
        ));
  }

  // แสดงข้อมูลต่อใน ExpenseList
  Widget ExpenseList(BuildContext context, Expense expense, String today) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          key: Key(expense.expense_id),
          actions: [
            // ปัดซ้ายเพื่อแก้ไข
            IconSlideAction(
              color: Colors.green,
              onTap: () {
                if (expense.type == 'expense') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ExpenseEditPage(expense: expense)));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              IncomeEditPage(expense: expense)));
                }
              },
              caption: 'แก้ไข',
              icon: Icons.edit,
            )
          ],
          // ปัดขวาเพื่อลบ
          secondaryActions: [
            IconSlideAction(
              color: Colors.red,
              caption: 'ลบ',
              onTap: () {
                FirebaseApi.deleteExpense(context, expense);
              },
              icon: Icons.delete,
            )
          ],
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.all(3),
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Utils.getImage(expense.name),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildName(context, expense.name),
                              buildDetail(expense),
                            ],
                          ),
                        ],
                      ),
                      buildDayAndCost(
                          today, expense.day, expense.time, expense.price),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // แสดงชื่อ
  Widget buildName(BuildContext context, String name) => Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          )
        ],
      );

  // แสดงรายการ
  Widget buildDetail(Expense expense) => Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(10, 4, 0, 0),
            child: Text(
              'รายการ ' + expense.detail,
              style: TextStyle(fontSize: 13),
            ),
          )
        ],
      );

  // แสดงวันที่และเวลา
  Widget buildDayAndCost(String today, String day, String time, int number) =>
      Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(
              today == day ? time : day,
              style: TextStyle(fontSize: 13),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(
              number >= 0
                  ? '+' + NumberFormat("#,###").format(number).toString()
                  : NumberFormat("#,###").format(number).toString(),
              style: TextStyle(
                  fontSize: 18, color: number >= 0 ? Colors.green : Colors.red),
            ),
          )
        ],
      );

  goBack(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage(from: 'login')),
      (Route<dynamic> route) => false,
    );
  }
}

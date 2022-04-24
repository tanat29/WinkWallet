import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose/model/month.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LookMonthPage extends StatefulWidget {
  @override
  _LookMonthPage createState() => _LookMonthPage();
}

class _LookMonthPage extends State<LookMonthPage> {
  // ประกาศตัวแปร
  int selectedIndex = 1;
  String intent_from;

  @override // กำหนด UI
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ดูรายการแบบเดือน'),
        ),
        body: Container(
          height: double.infinity,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('month')
                .orderBy(MonthField.createdTime, descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text("ไม่มีข้อมูล"));
              } else
                return ListView(
                  padding: EdgeInsets.all(10),
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  children: snapshot.data.docs.map((doc) {
                    Month month = Month(
                        doc_id: doc['doc_id'],
                        month: doc['month'],
                        price: doc['price']);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: GestureDetector(
                        onTap: () => print(month.doc_id),
                        child: Container(
                          color: Colors.white,
                          margin: EdgeInsets.all(3),
                          padding: EdgeInsets.all(20),
                          child: buildMonthAndCost(month),
                        ),
                      ),
                    );
                  }).toList(),
                );
            },
          ),
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
        ));
  }

  Widget buildMonthAndCost(Month month) => Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'เดือน ' + month.month,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Text(
                    month.price > 0
                        ? '+' +
                            NumberFormat("#,###").format(month.price).toString()
                        : NumberFormat("#,###").format(month.price).toString(),
                    style: TextStyle(
                        fontSize: 20,
                        height: 1.5,
                        color: month.price > 0 ? Colors.green : Colors.red),
                  ),
                )
              ],
            ),
          ),
        ],
      );
}

Widget buildText(String text) => Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );

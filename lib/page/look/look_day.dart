import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose/model/day.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LookDayPage extends StatefulWidget {
  @override
  _LookDayPage createState() => _LookDayPage();
}

class _LookDayPage extends State<LookDayPage> {
  // ประกาศตัวแปร
  int selectedIndex = 1;
  String intent_from;

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ดูรายการแบบวัน'),
        ),
        body: Container(
          height: double.infinity,
          // โหลดข้อมูล firebase collection day
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('day')
                .orderBy(DayField.createdTime, descending: true)
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
                    Day day = Day(
                        doc_id: doc['doc_id'],
                        day: doc['day'],
                        price: doc['price']);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: GestureDetector(
                        onTap: () => print(day.doc_id),
                        child: Container(
                          color: Colors.white,
                          margin: EdgeInsets.all(3),
                          padding: EdgeInsets.all(20),
                          child: buildDayAndCost(day),
                        ),
                      ),
                    );
                  }).toList(),
                );
            },
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
        ));
  }

  Widget buildDayAndCost(Day day) => Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'วันที่ ' + day.day,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  // จัด format ให้มีลูกน้ำ
                  child: Text(
                    day.price > 0
                        ? '+' +
                            NumberFormat("#,###").format(day.price).toString()
                        : NumberFormat("#,###").format(day.price).toString(),
                    style: TextStyle(
                        fontSize: 20,
                        height: 1.5,
                        // ถ้ามากกว่า 0 สีเขียว ถ้าน้อยกว่าสีแดง
                        color: day.price > 0 ? Colors.green : Colors.red),
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

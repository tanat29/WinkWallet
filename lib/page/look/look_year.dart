import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose/model/year.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LookYearPage extends StatefulWidget {
  @override
  _LookYearPage createState() => _LookYearPage();
}

class _LookYearPage extends State<LookYearPage> {
  // ประกาศตัวแปร
  int selectedIndex = 1;
  String intent_from;

  @override // กำหนด UI
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ดูรายการแบบปี'), // ชื่อด้านบน
        ),
        body: Container(
          height: double.infinity,
          // โหลดข้อมูล firebase collection year
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('year')
                .orderBy(YearField.createdTime, descending: true)
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
                    Year year = Year(
                        doc_id: doc['doc_id'],
                        year: doc['year'],
                        price: doc['price']);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: GestureDetector(
                        onTap: () => print(year.doc_id),
                        child: Container(
                          color: Colors.white,
                          margin: EdgeInsets.all(3),
                          padding: EdgeInsets.all(20),
                          child: buildYearAndCost(year),
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

  Widget buildYearAndCost(Year year) => Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ปี ' + year.year,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  // จัด format ตัวเลข
                  child: Text(
                    year.price > 0
                        ? '+' +
                            NumberFormat("#,###").format(year.price).toString()
                        : NumberFormat("#,###").format(year.price).toString(),
                    style: TextStyle(
                        fontSize: 20,
                        height: 1.5,
                        color: year.price > 0 ? Colors.green : Colors.red),
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
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose/model/graph.dart';
import 'package:multipurpose/page/expense/expense_datail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:multipurpose/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multipurpose/api/firebase_api.dart';
import 'package:multipurpose/page/login.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExpenseAllPage extends StatefulWidget {
  @override
  _ExpenseAllPage createState() => _ExpenseAllPage();
}

class _ExpenseAllPage extends State<ExpenseAllPage> {
  // ประกาศตัวแปร
  int SumNumber = 0, selectedIndex = 0;
  bool btn_color0 = false;
  bool btn_color1 = true;
  bool btn_color2 = false;
  List<ChartData> chartData = [];

  @override // รัน initState ก่อน
  void initState() {
    super.initState();

    // รอ 0.5 วิ
    Timer(const Duration(milliseconds: 500), () {
      loadSumPrice(selectedIndex);
    });
    // รอ 1.5 วิ
    Timer(const Duration(milliseconds: 1500), () {
      load_graph(selectedIndex);
    });
  }

  // รวมค่าใช้จ่ายทั้งหมด
  Future loadSumPrice(int selectedIndex) async {
    SumNumber = await FirebaseApi.getSumExpense(selectedIndex);
    setState(() {
      print(SumNumber.toString());
    });
  }

  // โหลดข้อมูลกราฟลงใน chartData
  Future load_graph(int selectedIndex) async {
    chartData.clear;
    if (selectedIndex == 0) {
      await FirebaseFirestore.instance
          .collection('graph')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          String name = result.data()['name'];
          int price = result.data()['price'];

          setState(() {
            chartData.add(ChartData(name, price, Colors.amber));
          });
        });
      });
    } else if (selectedIndex == 1) {
      int array = 0;
      await FirebaseFirestore.instance
          .collection('graph')
          .where('type', isEqualTo: 'income')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          String name = result.data()['name'];
          int price = result.data()['price'];
          array = array + 1;

          setState(() {
            chartData
                .add(ChartData(name, price, Utils.selectColorIncome(array)));
          });
        });
      });
    } else {
      int array = 0;
      await FirebaseFirestore.instance
          .collection('graph')
          .where('type', isEqualTo: 'expense')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          String name = result.data()['name'];
          int price = result.data()['price'];
          array = array + 1;

          setState(() {
            chartData
                .add(ChartData(name, price, Utils.selectColorExpense(array)));
          });
        });
      });
    }
  }

  // ปุ่มย้อนกลับ
  Future<bool> BackPress() async {
    return (await goBack(context)) ?? false;
  }

  @override // หน้า UI
  Widget build(BuildContext context) {
    //final today = DateFormat.yMMMd('th').formatInBuddhistCalendarThai(DateTime.now());
    //final today = Utils.getDateThai(); // รับค่าวัน ณ ปัจจุบัน

    // จัด UI แบบบนลงล่าง
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(spacing: 10, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: btn_color0 == true ? Colors.green : Colors.grey,
              ),
              child: Text('รายรับ',
                  style: new TextStyle(color: Colors.white, fontSize: 12)),
              onPressed: () {
                // กดปุ่ม
                setState(() {
                  selectedIndex = 1;
                  btn_color0 = true;
                  btn_color1 = false;
                  btn_color2 = false;
                  chartData.clear();
                  loadSumPrice(1);
                  load_graph(1);
                });
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: btn_color1 == true ? Colors.green : Colors.grey,
              ),
              child: Text('ทั้งหมด',
                  style: new TextStyle(color: Colors.white, fontSize: 12)),
              onPressed: () {
                // กดปุ่ม
                setState(() {
                  selectedIndex = 0;
                  btn_color0 = false;
                  btn_color1 = true;
                  btn_color2 = false;
                  chartData.clear();
                  loadSumPrice(0);
                  load_graph(0);
                });
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: btn_color2 == true ? Colors.green : Colors.grey,
              ),
              child: Text('รายจ่าย',
                  style: new TextStyle(color: Colors.white, fontSize: 12)),
              onPressed: () {
                // กดปุ่ม
                setState(() {
                  selectedIndex = 2;
                  btn_color0 = false;
                  btn_color1 = false;
                  btn_color2 = true;
                  chartData.clear();
                  loadSumPrice(2);
                  load_graph(2);
                });
              },
            ),
          ]),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: Utils.selectGraphType(selectedIndex),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center();
            } else
              return Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Utils.setTextSumPrice(selectedIndex),
                            // จัด format ให้มีลูกน้ำ
                            Text(
                              SumNumber != null
                                  ? NumberFormat("#,###")
                                      .format(SumNumber)
                                      .toString()
                                  : NumberFormat("#,###")
                                      .format(SumNumber)
                                      .toString(),
                              style: new TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            Text(
                              ' บาท',
                              style: new TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            //SizedBox(width: 15.0),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 170,
                      child: selectedIndex == 0
                          ? SfCircularChart(
                              legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.right),
                              series: <CircularSeries>[
                                  PieSeries<ChartData, String>(
                                      dataSource: chartData,
                                      xValueMapper: (ChartData data, _) =>
                                          data.x,
                                      yValueMapper: (ChartData data, _) =>
                                          data.y,
                                      dataLabelSettings: DataLabelSettings(
                                          showZeroValue: false,
                                          isVisible: true,
                                          overflowMode: OverflowMode.trim))
                                ])
                          : SfCircularChart(
                              legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.right),
                              series: <CircularSeries>[
                                  PieSeries<ChartData, String>(
                                      dataSource: chartData,
                                      pointColorMapper: (ChartData data, _) =>
                                          data.color,
                                      xValueMapper: (ChartData data, _) =>
                                          data.x,
                                      yValueMapper: (ChartData data, _) =>
                                          data.y,
                                      dataLabelSettings: DataLabelSettings(
                                          showZeroValue: false,
                                          isVisible: true,
                                          overflowMode: OverflowMode.trim))
                                ]),
                    ),
                    ListView(
                      padding: EdgeInsets.all(10),
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      children: snapshot.data.docs.map((doc) {
                        Graph graph = Graph(
                          graph_id: doc['graph_id'],
                          name: doc['name'],
                          price: doc['price'],
                          type: doc['type'],
                        );

                        return GraphList(context, graph);
                      }).toList(),
                    ),
                  ],
                ),
              );
          },
        )
      ],
    );
  }

  Widget GraphList(BuildContext context, Graph graph) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GestureDetector(
          onTap: () {
            // ไปหน้า ExpenseDetail
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExpenseDetail(name: graph.name)));
          },
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
                          Utils.getImage(graph.name),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildName(context, graph.name),
                              buildType(graph.type),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // จัด format ให้มีลูกน้ำ
                          Text(
                            graph.price >= 0
                                ? '+' +
                                    NumberFormat("#,###")
                                        .format(graph.price)
                                        .toString()
                                : NumberFormat("#,###")
                                    .format(graph.price)
                                    .toString(),
                            style: TextStyle(
                                fontSize: 16,
                                // ถ้าราคามากกว่า 0 เป็นสีเขียว ถ้าน้อยกว่าเป็นสีแดง
                                color: graph.price >= 0
                                    ? Colors.green
                                    : Colors.red),
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.navigate_next,
                              ),
                              // กดแล้วไปหน้า ExpenseDetail
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ExpenseDetail(name: graph.name))))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildName(BuildContext context, String name) => Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          )
        ],
      );

  Widget buildType(String type) => Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(10, 4, 0, 0),
            child: type == 'income'
                ? Text(
                    'รายรับ',
                    style: TextStyle(fontSize: 13, color: Colors.green),
                  )
                : Text(
                    'รายจ่าย',
                    style: TextStyle(fontSize: 13, color: Colors.red),
                  ),
          )
        ],
      );

  // ย้อนกลับไปหน้า HomePage
  goBack(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage(from: 'login')),
      (Route<dynamic> route) => false,
    );
  }

  // ฟังก์ชั่น logOut
  Future logOut() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('⭐ แจ้งเตือน'),
        content: new Text('คุณต้องการออกจากระบบ ใช่หรือไม่?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // ปิด pop up
            child: new Text('ไม่ใช่'),
          ),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear(); // เคลีย SharedPreferences
              // ไปหน้า LoginPage
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage(),
                  ),
                  (route) => false);
            },
            child: new Text('ใช่'),
          ),
        ],
      ),
    ));
  }
}

class ChartData {
  final String x;
  final int y;
  final Color color;

  ChartData(this.x, this.y, [this.color]);
}

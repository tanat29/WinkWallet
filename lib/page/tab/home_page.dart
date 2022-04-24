import 'dart:async';

import 'package:multipurpose/page/expense/expense_add.dart';
import 'package:multipurpose/page/income/income_add.dart';
import 'package:multipurpose/page/login.dart';
import 'package:flutter/material.dart';
import 'package:multipurpose/page/look/look_day.dart';
import 'package:multipurpose/page/look/look_month.dart';
import 'package:multipurpose/page/look/look_year.dart';
import 'package:multipurpose/page/note/note_add.dart';
import 'package:multipurpose/page/tab/expense_all_page.dart';
import 'package:multipurpose/page/tab/note_page.dart';
import 'package:multipurpose/page/tab/user_profile.dart';
import 'package:multipurpose/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  // รับค่าจากหน้าก่อน
  String from;
  HomePage({Key key, @required this.from}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ประกาศตัวแปร
  int selectedIndex = 0;
  String intent_from, imagePath = '';

  SharedPreferences prefs;
  String user_id, username, password, tel, type, photo_before, createdTime;

  @override // รัน initState ก่อน
  initState() {
    super.initState();

    setState(() {
      // รับค่า from จากหน้าก่อน
      intent_from = widget.from;

      if (intent_from == '2') {
        selectedIndex = 2;
      } else if (intent_from == 'note') {
        selectedIndex = 1;
      } else {
        selectedIndex = 0;
      }
    });
  }

  @override // กำหนด UI
  Widget build(BuildContext context) {
    // กำหนด array หน้า tab 3 หน้า
    final tabs = [
      ExpenseAllPage(),
      NoteAllPage(),
      UserProfile(),
    ];

    Future<bool> Logout() async {
      return (await logoutMethod(context)) ?? false;
    }

    return new WillPopScope(
      onWillPop: Logout,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Utils.setName(selectedIndex)),
          actions: [
            selectedIndex == 0
                ? InkWell(
                    child: Center(
                    // แสดงไอคอนปฏิทิน
                    child: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => lookDayMothYear(context)),
                  ))
                : Container(),
            InkWell(
                child: Center(
              child: IconButton(
                  // แสดงไอคอน logout
                  icon: Icon(
                    Icons.logout,
                  ),
                  onPressed: () => Logout()),
            )),
          ],
        ),
        // แสดงปุ่มด้านล่าง
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedItemColor: Colors.white,
          currentIndex: selectedIndex,
          onTap: (index) => setState(() {
            selectedIndex = index;
          }),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'หน้าหลัก',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt),
              label: 'โน็ต',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts, size: 28),
              label: 'ผู้ใช้',
              backgroundColor: Colors.green,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              // จัดสีพื้นหลัง
              // gradient: LinearGradient(
              //     begin: Alignment.bottomLeft,
              //     end: Alignment.topRight,
              //     colors: [
              //       Colors.yellow[100],
              //       Colors.pink[200],
              //       Colors.blue[300]
              //     ]),
              ),
          child: ListView(
            children: [tabs[selectedIndex]],
          ),
        ),
        floatingActionButton: setFloatingButton(selectedIndex),
      ),
    );
  }

  // กำหนดปุ่ม floating ถ้าเป็นรายรับรายจ่ายให้ไป selectExpenseIncome ถ้าเป็น note ให้ไป NoteAddPage
  setFloatingButton(int selectedIndex) {
    if (selectedIndex == 0) {
      return FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.black,
        onPressed: () => selectExpenseIncome(context),
        child: Icon(Icons.add),
      );
    } else if (selectedIndex == 1) {
      return FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.black,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoteAddPage()),
        ),
        child: Icon(Icons.add),
      );
    } else {
      return Container();
    }
  }

  // แสดง popup รายรับรายจ่าย
  Future selectExpenseIncome(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('⭐ เพิ่มรายการ'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  // ไปหน้า IncomeAddPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IncomeAddPage()),
                  );
                },
                child: const Text(
                  'เพิ่มรายรับ',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  // ไปหน้า ExpenseAddPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExpenseAddPage()),
                  );
                },
                child: const Text(
                  'เพิ่มรายจ่าย',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        });
  }

  // แสดง popup ดูวัน เดือน ปี
  Future lookDayMothYear(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('⭐ เลือกดูแบบไหน'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  // ไปหน้า LookDayPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LookDayPage()),
                  );
                },
                child: const Text(
                  'ดูรายการแบบวัน',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  // ไปหน้า LookMonthPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LookMonthPage()),
                  );
                },
                child: const Text(
                  'ดูรายการแบบเดือน',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  // ไปหน้า LookYearPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LookYearPage()),
                  );
                },
                child: const Text(
                  'ดูรายการแบบปี',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        });
  }

  // ฟังก์ชัน Logout
  logoutMethod(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('⭐ แจ้งเตือน'),
          content: Text("คุณต้องการออกจากระบบ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              // ปิด popup
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                // เคลียร์ SharedPreferences และไปหน้า LoginPage
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
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
        );
      },
    );
  }
}

// แสดงข้อความ
Widget buildText(String text) => Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );

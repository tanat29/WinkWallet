import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multipurpose/api/firebase_api.dart';
import 'package:multipurpose/model/graph.dart';
import 'package:multipurpose/model/note.dart';
import 'package:progress_dialog/progress_dialog.dart';

// ไฟล์ จัดการเครื่องมือต่างๆในแอพ
class Utils {
  // แสดง SnackBar
  static void showSnackBar(BuildContext context, String text) =>
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));

  // แสดงข้อความ
  static void showToast(BuildContext context, String text) =>
      Fluttertoast.showToast(
          msg: text,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

  // แสดง Loading
  static void showProgress(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context);
    pr.style(
        message: "กรุณารอสักครู่ ...",
        progressWidget: Container(
            margin: EdgeInsets.all(10.0), child: CircularProgressIndicator()));
    pr.show();
  }

  // ซ่อน Loading
  static void hideProgress(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context);
    pr.hide();
  }

  // เช็คการทำงาน Loading
  static bool isShowProgress(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context);
    return pr.isShowing();
  }

  // รับ Timestamp มาเป็นวัน
  static DateTime toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  // รับ name มา แล้วคืน Image
  static getImage(String name) {
    if (name == 'อาหาร') {
      return Image.asset(
        'assets/food.png',
        height: 30,
      );
    } else if (name == 'เดินทาง') {
      return Image.asset(
        'assets/travel.png',
        height: 30,
      );
    } else if (name == 'ที่พัก') {
      return Image.asset(
        'assets/hotel.png',
        height: 30,
      );
    } else if (name == 'ของใช้') {
      return Image.asset(
        'assets/shopping.png',
        height: 30,
      );
    } else if (name == 'บริการ') {
      return Image.asset(
        'assets/serve.png',
        height: 30,
      );
    } else if (name == 'ถูกยืม') {
      return Image.asset(
        'assets/borrow.png',
        height: 30,
      );
    } else if (name == 'ค่ารักษา') {
      return Image.asset(
        'assets/health.png',
        height: 30,
      );
    } else if (name == 'สัตว์เลี้ยง') {
      return Image.asset(
        'assets/dog.png',
        height: 30,
      );
    } else if (name == 'บริจาค') {
      return Image.asset(
        'assets/donate.png',
        height: 30,
      );
    } else if (name == 'การศึกษา') {
      return Image.asset(
        'assets/book.png',
        height: 30,
      );
    } else if (name == 'คนรัก') {
      return Image.asset(
        'assets/love.png',
        height: 30,
      );
    } else if (name == 'เสื้อผ้า') {
      return Image.asset(
        'assets/cloth.png',
        height: 30,
      );
    } else if (name == 'เครื่องสำอาง') {
      return Image.asset(
        'assets/cosmetics.png',
        height: 30,
      );
    } else if (name == 'เครื่องประดับ') {
      return Image.asset(
        'assets/ring.png',
        height: 30,
      );
    } else if (name == 'บันเทิง') {
      return Image.asset(
        'assets/music.png',
        height: 30,
      );
    } else if (name == 'รายได้') {
      return Image.asset(
        'assets/income.png',
        height: 30,
      );
    } else if (name == 'กำไรจากลงทุน') {
      return Image.asset(
        'assets/profits.png',
        height: 30,
      );
    } else if (name == 'ออมเงิน') {
      return Image.asset(
        'assets/saving.png',
        height: 30,
      );
    } else if (name == 'เหรียญคริปโต') {
      return Image.asset(
        'assets/bitcoin.png',
        height: 30,
      );
    } else if (name == 'โบนัส') {
      return Image.asset(
        'assets/bonus.png',
        height: 30,
      );
    } else if (name == 'ทรัพย์สิน') {
      return Image.asset(
        'assets/asset.png',
        height: 30,
      );
    }
  }

  // รับ month แล้วคืนเป็น String
  static monthThai(int month) {
    if (month == 1) {
      return 'ม.ค.';
    } else if (month == 2) {
      return 'ก.พ.';
    } else if (month == 3) {
      return 'มี.ค.';
    } else if (month == 4) {
      return 'เม.ย.';
    } else if (month == 5) {
      return 'พ.ค.';
    } else if (month == 6) {
      return 'มิ.ย.';
    } else if (month == 7) {
      return 'ก.ค.';
    } else if (month == 8) {
      return 'ส.ค.';
    } else if (month == 9) {
      return 'ก.ย.';
    } else if (month == 10) {
      return 'ต.ค.';
    } else if (month == 11) {
      return 'พ.ย.';
    } else if (month == 12) {
      return 'ธ.ค.';
    }
  }

  // รับ selected แล้วคืน String
  static getSelectedNameExpense(String selected) {
    if (selected == '1') {
      return 'อาหาร';
    } else if (selected == '2') {
      return 'เดินทาง';
    } else if (selected == '3') {
      return 'ที่พัก';
    } else if (selected == '4') {
      return 'ของใช้';
    } else if (selected == '5') {
      return 'บริการ';
    } else if (selected == '6') {
      return 'ถูกยืม';
    } else if (selected == '7') {
      return 'ค่ารักษา';
    } else if (selected == '8') {
      return 'สัตว์เลี้ยง';
    } else if (selected == '9') {
      return 'บริจาค';
    } else if (selected == '10') {
      return 'การศึกษา';
    } else if (selected == '11') {
      return 'คนรัก';
    } else if (selected == '12') {
      return 'เสื้อผ้า';
    } else if (selected == '13') {
      return 'เครื่องสำอาง';
    } else if (selected == '14') {
      return 'เครื่องประดับ';
    } else if (selected == '15') {
      return 'บันเทิง';
    }
  }

  // รับ selected แล้วคืนเป็น String
  static getSelectedNameIncome(String selected) {
    if (selected == '1') {
      return 'รายได้';
    } else if (selected == '2') {
      return 'กำไรจากลงทุน';
    } else if (selected == '3') {
      return 'ออมเงิน';
    } else if (selected == '4') {
      return 'เหรียญคริปโต';
    } else if (selected == '5') {
      return 'โบนัส';
    } else if (selected == '6') {
      return 'ทรัพย์สิน';
    }
  }

  // แสดงวัน ณ ปัจจุบัน
  static String getDateThai() {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    String day, month, year;

    day = date.day.toString();
    year = (date.year + 543).toString();

    if (date.month == 1) {
      month = 'ม.ค.';
    } else if (date.month == 2) {
      month = 'ก.พ.';
    } else if (date.month == 3) {
      month = 'มี.ค.';
    } else if (date.month == 4) {
      month = 'เม.ย.';
    } else if (date.month == 5) {
      month = 'พ.ค.';
    } else if (date.month == 6) {
      month = 'มิ.ย.';
    } else if (date.month == 7) {
      month = 'ก.ค.';
    } else if (date.month == 8) {
      month = 'ส.ค.';
    } else if (date.month == 9) {
      month = 'ก.ย.';
    } else if (date.month == 10) {
      month = 'ต.ค.';
    } else if (date.month == 11) {
      month = 'พ.ย.';
    } else if (date.month == 12) {
      month = 'ธ.ค.';
    }
    return day + ' ' + month + ' ' + year;
  }

  // รับ number มาแล้วคืนเป็น color
  static Color selectColorExpense(int number) {
    Color color;
    if (number % 10 == 1) {
      color = Color(0xff40b863);
    } else if (number % 10 == 2) {
      color = Color(0xff3bbfc4);
    } else if (number % 10 == 3) {
      color = Color(0xff4069b3);
    } else if (number % 10 == 4) {
      color = Color(0xff5e57a5);
    } else if (number % 10 == 5) {
      color = Color(0xff9855a2);
    } else if (number % 10 == 6) {
      color = Color(0xffd0e8c6);
    } else if (number % 10 == 7) {
      color = Color(0xffd5edf2);
    } else if (number % 10 == 8) {
      color = Color(0xff9fcaea);
    } else if (number % 10 == 9) {
      color = Color(0xffcbcbe7);
    } else if (number % 10 == 0) {
      color = Color(0xffb59ac9);
    }
    return color;
  }

  // รับ number มาแล้วคืนเป็น color
  static Color selectColorIncome(int number) {
    Color color;
    if (number % 10 == 1) {
      color = Color(0xffef3b24);
    } else if (number % 10 == 2) {
      color = Color(0xfff66420);
    } else if (number % 10 == 3) {
      color = Color(0xfff99837);
    } else if (number % 10 == 4) {
      color = Color(0xffcc9932);
    } else if (number % 10 == 5) {
      color = Color(0xff9ac93c);
    } else if (number % 10 == 6) {
      color = Color(0xfff9caca);
    } else if (number % 10 == 7) {
      color = Color(0xfffbcd98);
    } else if (number % 10 == 8) {
      color = Color(0xfffecc68);
    } else if (number % 10 == 9) {
      color = Color(0xfff9ee6c);
    } else if (number % 10 == 0) {
      color = Color(0xffcee195);
    }
    return color;
  }

  // กำหนดข้อความ
  static Widget setTextSumPrice(int selectedIndex) {
    if (selectedIndex == 0) {
      return Text(
        'ยอดรวม ',
        style: new TextStyle(color: Colors.black, fontSize: 18),
      );
    } else if (selectedIndex == 1) {
      return Text(
        'รายรับ ',
        style: new TextStyle(color: Colors.black, fontSize: 18),
      );
    } else {
      return Text(
        'รายจ่าย ',
        style: new TextStyle(color: Colors.black, fontSize: 18),
      );
    }
  }

  // กำหนดกราฟ
  static selectGraphType(int selectedIndex) {
    if (selectedIndex == 0) {
      return FirebaseFirestore.instance
          .collection('graph')
          .orderBy(GraphField.createdTime, descending: true)
          .snapshots();
    } else if (selectedIndex == 1) {
      return FirebaseFirestore.instance
          .collection('graph')
          .where('type', isEqualTo: 'income')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('graph')
          .where('type', isEqualTo: 'expense')
          .snapshots();
    }
  }

  // กำหนดหัวข้อของแต่ละหน้า
  static String setName(int selectedIndex) {
    if (selectedIndex == 0) {
      return 'หน้าหลัก';
    } else if (selectedIndex == 1) {
      return 'หน้าโน๊ต';
    } else {
      return 'หน้าผู้ใช้งาน';
    }
  }

  // แสดง popup เพื่อลบ note
  static confirmDelete(BuildContext context, Note note) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('⭐ แจ้งเตือน'),
          content: Text("คุณต้องการลบโน๊ตนี้ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
                FirebaseApi.deleteNote(note.note_id);
                FirebaseApi.deleteNoteMonth(note.month);
              },
              child: new Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}

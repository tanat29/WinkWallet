import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:multipurpose/api/firebase_api.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:multipurpose/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteAddPage extends StatefulWidget {
  @override
  _NoteAddPage createState() => _NoteAddPage();
}

class _NoteAddPage extends State<NoteAddPage> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  double _height;
  double _width;

  String _setTime, _setDate;
  String _hour, _minute, _time;
  int sum = 0;

  String dateTime, name, detail;
  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  final picker = ImagePicker();
  String imagePath = '';
  File croppedFile;

  SharedPreferences prefs;
  String user_id;

  @override // รัน initState ก่อน
  void initState() {
    load();
    super.initState();
  }

  // โหลดข้อมูล SharedPreferences
  Future load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('user_id');
    });
  }

  @override // กำหนด UI
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มโน๊ต'),
      ),
      body: Container(
        height: double.infinity,
        // decoration: BoxDecoration(
        //   // จัดสีพื้นหลัง
        //   gradient: LinearGradient(
        //       begin: Alignment.bottomLeft,
        //       end: Alignment.topRight,
        //       colors: [Colors.yellow[100], Colors.pink[200], Colors.blue[300]]),
        // ),
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // แสดงข้อมูลจากบนลงล่าง
            child: Column(
              children: <Widget>[
                buildName(),
                buildDetail(),
                SizedBox(height: 16),
                buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // แสดงช่องกรอกชื่อ
  Widget buildName() => TextFormField(
        maxLines: 1,
        initialValue: name,
        onChanged: (name) => setState(() => this.name = name),
        validator: (name) {
          if (name.isEmpty) {
            return 'กรุณาใส่ชื่อโน๊ตก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'กรุณาใส่โน๊ต',
        ),
      );

  // แสดงช่องกรอกรายละเอียด
  Widget buildDetail() => TextFormField(
        maxLines: 1,
        initialValue: detail,
        onChanged: (detail) => setState(() => this.detail = detail),
        validator: (detail) {
          if (detail.isEmpty) {
            return 'กรุณาใส่รายละเอียดก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'กรุณาใส่รายละเอียด',
        ),
      );

  // แสดงปุ่ม เพิ่มโน็จ
  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: () => save_data(),
          child: Text('เพิ่มโน๊ต',
              style:
                  TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ),
      );

  // ฟังก์ชัน save_data
  void save_data() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState.validate();

    if (!isValid) {
      return;
    } else {
      var year = (selectedDate.year + 543).toString();
      var month = Utils.monthThai(selectedDate.month).toString() + ' ' + year;
      var day = Utils.getDateThai();
      var time = formatDate(
          DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
          [HH, ':', nn, " น."]).toString();

      Utils.showProgress(context); // แสดง Loading

      final docNote = FirebaseFirestore.instance.collection('note').doc();
      // ข้อมูล note
      await docNote.set({
        'note_id': docNote.id,
        'name': name,
        'detail': detail,
        'time': time,
        'day': day,
        'month': month,
        'user_id': user_id,
        'createdTime': DateTime.now(),
      });

      FirebaseApi.addNoteMonth(month, user_id); // เพื่มข้อมูลเดือน

      Utils.hideProgress(context); // ซ่อน Loading
      // ไปหน้า HomePage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  from: 'note',
                )),
        (Route<dynamic> route) => false,
      );
    }
  }
}

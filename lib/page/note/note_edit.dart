import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose/model/note.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:multipurpose/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NoteEditPage extends StatefulWidget {
  // รับค่าจากหน้าก่อน
  Note note;
  NoteEditPage({Key key, @required this.note}) : super(key: key);
  @override
  _NoteEditPage createState() => _NoteEditPage();
}

class _NoteEditPage extends State<NoteEditPage> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  double _height;
  double _width;

  int sum = 0, cost;
  String note_id, name, detail;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  final picker = ImagePicker();
  String imagePath = '';
  File croppedFile;

  @override // รัน initState ก่อน
  void initState() {
    note_id = widget.note.note_id;
    name = widget.note.name;
    detail = widget.note.detail;
    super.initState();
  }

  @override // กำหนด UI
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขโน๊ต'),
      ),
      body: Container(
        height: double.infinity,
        // จัดสีพื้นหลัง
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //       begin: Alignment.bottomLeft,
        //       end: Alignment.topRight,
        //       colors: [Colors.yellow[100], Colors.pink[200], Colors.blue[300]]),
        // ),
        padding: EdgeInsets.all(16),

        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // เรียงจากบนลงล่าง
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

  // แสดงช่องกรอกชื่อโน็ต
  Widget buildName() => TextFormField(
        maxLines: 1,
        initialValue: name,
        onChanged: (name) => setState(() => this.name = name),
        validator: (name) {
          if (name.isEmpty) {
            return 'กรุณาใส่ชื่อโน็ตก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'กรุณาใส่โน็ต',
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

  // แสดงปุ่มแก้ไข
  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: () => saveData(),
          child: Text('แก้ไข',
              style:
                  TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ),
      );

  // ฟังก์ชัน saveData
  void saveData() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState.validate();

    if (!isValid) {
      return;
    } else {
      Utils.showProgress(context); // แสดง Loading

      // อัพเดตข้อมูล firebase collection note
      await FirebaseFirestore.instance.collection('note').doc(note_id).update({
        'name': name,
        'detail': detail,
      });

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

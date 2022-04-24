import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:multipurpose/api/firebase_api.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:multipurpose/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class IncomeAddPage extends StatefulWidget {
  @override
  _IncomeAddPage createState() => _IncomeAddPage();
}

class _IncomeAddPage extends State<IncomeAddPage> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  double _height;
  double _width;

  String _setTime, _setDate;
  String _hour, _minute, _time;
  int sum = 0;

  String dateTime, cost, detail, _selected;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  List<Map> _myJson = [
    {"id": '1', "image": "assets/income.png", "name": "รายได้"},
    {"id": '2', "image": "assets/profits.png", "name": "กำไรจากลงทุน"},
    {"id": '3', "image": "assets/saving.png", "name": "ออมเงิน"},
    {"id": '4', "image": "assets/bitcoin.png", "name": "เหรียญคริปโต"},
    {"id": '5', "image": "assets/bonus.png", "name": "โบนัส"},
    {"id": '6', "image": "assets/asset.png", "name": "ทรัพย์สิน"},
  ];

  final picker = ImagePicker();
  File croppedFile;

  @override // รัน initState ก่อน
  void initState() {
    _dateController.text = Utils.getDateThai();
    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [HH, ':', nn, " น."]).toString();

    super.initState();
  }

  // เลือกวัน
  Future _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        _dateController.text = selectedDate.day.toString() +
            ' ' +
            Utils.monthThai(selectedDate.month) +
            ' ' +
            (selectedDate.year + 543).toString();
      });
  }

  // เลือกเวลา
  Future _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [HH, ':', nn, " น."]).toString();
      });
  }

  @override // กำหนด UI
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    dateTime = DateFormat.yMMMd().format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text('บันทึกรายรับ'),
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //       begin: Alignment.bottomLeft,
        //       end: Alignment.topRight,
        //       colors: [Colors.yellow[100], Colors.pink[200], Colors.blue[300]]),
        // ),
        padding: EdgeInsets.all(16),
        width: _width,
        height: _height,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // เรียงจากบนลงล่าง
            child: Column(
              children: <Widget>[
                buildDate(),
                buildTime(),
                Align(
                    child: Text('หมวดหมู่', style: TextStyle(fontSize: 18)),
                    alignment: Alignment.centerLeft),
                buildCategory(),
                //buildImageSlip(),
                SizedBox(height: 10),
                buildDetail(),
                buildCost(),
                SizedBox(height: 16),
                buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // แสดงข้อมูลวันที่
  Widget buildDate() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: _width / 1.7,
            height: _height / 12,
            alignment: Alignment.center,
            child: TextFormField(
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              enabled: false,
              keyboardType: TextInputType.text,
              controller: _dateController,
              onSaved: (String val) {
                _setDate = val;
              },
              decoration: InputDecoration(
                  disabledBorder:
                      UnderlineInputBorder(borderSide: BorderSide.none),
                  // labelText: 'Time',
                  contentPadding: EdgeInsets.only(top: 0.0)),
            ),
          ),
          // แสดงปุ่มเลือกวัน
          Container(
            width: 100,
            child: ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('เลือกวัน',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ),
          ),
        ],
      );

  // แสดงข้อมูลเวลา
  Widget buildTime() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: _width / 1.7,
            height: _height / 10,
            alignment: Alignment.center,
            child: TextFormField(
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              onSaved: (String val) {
                _setTime = val;
              },
              enabled: false,
              keyboardType: TextInputType.text,
              controller: _timeController,
              decoration: InputDecoration(
                  disabledBorder:
                      UnderlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.all(5)),
            ),
          ),
          // แสดงปุ่มเลือกเวลา
          Container(
            width: 100,
            child: ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text(
                'เลือกเวลา',
                style:
                    TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      );

  // แสดง dropdown
  Widget buildCategory() => Container(
        margin: EdgeInsets.all(30),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    isDense: true,
                    hint: new Text("กรุณาเลือกหมวดหมู่"),
                    value: _selected,
                    onChanged: (String newValue) {
                      setState(() {
                        _selected = newValue;
                      });
                    },
                    items: _myJson.map((Map map) {
                      return new DropdownMenuItem<String>(
                        value: map["id"].toString(),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              map["image"],
                              width: 25,
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(map["name"])),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  //แสดงช่องกรอกรายการ
  Widget buildDetail() => TextFormField(
        maxLines: 1,
        initialValue: detail,
        onChanged: (detail) => setState(() => this.detail = detail),
        validator: (codetailst) {
          if (detail.isEmpty) {
            return 'กรุณาใส่รายการก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'กรุณาใส่รายการ',
        ),
      );

  // แสดงช่องกรอกราคา
  Widget buildCost() => TextFormField(
        maxLines: 1,
        initialValue: cost,
        // กำหนดให้ใส่แค่ตัวเลข
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onChanged: (cost) => setState(() => this.cost = cost),
        validator: (cost) {
          if (cost.isEmpty) {
            return 'กรุณาใส่ราคาก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'กรุณาใส่ราคา',
        ),
      );

  //แสดงปุ่ม บันทึก
  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: () => save_data(),
          child: Text('บันทึก',
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
      var day = selectedDate.day.toString() + ' ' + month;
      var time = _timeController.text.toString();
      var cost2 = int.parse(cost);

      // ดักข้อมูล dropdown
      if (_selected == null) {
        Utils.showToast(context, 'กรุณาเลือกหมวดหมู่ก่อน');
        return;
      }

      Utils.showProgress(context); // แสดง Loading

      final doc_expense =
          FirebaseFirestore.instance.collection('expense').doc();

      // เพิ่มข้อมูล expense
      await doc_expense.set({
        'expense_id': doc_expense.id,
        'name': Utils.getSelectedNameIncome(_selected),
        'price': cost2,
        'detail': detail,
        'time': time,
        'day': day,
        'month': month,
        'year': year,
        'type': 'income',
        'createdTime': DateTime.now(),
      });

      FirebaseApi.getDataDayMonthYearAll('day'); // เพิ่มข้อมูลวัน
      FirebaseApi.getDataDayMonthYearAll('month'); // เพิ่มข้อมูลเดือน
      FirebaseApi.getDataDayMonthYearAll('year'); // เพิ่มข้อมูลปี
      FirebaseApi.updateGraph(
          Utils.getSelectedNameIncome(_selected), 'income'); // อัพเดทกราฟ

      Utils.hideProgress(context); // ซ่อน Loading

      // ไปหน้า HomePage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(from: 'income')),
        (Route<dynamic> route) => false,
      );
    }
  }
}

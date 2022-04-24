import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:multipurpose/api/firebase_api.dart';
import 'package:multipurpose/model/expense.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:multipurpose/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class IncomeEditPage extends StatefulWidget {
  // รับค่าจากหน้าก่อน
  Expense expense;
  IncomeEditPage({Key key, @required this.expense}) : super(key: key);
  @override
  _IncomeEditPage createState() => _IncomeEditPage();
}

class _IncomeEditPage extends State<IncomeEditPage> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  double _height;
  double _width;

  String _setTime, _setDate;
  String _hour, _minute, _time;
  int sum = 0, cost;
  String expense_id;

  String dateTime, amount, name_before, cost2, detail;
  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  String _selected;

  final picker = ImagePicker();
  String imagePath = '';
  File croppedFile;

  // กำหนด json
  List<Map> _myJson = [
    {"id": '1', "image": "assets/income.png", "name": "รายได้"},
    {"id": '2', "image": "assets/profits.png", "name": "กำไรจากลงทุน"},
    {"id": '3', "image": "assets/saving.png", "name": "ออมเงิน"},
    {"id": '4', "image": "assets/bitcoin.png", "name": "เหรียญคริปโต"},
    {"id": '5', "image": "assets/bonus.png", "name": "โบนัส"},
    {"id": '6', "image": "assets/asset.png", "name": "ทรัพย์สิน"},
  ];

  @override // รัน initState ก่อน
  void initState() {
    _dateController.text = Utils.getDateThai(); // รับค่าวันที่ปัจจุบันมา

    // รับค่าเวลาปัจจุบัน
    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [HH, ':', nn, " น."]).toString();

    expense_id = widget.expense.expense_id;
    name_before = widget.expense.name;
    detail = widget.expense.detail;
    cost2 = widget.expense.price.toString().replaceAll('-', '');

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
        title: Text('แก้ไขรายรับ'),
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
                  // labelText: 'Time',
                  contentPadding: EdgeInsets.all(5)),
            ),
          ),
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

  Widget buildCost() => TextFormField(
        maxLines: 1,
        initialValue: cost2,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onChanged: (cost2) => setState(() => this.cost2 = cost2),
        validator: (cost2) {
          if (cost2.isEmpty) {
            return 'กรุณาใส่ราคาก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'กรุณาใส่ราคา',
        ),
      );

  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: () => save_data(),
          child: Text('แก้ไข',
              style:
                  TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ),
      );

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
      var price = int.parse(cost2);

      // ดักข้อมูล dropdown
      if (_selected == null) {
        Utils.showToast(context, 'กรุณาเลือกหมวดหมู่ก่อน');
        return;
      }

      Utils.showProgress(context); // แสดง Loading

      // อัพเดตข้อมูล expense
      await FirebaseFirestore.instance
          .collection('expense')
          .doc(expense_id)
          .update({
        'name': Utils.getSelectedNameIncome(_selected),
        'price': price,
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

      FirebaseApi.checkExpenseEmtry('day'); // เช็คข้อมูลวัน
      FirebaseApi.checkExpenseEmtry('month'); // เช็คข้อมูลเดือน
      FirebaseApi.checkExpenseEmtry('year'); // เช็คข้อมูลปี
      FirebaseApi.deleteGraph(name_before, 'expense'); // เช็คข้อมูลกราฟ
      FirebaseApi.getDataGraphAll(); // เพิ่มข้อมูลกราฟ

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

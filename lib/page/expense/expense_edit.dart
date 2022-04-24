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

class ExpenseEditPage extends StatefulWidget {
  // รับค่ามาจากหน้าก่อน
  Expense expense;
  ExpenseEditPage({Key key, @required this.expense}) : super(key: key);
  @override
  _ExpenseEditPage createState() => _ExpenseEditPage();
}

class _ExpenseEditPage extends State<ExpenseEditPage> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  double _height;
  double _width;

  String _setTime, _setDate;
  String _hour, _minute, _time;
  int sum = 0, cost;
  String expense_id, name_before, detail;

  String dateTime, amount, _selected;
  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  final picker = ImagePicker();
  File croppedFile;

  // ประกาศ Json
  List<Map> _myJson = [
    {"id": '1', "image": "assets/food.png", "name": "อาหาร"},
    {"id": '2', "image": "assets/travel.png", "name": "เดินทาง"},
    {"id": '3', "image": "assets/hotel.png", "name": "ที่พัก"},
    {"id": '4', "image": "assets/shopping.png", "name": "ของใช้"},
    {"id": '5', "image": "assets/serve.png", "name": "บริการ"},
    {"id": '6', "image": "assets/borrow.png", "name": "ถูกยืม"},
    {"id": '7', "image": "assets/health.png", "name": "ค่ารักษา"},
    {"id": '8', "image": "assets/dog.png", "name": "สัตว์เลี้ยง"},
    {"id": '9', "image": "assets/donate.png", "name": "บริจาค"},
    {"id": '10', "image": "assets/book.png", "name": "การศึกษา"},
    {"id": '11', "image": "assets/love.png", "name": "คนรัก"},
    {"id": '12', "image": "assets/cloth.png", "name": "เสื้อผ้า"},
    {"id": '13', "image": "assets/cosmetics.png", "name": "เครื่องสำอาง"},
    {"id": '14', "image": "assets/ring.png", "name": "เครื่องประดับ"},
    {"id": '15', "image": "assets/music.png", "name": "บันเทิง"},
  ];

  @override // รัน initState ก่อน
  void initState() {
    _dateController.text = Utils.getDateThai(); // ใส่ค่าวัน ณ ปัจจุบัน

    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [HH, ':', nn, " น."]).toString();

    expense_id = widget.expense.expense_id;
    name_before = widget.expense.name;
    cost = widget.expense.price;
    detail = widget.expense.detail;

    setState(() {
      amount = cost.toString().replaceAll('-', '');
    });
    super.initState();
  }

  // เลือกวันที่
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
        title: Text('แก้ไขรายจ่าย'),
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
                SizedBox(height: 10),
                buildDetail(),
                buildAmount(),
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
                        // value: _mySelection,
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

  Widget buildAmount() => TextFormField(
        maxLines: 1,
        initialValue: amount,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onChanged: (amount) => setState(() => this.amount = amount),
        validator: (amount) {
          if (amount.isEmpty) {
            return 'กรุณาใส่จำนวนก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'กรุณาใส่จำนวน',
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

  // ฟัง์ชัน save_data
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
      var cost = int.parse(amount);

      if (_selected == null) {
        Utils.showToast(context, 'กรุณาเลือกหมวดหมู่ก่อน');
        return;
      }

      Utils.showProgress(context); // แสดง Loading

      // อัพเดตข้อมูล firebase
      await FirebaseFirestore.instance
          .collection('expense')
          .doc(expense_id)
          .update({
        'name': Utils.getSelectedNameExpense(_selected),
        'price': -cost,
        'detail': detail,
        'time': time,
        'day': day,
        'month': month,
        'year': year,
        'type': 'expense',
        'createdTime': DateTime.now(),
      });

      FirebaseApi.getDataDayMonthYearAll('day'); // เพิ่มข้อมูลวัน
      FirebaseApi.getDataDayMonthYearAll('month'); // เพิ่มข้อมูลเดือน
      FirebaseApi.getDataDayMonthYearAll('year'); // เพิ่มข้อมูลปี

      FirebaseApi.checkExpenseEmtry('day'); // เช็ควันที่ไม่มีข้อมูล
      FirebaseApi.checkExpenseEmtry('month');
      FirebaseApi.checkExpenseEmtry('year');
      FirebaseApi.deleteGraph(name_before, 'expense');
      FirebaseApi.getDataGraphAll();

      Utils.hideProgress(context);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(from: 'expense')),
        (Route<dynamic> route) => false,
      );
    }
  }
}

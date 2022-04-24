import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:multipurpose/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multipurpose/page/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  String username;
  String password;
  bool _validate = false;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();

    setState(() {
      username = '';
      password = '';
    });
  }

  @override // แสดง UI
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('หน้าล็อกอิน'),
      ),
      body: Container(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                // แสดงจากยนลงล่าง
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 150,
                    ),
                    buildEmail(),
                    SizedBox(height: 8),
                    buildPassword(),
                    SizedBox(height: 16),
                    buildButton(),
                    buildTextRegister(),
                  ],
                ),
              ),
            ),
          ),
        ),
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //       begin: Alignment.bottomLeft,
        //       end: Alignment.topRight,
        //       colors: [Colors.yellow[100], Colors.pink[200], Colors.blue[300]]),
        // ),
      ));

  Widget buildEmail() => TextFormField(
        maxLines: 1,
        initialValue: username,
        onChanged: (username) => setState(() => this.username = username),
        validator: (username) {
          if (username.isEmpty) {
            return 'กรุณาใส่ชื่อผู้ใช้ก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'ชื่อผู้ใช้',
        ),
      );

  Widget buildPassword() => TextFormField(
        maxLines: 1,
        initialValue: password,
        onChanged: (password) => setState(() => this.password = password),
        validator: (password) {
          if (password.isEmpty) {
            return 'กรุณาใส่รหัสผ่านก่อน';
          }
          if (password.length < 5) {
            return 'รห้สผ่านต้องมากกว่า 6 ตัว';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'รหัสผ่าน',
        ),
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
      );

  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: () {
            saveTodo();
          },
          child: Text('เข้าสู่ระบบ'),
        ),
      );

  Widget buildTextRegister() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ยังไม่มีบัญชีใช่มั้ย?',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              },
              child: Text(
                'สมัครเลย',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ))
        ],
      );

  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState.validate();

    if (!isValid) {
      // ดักข้อมูล
      return;
    } else {
      Utils.showProgress(context); // แสดง Loading

      await FirebaseFirestore.instance
          .collection('user')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          Utils.hideProgress(context); // ซ่อน Loading
          // รับค่าจาก Firestore
          var user_id = result.data()['user_id'];
          var username = result.data()['username'];
          var password = result.data()['password'];
          var tel = result.data()['tel'];
          var type = result.data()['type'];
          var photo = result.data()['photo'];
          var createdTime = result.data()['createdTime'].toString();

          final prefs =
              await SharedPreferences.getInstance(); // ประกาศ SharedPreferences
          prefs.setBool("check", true); // เก็บค่า boolean
          prefs.setString('user_id', user_id);
          prefs.setString('username', username);
          prefs.setString('password', password);
          prefs.setString('tel', tel);
          prefs.setString('type', type);
          prefs.setString('photo', photo);
          prefs.setString('createdTime', createdTime);

          // ไปหน้า HomePage
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage(from: 'login')),
            (Route<dynamic> route) => false,
          );
        });
      }).catchError((e) {
        // ดัก Error
        Utils.hideProgress(context); // ซ่อน Loading
        Utils.showToast(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่'); // แสดงข้อความ
      });

      // ถ้า Loading ยังทำงาน
      if (Utils.isShowProgress(context)) {
        // นับเวลา 3 วิ
        Timer(const Duration(seconds: 3), () {
          Utils.hideProgress(context); // ซ่อน Loading
          Utils.showToast(
              context, 'ข้อมูลไม่ถูกต้อง กรุณาลองใหม่'); // แสดงข้อความ
        });
      }
    }
  }
}

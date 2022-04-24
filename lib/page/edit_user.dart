import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multipurpose/model/user.dart';

class EditUserPage extends StatefulWidget {
  final User user;
  String from;

  // รับค่ามาจากหน้าก่อน
  EditUserPage({Key key, @required this.user, this.from}) : super(key: key);

  @override
  _EditUserPage createState() => _EditUserPage();
}

class _EditUserPage extends State<EditUserPage> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  String user_id;
  String username;
  String password;
  String tel;
  String from;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    user_id = widget.user.user_id;
    username = widget.user.username;
    password = widget.user.password;
    tel = widget.user.tel;
    from = widget.from;
  }

  @override // แสดง UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('แก้ไขข้อมูลผู้ใช้'),
        ),
        body: Container(
          height: double.infinity,
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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                // แสดงจากบนลงล่าง
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildUsername(),
                    SizedBox(height: 8),
                    buildPassword(),
                    SizedBox(height: 8),
                    buildTel(),
                    SizedBox(height: 16),
                    buildButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget buildUsername() => TextFormField(
        maxLines: 1,
        initialValue: username,
        onChanged: (username) => setState(() => this.username = username),
        validator: (username) {
          if (username.isEmpty) {
            return 'กรุณาใส่ชื่อบัญชีก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'กรุณาใส่ชื่อบัญชี',
        ),
      );

  Widget buildTel() => TextFormField(
        maxLines: 1,
        initialValue: tel,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onChanged: (tel) => setState(() => this.tel = tel),
        validator: (tel) {
          if (tel.isEmpty) {
            return 'กรุณาใส่เบอร์โทรก่อน';
          }
          if (tel.length < 8) {
            return 'กรุณาเช็คจำนวนตัวเลขก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'กรุณาใส่เบอร์โทร',
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
          child: Text('แก้ไขข้อมูล'),
        ),
      );

  // ฟังก์ชัน แกไ้ขข้อมูล
  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState.validate();

    if (!isValid) {
      return;
    } else {
      // แก้ไขข้อมูล
      await FirebaseFirestore.instance.collection('user').doc(user_id).update({
        'username': username,
        'password': password,
        'tel': tel,
      });

      if (from == 'user') {
        // ถ้า from เป็น user1 ให้บันทึกลง SharedPreferences แล้วไปหน้า HomePage ส่งค่า 4 ไป
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        prefs.setString('password', password);
        prefs.setString('tel', tel);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage(from: '2')),
          (Route<dynamic> route) => false,
        );
      } else {
        // ถ้าไม่ใช่ ไปหน้า HomePage ส่งค่า 3 ไป
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage(from: '3')),
          (Route<dynamic> route) => false,
        );
      }
    }
  }
}

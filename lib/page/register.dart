// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:multipurpose/model/user.dart';
import 'package:multipurpose/provider/provider_api.dart';
import 'package:multipurpose/utils.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  // ประกาศตัวแปรก่อนเข้าหน้า UI
  final _formKey = GlobalKey<FormState>();
  String username, tel, password, password_confirm;
  bool _validate = false;

  @override // หน้า UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('หน้าสมัครสมาชิก'),
        ),
        body: Container(
          height: double.infinity,
          // decoration: BoxDecoration(
          //   // จัดสีพื้นหลัง
          //   gradient: LinearGradient(
          //       begin: Alignment.bottomLeft,
          //       end: Alignment.topRight,
          //       colors: [
          //         Colors.yellow[100],
          //         Colors.pink[200],
          //         Colors.blue[300]
          //       ]),
          // ),
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                // ไล่ widget จากบนลงล่าง
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildUsername(),
                  SizedBox(height: 8),
                  buildPassword(),
                  SizedBox(height: 8),
                  buildPasswordConfirm(),
                  SizedBox(height: 8),
                  buildTel(),
                  SizedBox(height: 16),
                  buildButton(),
                ],
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
          if (tel.length < 6) {
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
          if (password.length < 6) {
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
  Widget buildPasswordConfirm() => TextFormField(
        maxLines: 1,
        initialValue: password_confirm,
        onChanged: (password_confirm) =>
            setState(() => this.password_confirm = password_confirm),
        validator: (password_confirm) {
          if (password != password_confirm) {
            return 'รหัสผ่านไม่ตรงกัน';
          }
          if (password_confirm.isEmpty) {
            return 'กรุณาใส่รหัสผ่านก่อน';
          }
          if (password_confirm.length < 6) {
            return 'รห้สผ่านต้องมากกว่า 6 ตัว';
          }
          return null;
        },
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'รหัสผ่านอีกครั้ง',
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
          child: Text('สมัครสมาชิก'),
        ),
      );

  void saveTodo() async {
    // บันทึกข้อมูล
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState.validate();

    if (!isValid) {
      return;
    } else {
      Utils.showProgress(context); // แสดง Loading

      // เช็คว่าชื่อซ้ำหรือไม่
      if (await checkIfDocExists(username)) {
        final user = User(
          user_id: DateTime.now().toString(),
          username: username,
          password: password,
          tel: tel,
          type: 'ผู้ใช้ทั่วไป',
          photo: '',
          createdTime: DateTime.now(),
        );

        final provider = Provider.of<ProviderApi>(context, listen: false);
        provider.addUser(user); // ส่งค่าไปเพิ่มข้อมูลผู้ใช้

        Utils.hideProgress(context); // ปิด Loading
        Navigator.pop(context); // ย้อนกลับหน้าเดิม
      } else {
        Utils.hideProgress(context); // ปิด Loading
        Utils.showToast(
            context, 'ชื่อบัญชีซ้ำ กรุณาเปลี่ยน'); // ส่งค่าไปเพิ่มข้อมูลผู้ใช้
      }
    }
  }

  // เช็คว่าชื่อซ้ำหรือไม่
  Future<bool> checkIfDocExists(String username) async {
    bool check = false;
    final snapshot = await FirebaseFirestore.instance
        .collection("user")
        .where('username', isEqualTo: username)
        .get();

    if (snapshot.docs.length == 0) {
      setState(() {
        // ถ้าไม่ซ้ำให้เป็น false
        check = true;
      });
    } else {
      setState(() {
        // ถ้าซ้ำให้เป็น true
        check = false;
      });
    }
    return check;
  }
}

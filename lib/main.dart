import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multipurpose/page/login.dart';
import 'package:multipurpose/provider/provider_api.dart';

Future main() async {
  // ประกาศการใช้งานต่างๆครั้งแรก
  Intl.defaultLocale = 'th';
  initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ใช้งาน firebase
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // จัดหน้าจอแนวตั้ง
  ]);
  runApp(MyApp()); // รันที่ MyApp
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => ProviderApi(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Wink Wallet',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: Color(0xFFf6f5ee),
          ),
          home: SplashScreen(), // ไปที่หน้า SplashScreen
        ),
      );
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // เข้าที่ initState ก่อน
    super.initState();

    check_data();
  }

  void check_data() async {
    // เช็คว่า login ไว้หรือเปล่า ถ้า login ให้ไป HomePage , ถ้าไม่ได้ Login ให้ไป LoginPage
    final prefs = await SharedPreferences.getInstance();
    var check = prefs.getBool('check') ?? false;
    var type = prefs.getString('type');
    if (check) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(from: 'login')),
        (Route<dynamic> route) => false,
      );
    } else {
      Timer(const Duration(seconds: 3), () {
        // นับเวลา 3 วิ
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => LoginPage(),
            ),
            (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // หน้า UI
    return Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //       // จัดสีพื้นหลัง
        //       begin: Alignment.bottomLeft,
        //       end: Alignment.topRight,
        //       colors: [
        //         Colors.yellow[100],
        //         Colors.green[200],
        //         Colors.blue[300]
        //       ]),
        // ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // แสดงรูป
              Image.asset(
                'assets/logo.png',
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

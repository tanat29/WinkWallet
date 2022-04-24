import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose/api/firebase_api.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multipurpose/model/user.dart';
import 'package:multipurpose/page/edit_user.dart';
import 'package:multipurpose/utils.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfile createState() => _UserProfile();
}

class _UserProfile extends State<UserProfile> {
  //  ประกาศตัวแปร
  SharedPreferences prefs;
  String user_id, username, password, tel, type, photo_before, createdTime;

  String imagePath = '';
  final picker = ImagePicker();

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    load();
  }

  // โหลดข้อมูล SharedPreferences
  Future load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('user_id');
      username = prefs.getString('username');
      password = prefs.getString('password');
      tel = prefs.getString('tel');
      type = prefs.getString('type');
      photo_before = prefs.getString('photo');
      createdTime = prefs.getString('createdTime');
    });
  }

  @override // หน้า UI
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Container(
      // แสดงจากบนลงล่าง
      child: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          buildPhoto(),
          buildUsername(),
          SizedBox(
            height: 10.0,
          ),
          buildPassword(),
          SizedBox(
            height: 10,
          ),
          buildTel(),
          SizedBox(
            height: 10.0,
          ),
          buildType(),
          SizedBox(
            height: 10.0,
          ),
          buildButtonEdit(),
        ],
      ),
    ));
  }

  Widget buildPhoto() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 25.0,
                ),
                onPressed: () async => await FirebaseApi.removePhoto(
                    'https://firebasestorage.googleapis.com/v0/b/farmaccounting-74f30.appspot.com/o/Slip%2F2021-10-06%2021%3A40%3A35.182752.jpg?alt=media&token=bc811314-61b3-4ce8-93ea-c204e64d7594'),
              ),
            ),
          ),
          CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xff476cfb),
            child: ClipOval(
              child: new SizedBox(
                  width: 105,
                  height: 105,
                  child: photo_before != ''
                      ? Image.network(
                          '${photo_before}', // this image doesn't exist
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/placeholder.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/user.png',
                          fit: BoxFit.cover,
                        )),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 60.0),
            child: IconButton(
              icon: Icon(
                Icons.photo_camera,
                size: 25.0,
              ),
              onPressed: () async {
                final pickedFile =
                    await picker.getImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  File croppedFile = await ImageCropper().cropImage(
                    sourcePath: pickedFile.path,
                    aspectRatioPresets: [
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio3x2,
                      CropAspectRatioPreset.original,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.ratio16x9
                    ],
                    androidUiSettings: AndroidUiSettings(
                      toolbarTitle: 'การตัดรูป',
                      toolbarColor: Colors.green[700],
                      toolbarWidgetColor: Colors.white,
                      activeControlsWidgetColor: Colors.green[700],
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: false,
                    ),
                    iosUiSettings: IOSUiSettings(
                      minimumAspectRatio: 1.0,
                    ),
                  );
                  if (croppedFile != null) {
                    setState(() {
                      imagePath = croppedFile.path;
                      uploadPic(croppedFile);
                      print(imagePath);
                    });
                  }
                }
              },
            ),
          ),
        ],
      );

  Widget buildUsername() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 60,
              child: Text('ชื่อผู้ใช้ :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('$username',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildPassword() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 65,
              child: Text('รหัสผ่าน :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text('$password',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildTel() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 67,
              child: Text('เบอร์โทร :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text('$tel',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildType() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 65,
              child: Text('ประเภท :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text('$type',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildButtonEdit() => Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(10),
      child: ElevatedButton.icon(
        onPressed: () => goToEditUser(),
        label: Text('แก้ไขข้อมูล'),
        icon: Icon(Icons.edit),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
        ),
      ));

  // อัปโหลดรูปภาพ
  Future uploadPic(File _image) async {
    FocusScope.of(context).unfocus();

    // แสดง Progress
    Utils.showProgress(context);

    if (_image == null) {
      // ถ้าไม่มีรูปให้แสดง SnackBar
      Utils.showSnackBar(context, 'กรุณาเลือกรูปก่อน');
      Utils.hideProgress(context); // ซ่อน Loading
      return;
    } else {
      // ถ้ามีรูปให้ทำการอัพโหลด

      String fileName = DateTime.now().toString() + ".jpg";
      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child("User/$fileName").putFile(_image);
      if (snapshot.state == TaskState.success) {
        // ถ้าอัปโหลดสำเร็จ จะรับค่า Url มา
        final String url = await snapshot.ref.getDownloadURL();

        // ลบรูปเก่าออก
        // if (photo_before != '') {
        //   await FirebaseApi.removePhoto(photo_before);
        // }

        // อัปเดต Url อันใหม่
        prefs.setString('photo', url);
        FirebaseFirestore.instance
            .collection('user')
            .doc(user_id)
            .update({'photo': url});

        Utils.hideProgress(context); // ซ่อน Loading

        setState(() {
          photo_before = url;
        });
      } else {
        Utils.hideProgress(context); // ซ่อน Loading
        Utils.showSnackBar(
            context, 'เกิดข้อผิดพลาด กรุณาลองใหม่'); // แสดง SnackBar
        return;
      }
    }
  }

  // ไปหน้า EditUserPage
  void goToEditUser() {
    final user = User(
        user_id: user_id,
        username: username,
        password: password,
        tel: tel,
        type: type,
        photo: '');

    // ไปหน้า EditUserPage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditUserPage(user: user, from: 'user'),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multipurpose/model/expense.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multipurpose/model/user.dart';
import 'package:multipurpose/page/tab/home_page.dart';

// ไฟล์สำหรับจัดการข้อมูลใน firebase
class FirebaseApi {
  // ลบข้อมูล user
  static Future deleteUser(User user) async {
    final docUser =
        FirebaseFirestore.instance.collection('user').doc(user.user_id);

    await docUser.delete();
  }

  // สร้าง user
  static Future<String> createUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('user').doc();

    user.user_id = docUser.id;
    await docUser.set(user.toJson());

    return docUser.id;
  }

  // อัพเดต user
  static Future updateUser(User user) async {
    final docUser =
        FirebaseFirestore.instance.collection('user').doc(user.user_id);

    await docUser.update(user.toJson());
  }

  // ลบรูปภาพ
  static Future removePhoto(String photo_before) async {
    await FirebaseStorage.instance
        .refFromURL(photo_before)
        .delete()
        .then((value) => print('Delete Success'));
  }

  // รับค่า id แล้วคืนกลับไปยังฟังก์ชั่นที่เรียก
  static Future<String> getId(String data, String type) async {
    String doc_id;
    final snapshot = await FirebaseFirestore.instance
        .collection(type)
        .where(type, isEqualTo: data)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        doc_id = result.data()['doc_id'];
      });
    });

    return doc_id;
  }

  // คำนวณราคารวม แล้วคืนกลับไปยังฟังก์ชันที่เรียก
  static Future<int> getSumCostDayMonthYear(String data, String type) async {
    int sum = 0;
    await FirebaseFirestore.instance
        .collection('expense')
        .where(type, isEqualTo: data)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        sum += result.data()['price'];
      });
    });
    return sum;
  }

  // คำนวณรายรับรายจ่ายรวม แล้วคืนกลับไป
  static Future<int> getSumExpense(int selectindex) async {
    int sum = 0;
    if (selectindex == 0) {
      await FirebaseFirestore.instance
          .collection('expense')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          sum += result.data()['price'];
        });
      });
    } else if (selectindex == 1) {
      await FirebaseFirestore.instance
          .collection('expense')
          .where('type', isEqualTo: 'income')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          sum += result.data()['price'];
        });
      });
    } else {
      await FirebaseFirestore.instance
          .collection('expense')
          .where('type', isEqualTo: 'expense')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          sum += result.data()['price'];
        });
      });
    }
    return sum;
  }

  // แยก expense ของวันเดือนปี เพื่อนำไปคำนวณ
  static void getDataDayMonthYearAll(String type) async {
    await FirebaseFirestore.instance
        .collection('expense')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        var data;
        if (type == 'day') {
          data = result.data()['day'];
          Timer(const Duration(seconds: 3), () {
            updateData(data, type);
          });
        } else if (type == 'month') {
          data = result.data()['month'];
          updateData(data, type);
        } else {
          data = result.data()['year'];
          updateData(data, type);
        }
      });
    });
  }

  // อัพเดตข้อมูล
  static void updateData(String data, String type) async {
    final ref = FirebaseFirestore.instance.collection(type).doc();

    final snapshot_day = await FirebaseFirestore.instance
        .collection(type)
        .where(type, isEqualTo: data)
        .get();

    snapshot_day.docs.length == 0
        ? await ref.set({
            'doc_id': ref.id,
            'price': await getSumCostDayMonthYear(data, type),
            type: data,
            'createdTime': DateTime.now(),
          })
        : await FirebaseFirestore.instance
            .collection(type)
            .doc(await getId(data, type))
            .update({'price': await getSumCostDayMonthYear(data, type)});
  }

  // เช็คว่า collection day,month,year มีข้อมูลว่างหรือไม่
  static void checkExpenseEmtry(String type) async {
    await FirebaseFirestore.instance
        .collection(type)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        if (type == 'day') {
          var data = result.data()['day'];
          DeleteDayMonthYear(data, 'day');
        } else if (type == 'month') {
          var data = result.data()['month'];
          DeleteDayMonthYear(data, 'month');
        } else {
          var data = result.data()['year'];
          DeleteDayMonthYear(data, 'year');
        }
      });
    });
  }

  // ลบข้อมูลใน expense
  static void DeleteDayMonthYear(String data, String type) async {
    final snapshot_day = await FirebaseFirestore.instance
        .collection('expense')
        .where(type, isEqualTo: data)
        .get();

    if (snapshot_day.docs.length == 0)
      await FirebaseFirestore.instance
          .collection(type)
          .doc(await getIdDayMonthYear(data, type))
          .delete();
  }

  // รับค่า id แล้วคืนกลับไป
  static Future<String> getIdDayMonthYear(String data, String type) async {
    String doc_id;
    final snapshot = await FirebaseFirestore.instance
        .collection(type)
        .where(type, isEqualTo: data)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        doc_id = result.data()['doc_id'];
      });
    });

    return doc_id;
  }

  // อัพโหลดรูปภาพลง firestorage
  static Future uploadPic(File _image) async {
    if (_image == null) {
      return '';
    } else {
      String fileName = DateTime.now().toString() + ".jpg";
      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child("Slip/$fileName").putFile(_image);
      if (snapshot.state == TaskState.success) {
        final String url = await snapshot.ref.getDownloadURL();
        return url;
      }
    }
  }

  // แลดง popup เพื่อลบข้อมูล
  static Future deleteExpense(BuildContext context, Expense expense) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('⭐ แจ้งเตือน'),
            content: new Text('คุณต้องการลบข้อมูลรายการ ใช่หรือไม่?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('ไม่ใช่'),
              ),
              TextButton(
                onPressed: () async {
                  await deleteExpenseData(expense.expense_id);
                  FirebaseApi.getDataDayMonthYearAll('day');
                  FirebaseApi.getDataDayMonthYearAll('month');
                  FirebaseApi.getDataDayMonthYearAll('year');

                  FirebaseApi.checkExpenseEmtry('day');
                  FirebaseApi.checkExpenseEmtry('month');
                  FirebaseApi.checkExpenseEmtry('year');
                  FirebaseApi.deleteGraph(expense.name, expense.type);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(from: 'income')),
                    (Route<dynamic> route) => false,
                  );
                },
                child: new Text('ใช่'),
              ),
            ],
          ),
        )) ??
        false;
  }

  // ข้อมูล expense
  static Future deleteExpenseData(String expense_id) async {
    await FirebaseFirestore.instance
        .collection('expense')
        .doc(expense_id)
        .delete();
  }

  // รับค่า id ของ note_month แล้วคืนกลับไป
  static Future<String> getIdNoteMonth(String month) async {
    String doc_id;
    final snapshot = await FirebaseFirestore.instance
        .collection('note_month')
        .where('month', isEqualTo: month)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        doc_id = result.data()['note_month_id'];
      });
    });
    return doc_id;
  }

  // ลบ note
  static Future deleteNote(String note_id) async {
    await FirebaseFirestore.instance.collection('note').doc(note_id).delete();
  }

  // เช็คข้อมูล note เพื่อลบ note_month
  static Future deleteNoteMonth(String month) async {
    final snapshotNote = await FirebaseFirestore.instance
        .collection('note')
        .where('month', isEqualTo: month)
        .get();

    if (snapshotNote.docs.length == 0) {
      await FirebaseFirestore.instance
          .collection('note_month')
          .doc(await getIdNoteMonth(month))
          .delete();
    }
  }

  // เพิ่ม note_month
  static void addNoteMonth(String month, String user_id) async {
    final ref = FirebaseFirestore.instance.collection('note_month').doc();

    final snapshotDay = await FirebaseFirestore.instance
        .collection('note_month')
        .where('month', isEqualTo: month)
        .where('user_id', isEqualTo: user_id)
        .get();

    if (snapshotDay.docs.length == 0) {
      await ref.set({
        'note_month_id': ref.id,
        'month': month,
        'user_id': user_id,
        'color': true,
        'createdTime': DateTime.now(),
      });
    }
  }

  // อัพเดท color ใน note_month เป็น true ทั้งหมด
  static Future updateAllNoteMonthInit() async {
    await FirebaseFirestore.instance
        .collection('note_month')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'color': true});
      }
    });
  }

  // อัพเดต color ใน note_month
  static Future updateNoteMonth(String noteMonthId) async {
    await FirebaseFirestore.instance
        .collection('note_month')
        .where('note_month_id', isNotEqualTo: noteMonthId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'color': false});
      }
    }).whenComplete(() async => await FirebaseFirestore.instance
            .collection('note_month')
            .doc(noteMonthId)
            .update({'color': true}));

    // await FirebaseFirestore.instance
    //     .collection('note_month')
    //     //.where("note_month_id", isNotEqualTo: noteMonthId)
    //     .get()
    //     .then((snapshot) {
    //   for (DocumentSnapshot ds in snapshot.docs) {
    //     ds.reference.update({'color': false});
    //   }
    // }).whenComplete(() async => await FirebaseFirestore.instance
    //         .collection('note_month')
    //         .doc(noteMonthId)
    //         .update({'color': true}));
  }

  // รับค่า id แล้วคืนกลับไป
  static Future<String> getIdGraph(String name) async {
    String docId;
    await FirebaseFirestore.instance
        .collection('graph')
        .where('name', isEqualTo: name)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        docId = result.data()['graph_id'];
      });
    });
    return docId;
  }

  // คำนวณราคารวม แล้วคืนกลับไป
  static Future<int> getSumPriceGraph(String name) async {
    int sum = 0;
    await FirebaseFirestore.instance
        .collection('expense')
        .where('name', isEqualTo: name)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        sum += result.data()['price'];
      });
    });
    return sum;
  }

  // รับค่า name , price , type แล้วส่งไป updateGraph
  static void getDataGraphAll() async {
    await FirebaseFirestore.instance
        .collection('expense')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        var name = result.data()['name'];
        var price = result.data()['price'];
        var type = result.data()['type'];

        updateGraph(name, type);
      });
    });
  }

  // อัพเดต graph
  static void updateGraph(String name, String type) async {
    final ref = FirebaseFirestore.instance.collection('graph').doc();

    final snapshotGraph = await FirebaseFirestore.instance
        .collection('graph')
        .where('name', isEqualTo: name)
        .get();

    (snapshotGraph.docs.length == 0)
        ? await ref.set({
            'graph_id': ref.id,
            'name': name,
            'price': await FirebaseApi.getSumPriceGraph(name),
            'type': type,
            'createdTime': DateTime.now(),
          })
        : await FirebaseFirestore.instance
            .collection('graph')
            .doc(await FirebaseApi.getIdGraph(name))
            .update({
            'price': await FirebaseApi.getSumPriceGraph(name),
          });
  }

  // ลบ graph
  static Future deleteGraph(String name, String type) async {
    final snapshotGraph = await FirebaseFirestore.instance
        .collection('expense')
        .where('name', isEqualTo: name)
        .get();

    (snapshotGraph.docs.length == 0)
        ? await FirebaseFirestore.instance
            .collection('graph')
            .doc(await getIdGraph(name))
            .delete()
        : FirebaseApi.updateGraph(name, type);
  }
}

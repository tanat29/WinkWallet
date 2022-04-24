import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multipurpose/model/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multipurpose/page/note/note_edit.dart';
import 'package:multipurpose/page/tab/home_page.dart';
import 'package:multipurpose/api/firebase_api.dart';
import 'package:multipurpose/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteAllPage extends StatefulWidget {
  @override
  _NoteAllPage createState() => _NoteAllPage();
}

class _NoteAllPage extends State<NoteAllPage> {
  // ประกาศตัวแปร
  String month = '';
  SharedPreferences prefs;
  String user_id;
  bool btnColor = true;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    FirebaseApi.updateAllNoteMonthInit();
    load_user_id();
  }

  // โหลดข้อมูล SharedPreferences
  Future load_user_id() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      // เก็บข้อมูล user_id
      user_id = prefs.getString('user_id');
    });
  }

  // เมื่อกดย้อนกลับ
  Future<bool> BackPress() async {
    return (await goBack(context)) ?? false;
  }

  @override // กำหนด UI
  Widget build(BuildContext context) {
    final today = Utils.getDateThai(); // กำหนดวันที่ ณ ปัจจุบัน

    return new WillPopScope(
        onWillPop: BackPress,
        // เรียงจากบนลงล่าง
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70.0,
              child: StreamBuilder<QuerySnapshot>(
                // โหลด firebase collection note_month
                stream: FirebaseFirestore.instance
                    .collection('note_month')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center();
                  } else
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
                          child: Wrap(
                            spacing: 10,
                            children: snapshot.data.docs
                                .map(
                                  (doc) => ElevatedButton(
                                    child: Text(doc['month'],
                                        style: new TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                    onPressed: () {
                                      setState(() {
                                        FirebaseApi.updateNoteMonth(
                                            doc['note_month_id']);
                                        month = doc['month'];
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: doc['color'] == true
                                            ? Colors.green
                                            : Colors.grey),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    );
                },
              ),
            ),
            // โหลดข้อมูล firebase collection note
            StreamBuilder<QuerySnapshot>(
              stream: month == ''
                  // ถ้า month ว่างจากแสดงอันแรก ถ้าไม่ว่างจากแสดงอันหลัง
                  ? FirebaseFirestore.instance
                      .collection('note')
                      .orderBy(NoteField.createdTime, descending: true)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('note')
                      .where('month', isEqualTo: month)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center();
                } else
                  return ListView(
                    padding: EdgeInsets.all(10),
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    children: snapshot.data.docs.map((doc) {
                      Note note = Note(
                        note_id: doc['note_id'],
                        name: doc['name'],
                        detail: doc['detail'],
                        day: doc['day'],
                        month: doc['month'],
                        user_id: doc['user_id'],
                        time: doc['time'],
                      );
                      return noteList(context, note, today);
                      // return user_id == note.user_id
                      //     ? NoteList(context, note, today)
                      //     : Container();
                    }).toList(),
                  );
              },
            ),
          ],
        ));
  }

  Widget noteList(BuildContext context, Note note, String today) => Slidable(
      actionPane: SlidableDrawerActionPane(),
      key: Key(note.note_id),
      actions: [
        // ปัดซ้ายเป็น แก้ไข
        IconSlideAction(
          color: Colors.green,
          onTap: () {
            // ไปหน้า NoteEditPage
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NoteEditPage(note: note)));
          },
          caption: 'แก้ไข',
          icon: Icons.edit,
        )
      ],
      secondaryActions: [
        // ปัดขวาเป็นลบ
        IconSlideAction(
          color: Colors.red,
          caption: 'ลบ',
          onTap: () {
            Utils.confirmDelete(context, note);
          },
          icon: Icons.delete,
        )
      ],
      child: Card(
          child: Container(
        // แสดงข้อมูลจากบนลงล่าง
        child: Column(
          children: [
            buildDayAndCost(today, note.day, note.time),
            buildName(context, note.name),
            buildDetail(note),
          ],
        ),
        padding: EdgeInsets.all(10),
      )));

  // แสดงชื่อรายการ
  Widget buildName(BuildContext context, String name) => Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        ],
      );

  // แสดงข้อมูล
  Widget buildDetail(Note note) => Column(
        children: [
          Container(
              margin: EdgeInsets.fromLTRB(10, 4, 0, 0),
              // ถ้าข้อความเกิน 160 จะใช้ TextWrapper ถ้าไม่เกินใช้ text ธรรมดา
              child: note.detail.length > 160
                  ? TextWrapper(
                      text: note.detail,
                    )
                  : Align(
                      child: Text(
                        note.detail,
                        style: const TextStyle(fontSize: 16),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                      alignment: Alignment.topLeft,
                    ))
        ],
      );

  // แสดงข้อความวันหรือเวลา
  Widget buildDayAndCost(String today, String day, String time) => Align(
        alignment: Alignment.topRight,
        child: Text(
          today == day ? time : day,
          style: TextStyle(fontSize: 13),
        ),
      );

  goBack(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage(from: 'login')),
      (Route<dynamic> route) => false,
    );
  }
}

// กล่องข้อความ
class TextWrapper extends StatefulWidget {
  const TextWrapper({Key key, @required this.text}) : super(key: key);

  final String text;

  @override
  _TextWrapperState createState() => _TextWrapperState();
}

class _TextWrapperState extends State<TextWrapper>
    with TickerProviderStateMixin {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: ConstrainedBox(
              constraints: isExpanded
                  ? const BoxConstraints()
                  : const BoxConstraints(maxHeight: 70),
              child: Text(
                widget.text,
                style: const TextStyle(fontSize: 16),
                softWrap: true,
                overflow: TextOverflow.fade,
              ))),
      isExpanded
          ? TextButton.icon(
              icon: const Icon(Icons.arrow_upward),
              label: const Text('ย่อลง'),
              onPressed: () => setState(() => isExpanded = false))
          : TextButton.icon(
              icon: const Icon(Icons.arrow_downward),
              label: const Text('อ่านต่อ'),
              onPressed: () => setState(() => isExpanded = true)),
    ]);
  }
}

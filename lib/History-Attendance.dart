import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/src/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'QRScanner.dart';
import 'StudentInfoWithNavBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    home: HistoryAttendance('','','' as QRViewController),
  ));
}

class ClassInfo {
  final String course;
  final String date;
  final String period;
  final String day;
  final String section;
  final String registerTime;
  final bool present;

  ClassInfo(
  this.course,
  this.date,
  this.period,
  this.day,
  this.section,
  this.registerTime,
  this.present,
  );
}

class HistoryAttendance extends StatefulWidget {

  String? name;
  String? id;
  final QRViewController? controller;

  HistoryAttendance(this.name, this.id, this.controller);

  @override
  _HistoryAttendanceState createState() => _HistoryAttendanceState(name, id,controller);
}

class _HistoryAttendanceState extends State<HistoryAttendance> {

  String? name;
  String? id;
  QRViewController? controller;
  late RefreshController _refreshController;

  _HistoryAttendanceState(this.name, this.id, this.controller);
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  List<ClassInfo> historyAttendance = [];

  Future<void> fillHistoryAttendance() async {
    try {
      historyAttendance.clear();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collectionGroup("ID")
          .get();
      querySnapshot.docs.forEach((DocumentSnapshot document) async {
        if(document.id == id ){
          String documentPath = document.reference.path;
          List<String> pathSegments = documentPath.split('/');
          String instructorID = pathSegments[1];
          String classID = pathSegments[3];
          String date = pathSegments[5];
          DocumentSnapshot nameQuery = await FirebaseFirestore.instance
              .collection('instructors')
              .doc(instructorID)
              .collection('classes')
              .doc(classID)
              .get();
          List<String> pathDate = date.split(':');
          String year = pathDate[0];
          String month = pathDate[1].padLeft(2, '0');
          String day = pathDate[2].padLeft(2, '0');
          String dateString = '$year-$month-$day';
          DateTime dateTime = DateTime.parse(dateString);
          String dayOfWeek = DateFormat('EEEE').format(dateTime);

          ClassInfo newClass = ClassInfo(nameQuery.get('Name') as String,
              date as String,
              '${nameQuery.get('StartPeriod')}',
              dayOfWeek,
              nameQuery.get('Section') as String,
              document.get('Time') as String,
              document.get('Check')
          );
          if (!historyAttendance.contains(newClass)) {
            setState(() {
              historyAttendance.add(newClass);
            });
          }
        }
        historyAttendance.sort((a, b) => b.date.compareTo(a.date));
        _refreshController.refreshCompleted();
      });
    } catch (e) {
    }
  }
  Future<void> _onRefresh() async {
    await fillHistoryAttendance();
    createTutorial();
  }
  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }
  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.red,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
      getBoolSave();
    },
      onSkip: () {
        getBoolSave();
        return true;
      },
    );
  }

  @override
  void initState() {
    _onRefresh();
    Future.delayed(const Duration(seconds: 2), getBool);
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[Text('Attendance History'), Text('QR Scanner'), Text('Student Information'),];

  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('HistoryAttendance') ?? false;
    if (!skipT) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }
  void getBoolSave() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('HistoryAttendance', true);
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        controller?.resumeCamera();
        Navigator.pop(context, MaterialPageRoute(builder: (context) => QRScannerPage(name, id))) ;
      }
      if (index == 2) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentInfoPage(name, id,controller)));
      }
    });
  }
  List<LinearGradient> gradients = [
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFFAFAFA), Color(0xFFEAEAEA)],
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDCB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA11300),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Attendance History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
                Text(
                  'ID: ${id ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                )
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[IconButton(
          icon: const Icon(Icons.help),
          onPressed: () {
            showTutorial();
          },
        ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6B0B00), Color(0xFFC91400)],
            ),
          ),
        ),
      ),
        body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: const WaterDropMaterialHeader(
          backgroundColor: Color(0xFFA11300),
          color: Colors.white,
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFDF3), Color(0xFFFFFDCB)],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: historyAttendance.isEmpty
                        ? Center(key: keyButton1,
                      child: const Text(
                        'No attendance history available.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: historyAttendance.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Container(
                            margin: const EdgeInsets.all(5),
                            key: index == 0 ? keyButton1 : null,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 1.5,
                              offset: const Offset(2.7, 2.7),
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.bottomLeft,
                            colors: [Color(0xFFFFFFFF), Color(0xDFF1F1F1)],
                          ),
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFB1B1B2)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ExpansionTile(
                      title: Text('Course: ${entry.value.course}   \nDate: ${entry.value.date}  '),
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.fromLTRB(30.0, 4, 30, 4),
                              child: const Text(
                                'Day:',
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(30.0, 4, 30, 4),
                              child: Text(
                                entry.value.day,
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.fromLTRB(30.0, 4, 30, 4),
                              child: const Text(
                                'Section:',
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(30.0, 4, 30, 4),
                              child: Text(
                                entry.value.section,
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.fromLTRB(30.0, 4, 30, 4),
                              child: const Text(
                                'Period:',
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(30.0, 4, 30, 4),
                              child: Text(
                                entry.value.period,
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.fromLTRB(30.0, 4, 30, 4),
                              child: const Text(
                                'Register Time:',
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(30.0, 4, 30, 4),
                              child: Text(
                                entry.value.registerTime,
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.fromLTRB(12.0, 4, 10, 4),
                              child: const Text('Present:'),
                            ),
                            if (entry.value.present)
                              const Icon(Icons.check, color: Colors.green)
                            else
                              const Icon(Icons.close, color: Colors.red),
                          ],
                        ),
                      ],
                    ));
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    ),

        bottomNavigationBar:Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffcecece)),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFECECEC),
                Color(0xFFFFFFFF),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: BottomNavigationBar(
            key: keyButton2,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Attendance History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code),
                label: 'QR Scanner',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Student Information',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFFA11300),
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIconTheme: const IconThemeData(size: 30),
            unselectedIconTheme: const IconThemeData(size: 24),
            showSelectedLabels: true,
            showUnselectedLabels: false,
          ),
        )
    );
  }
  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "keyBottom1",
        keyTarget: keyButton1,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Attendants List",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "You can expand to show more information",
                    style: TextStyle(fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
      ),
    );
    targets.add(
      TargetFocus(
        identify: "keyBottomNavigation1",
        keyTarget: keyButton2,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "You are here",
                    style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "QR Scanner",
                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "tap to open",
                    style: TextStyle(fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Student Info",
                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "tap to open",
                    style: TextStyle(fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
      ),
    );
    return targets;
  }
}

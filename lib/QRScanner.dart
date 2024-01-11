import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lit_starfield/view/lit_starfield_container.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'History-Attendance.dart';
import 'StudentInfoWithNavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';

void main() {
  runApp(MaterialApp(
    home: StudentInfoPage('', '','' as QRViewController),
  ));
}

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
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

class QRScannerPage extends StatefulWidget {
  String? name;
  String? id;

  QRScannerPage(this.name, this.id);

  @override
  _QRScannerPageState createState() => _QRScannerPageState(name, id);
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {

  String? name;
  String? id;

  _QRScannerPageState(this.name, this.id);

  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('QRScannerPage') ?? false;
    if (!skipT) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }
  void getBoolSave() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('QRScannerPage', true);
  }
  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }
  void _dismissLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog();
      },
    );
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

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        controller?.pauseCamera();
        _navigateWithSlideTransition(HistoryAttendance(name, id,controller));
      }
      if (index == 2) {
        controller?.pauseCamera();
        _navigateWithSlideTransition(StudentInfoPage(name, id,controller), fromRight: true);
      }
    });
  }

  void _navigateWithSlideTransition(Widget page, {bool fromRight = false}) {
    PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = fromRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
        var end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
    Navigator.of(context).push(pageRouteBuilder);
  }
  QRViewController? controller;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    createTutorial();
    Future.delayed(Duration.zero, getBool);
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
        reverseCurve: Curves.linear,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller?.dispose();
    super.dispose();
  }

  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String deviceId = androidInfo.androidId;
    return deviceId;
  }

  Future<void> addAttendance(String instructorID, String deviceID, String classID, String date, String time, String id) async {
    DocumentReference<Map<String, dynamic>> Check = FirebaseFirestore.instance
        .collection('instructors')
        .doc(instructorID)
        .collection('classes')
        .doc(classID)
        .collection('Attendance')
        .doc(date);
    final DocumentSnapshot<Map<String, dynamic>> CheckSnap = await Check.get();
    if (!CheckSnap.exists){
      await Check.set({'date': date});
    }

    DocumentReference<Map<String, dynamic>> attendanceDocument = FirebaseFirestore.instance
        .collection('instructors')
        .doc(instructorID)
        .collection('classes')
        .doc(classID)
        .collection('Attendance')
        .doc(date)
        .collection('ID')
        .doc(id);

    final DocumentSnapshot<Map<String, dynamic>> attendanceSnapshot = await attendanceDocument.get();
    if (!attendanceSnapshot.exists) {
      await attendanceDocument.set({
        'Device ID': deviceID,
        'Class ID': classID,
        'Time': time,
        'Check': true,
      });
    }else if (attendanceSnapshot.exists) {
      if(attendanceSnapshot.get('Check') == false) {
        await attendanceDocument.set({
          'Device ID': deviceID,
          'Class ID': classID,
          'Time': time,
          'Check': true,
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmation = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (exitConfirmation) {
          SystemNavigator.pop();
        }
        return false;
      },
    child:Scaffold(
      backgroundColor: const Color(0xFFFFFDCB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFA11300),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'QR Code Scanner',
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
        body:Stack(
          children: [
            LitStarfieldContainer(
              animated: true,
              number: 100,
              velocity: 0.1,
              depth: 0.7,
              scale: 4,
              starColor: Colors.red,
              backgroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFFDF3),
                    Color(0xFFFFFDCB),
                    Color(0xFFFFFFFF),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            Center(
              key: keyButton1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unavailable on web',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'For security reasons',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  const Text(
                    'This feature is available only through the app.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ],
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
            currentIndex: 1,
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
    ) );
  }

  Widget scanningAnimation() {
    return AnimatedBuilder(
      animation: _animationController,key: keyButton1,
      builder: (BuildContext context, Widget? child) {
        return Container(
          height: 3.0,
          width: 290,
          margin: EdgeInsets.only(top: 100.0 * _animation.value),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.4),
                blurRadius: 8.0,
                spreadRadius: 2.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        );
      },
    );
  }
  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        //paddingFocus: 300,
        identify: "keyBottom1",
        keyTarget: keyButton1,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "QR Code Scanner",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "You can get attend by scanning JICode",
                    style: TextStyle(fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "(Class QR Code)",
                    style: TextStyle(fontSize: 14,
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
                    "Attendance History",
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Student Information",
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


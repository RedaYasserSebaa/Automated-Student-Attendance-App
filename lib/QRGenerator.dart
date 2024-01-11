import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'Classes.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

void main() {
  runApp(MaterialApp(
    home: QRCodePage(
      'YourClassNameValue',
      'YourClassSectionValue',
        'YourClassIDValue',
        'YourinstructorIDValue',
    ),
  ));
}

class QRCodePage extends StatefulWidget {
  String? className;
  String? section;
  String? classID;
  String? instructorID;

  QRCodePage(this.className, this.section,this.classID,this.instructorID);

  @override
  QRCode createState() => QRCode(className!, section!,classID!, instructorID!);
}

class QRCode extends State<QRCodePage> {

  final String className;
  final String section;
  final String classID;
  final String instructorID;
  QRCode(this.className, this.section, this.classID,  this.instructorID);

  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton = GlobalKey();

  late String randomString;
  late Timer timer;
  late int countdown;
  late int theTime;
  DateTime currentTime = DateTime.now();
  DateTime today = DateTime.now();

  String qrdata () {
    String formattedTime = "${currentTime.hour}:${currentTime.minute}:${currentTime.second}";
    String formattedData = "${today.year}:${today.month}:${today.day}";

    String QrData = instructorID +'&'+ classID +'&'+ randomString +'&'+ formattedData +'&'+ formattedTime;
    return QrData;
  }
  @protected
  late QrImage qrImage;

  @override
  void initState() {
      super.initState();
      theTime = 5;
      countdown = theTime;
      randomString = generateRandomString(5);
      addQRData(qrdata());
      timer = Timer.periodic(Duration(seconds: theTime), (Timer t) {
        setState(() {
          currentTime = DateTime.now();
          randomString = generateRandomString(5);
          deleteQRData();
          addQRData(qrdata());
        });
      });
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          countdown = (countdown - 1) % (theTime + 1);
          if (countdown == 0) {
            final qrCode = QrCode(
              8,
              QrErrorCorrectLevel.H,
            )..addData(qrdata());
            qrImage = QrImage(qrCode);
            countdown = theTime;
          }
        });
      });
      final qrCode = QrCode(
        6,
        QrErrorCorrectLevel.H,
      )..addData(qrdata());
      qrImage = QrImage(qrCode);
      createTutorial();
      Future.delayed(Duration(seconds: 1), getBool);
  }

  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('QRCodePage') ?? false;
    print('$skipT');
    if (!skipT) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }
  void getBoolSave() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('QRCodePage', true);
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
        print("finish");
        getBoolSave();
      },
      onSkip: () {
        print("skip");
        getBoolSave();
        return true;
      },
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
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "QR Code",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "A unique QR code that students \n can scan for attendance",
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
        keyTarget: keyButton,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Close the QR Code",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Press the button to close the QR Code session\n"
                        "When you close the QR code, students who did not scan it will be marked as absent\n\n\n\n\n\n\n",
                    style: TextStyle(fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    return targets;
  }
  @visibleForTesting
  static const kDefaultPrettyQrDecorationImage = PrettyQrDecorationImage(
    image: AssetImage('assets/images/jic_logo.png'),
    position: PrettyQrDecorationImagePosition.embedded,padding: EdgeInsets.all(-100),scale: 0.25,
  );
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String generateRandomString(int length) {
    const String charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random random = Random();
    StringBuffer result = StringBuffer();
    for (int i = 0; i < length; i++) {
      int randomIndex = random.nextInt(charset.length);
      result.write(charset[randomIndex]);
    }

    return result.toString();
  }

  Future<void> addQRData(String QrData) async {
    CollectionReference<Map<String, dynamic>> attendanceCollection = FirebaseFirestore.instance
        .collection('instructors')
        .doc(instructorID)
        .collection('classes')
        .doc(classID)
        .collection('QRData');
    final QuerySnapshot<Map<String, dynamic>> attendanceSnapshot = await attendanceCollection.get();
      await attendanceCollection.add({
        'QR Data': QrData,
      });
  }

  void checkSt() async{
    DocumentReference<Map<String, dynamic>> Check = FirebaseFirestore.instance
        .collection('instructors')
        .doc(instructorID)
        .collection('classes')
        .doc(classID)
        .collection('Attendance')
        .doc("${today.year}:${today.month}:${today.day}");
    DocumentSnapshot<Map<String, dynamic>> CheckSnap = await Check.get();
    if (!CheckSnap.exists){
      await Check.set({'date': "${today.year}:${today.month}:${today.day}"});
    }
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('instructors')
          .doc(instructorID)
          .collection('classes')
          .doc(classID)
          .collection('Attendancelist')
          .get();
      querySnapshot.docs.forEach((DocumentSnapshot document) async {
        DocumentReference<Map<String, dynamic>> isIN = await FirebaseFirestore.instance
            .collection('/instructors/$instructorID/classes/$classID/Attendance')
            .doc("${today.year}:${today.month}:${today.day}")
            .collection('ID')
            .doc(document.id);
        final DocumentSnapshot<Map<String, dynamic>> attendanceSnapshot = await isIN.get();

        if(!attendanceSnapshot.exists) {
          await isIN.set({
            'Device ID': document.get('deviceId'),
            'Class ID': classID,
            'Time': "${currentTime.hour}:${currentTime.minute}:${currentTime.second}",
            'Check': false,
          });
        }
      });
    }

  Future<void> deleteQRData () async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('/instructors/$instructorID/classes/$classID/QRData')
        .get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
  }

  Widget build(BuildContext context) {
    double baseWidth = 393;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    DocumentReference<Map<String, dynamic>> classData =
    FirebaseFirestore.instance.collection('instructors').doc(instructorID).collection('classes').doc(classID);

    return WillPopScope(
        onWillPop: () async {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Record Students\' Absence?'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Any student who does not attend will be recorded as absent.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    deleteQRData();
                    dispose();
                    Navigator.pop(context, MaterialPageRoute(builder: (context) => ClassPage(instructorID)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Color(0xFFFFC251),
                        content: Text('Absent students are not registered.'),
                      ),
                    );
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    checkSt();
                    deleteQRData();
                    dispose();
                    Navigator.pop(context, MaterialPageRoute(builder: (context) => ClassPage(instructorID)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Color(0xFF198754),
                        content: Text('Absent students were registered.'),
                      ),
                    );
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: Text('Yes'),
                ),
              ],
            ),
          );
          return true;
        },
        child: Scaffold(
      backgroundColor: Color(0xFFFFFDCB),
      appBar: AppBar(
        backgroundColor: Color(0xFFA11300),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              className,
              style: TextStyle(fontSize: 20.0),
            ),
            Text(
              section,
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
        actions: <Widget>[IconButton(
          icon: const Icon(Icons.help),
          onPressed: () {
            showTutorial();
          },
        ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6B0B00), Color(0xFFC91400)],
            ),
          ),
        ),
      ),
          body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFDF3), Color(0xFFFFFDCB)],
                ),
              ),
              child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 70, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10.0),
                  Container(
                    width: 500,
                    height: 500,
                    alignment: Alignment.center,
                    child: PrettyQrView(
                      key: keyButton1,
                      qrImage: qrImage,
                      decoration: PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(
                          color: Color(0xFF004500),
                          roundFactor: 1,
                        ),
                        image: kDefaultPrettyQrDecorationImage,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color(0xFFA11300)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      key: keyButton,
                      onPressed: () async{
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Record Students\' Absence?'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Any student who does not attend will be recorded as absent.',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  deleteQRData();
                                  dispose();
                                  Navigator.pop(context, MaterialPageRoute(builder: (context) => ClassPage(instructorID)));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Color(0xFFFFC251),
                                      content: Text('Absent students are not registered.'),
                                    ),
                                  );
                                  Navigator.of(context).pop(false);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                ),
                                child: Text('No'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  checkSt();
                                  deleteQRData();
                                  dispose();
                                  Navigator.pop(context, MaterialPageRoute(builder: (context) => ClassPage(instructorID)));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Color(0xFF198754),
                                      content: Text('Absent students were registered.'),
                                    ),
                                  );
                                  Navigator.of(context).pop(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                ),
                                child: Text('Yes'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0 , vertical: 15.0 ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(width: 10.0),
                            Text('Close QR Code', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    )
        )
    );
  }
}


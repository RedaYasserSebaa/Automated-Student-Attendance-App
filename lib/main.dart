import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'InstructorLoginPage.dart';
import 'Intro.dart';
import 'WelcomeScreen.dart';

void main() {
  runApp(kIsWeb ? IntroApp() : MobileApp());
}

class IntroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder(
        builder: (context) {
          if (MediaQuery.of(context).orientation != Orientation.portrait) {
            void getBoolSaves() async{
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('doneWelcome', true);
              await prefs.setBool('ClassPage', true);
              await prefs.setBool('CreateClass', true);
              await prefs.setBool('HistoryAttendance', true);
              await prefs.setBool('InstructorLoginPage', true);
              await prefs.setBool('AttendanceReportPage', true);
              await prefs.setBool('ListReport', true);
              await prefs.setBool('StudentLoginPage', true);
              await prefs.setBool('QRScannerPage', true);
              await prefs.setBool('QRCodePage', true);
            }
            getBoolSaves();
            return InstructorLoginPage();
          } else {
            return const WelcomeScreen();
          }
        },
      ),
    );
  }
}

class MobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Mobile App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Intro(),
    );
  }
}

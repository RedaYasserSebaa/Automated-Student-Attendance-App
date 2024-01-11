import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart'; // Import the flip_card package
import 'package:qr_code_scanner/src/qr_code_scanner.dart';
import 'AboutUsPage.dart';
import 'History-Attendance.dart';
import 'QRScanner.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: StudentInfoPage('', '','' as QRViewController),
  ));
}

class StudentInfoPage extends StatefulWidget {
  String? name;
  String? id;
  QRViewController? controller;

  StudentInfoPage(this.name, this.id, this.controller);

  @override
  _StudentInfoPageState createState() => _StudentInfoPageState(name, id ,controller);
}

class _StudentInfoPageState extends State<StudentInfoPage> {
  String? name;
  String? id;
  QRViewController? controller;
  int flipCount = 0;
  final int maxFlipCount = 5;

  _StudentInfoPageState(this.name, this.id, this.controller);

  final RegExp idRegExp = RegExp(r'^[0-9]{9}$');
  final RegExp nameRegExp = RegExp(r'^[a-zA-Z\s\-]+$');

  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();

  void saveStudentInfo() async {
    setState(() {
      name = nameController.text;
      id = idController.text;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('StudentName', name!);
    await prefs.setString('StudentId', id!);
  }

  String? validateID(String value) {
    if (value.isEmpty) {
      return 'Please enter your ID.';
    }
    if (!idRegExp.hasMatch(value)) {
      return 'Please enter a valid ID (only 9 numbers are allowed).';
    }
    return null;
  }

  String? validateName(String value) {
    if (value.isEmpty) {
      return 'Please enter your name.';
    }
    if (!nameRegExp.hasMatch(value)) {
      return 'Please enter a valid name (only alphabets, spaces, and hyphens are allowed).';
    }
    return null;
  }

  int _selectedIndex = 2;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Attendance History'),
    Text('QR Scanner'),
    Text('Student Information'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HistoryAttendance(name, id,controller)));
      }
      if (index == 1) {
        controller?.resumeCamera();
        Navigator.pop(context, MaterialPageRoute(builder: (context) => QRScannerPage(name, id)));
      }
      if (index == 2) {
        /*Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => StudentInfoPage(name, id)));*/
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDCB),
      appBar: AppBar(
        backgroundColor: Color(0xFFA11300),
        title: Text(
          'Student',
          style: TextStyle(color: Color(0xFFF7F3F3)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6B0B00), Color(0xFFC91400)],
            ),
          ),
        ),
        centerTitle: true,
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
          child: buildCard(),
        ),
      )),
        bottomNavigationBar:Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffcecece)),
            gradient: LinearGradient(
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
            selectedItemColor: Color(0xFFA11300),
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIconTheme: IconThemeData(size: 30),
            unselectedIconTheme: IconThemeData(size: 24),
            showSelectedLabels: true,
            showUnselectedLabels: false,
          ),
        )
    );
  }

  Widget buildCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/jic_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              'Student Name:',
              style: TextStyle(
                color: Color(0xFFA11300),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              '$name',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'ID:',
              style: TextStyle(
                color: Color(0xFFA11300),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              '$id',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

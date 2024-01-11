import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'List.dart';

void main() {
  runApp(MaterialApp(
    home: AttendanceReportPage(
      'YourClassNameValue',
      'YourClassSectionValue',
      'YourClassIDValue',
      'InstructorIDValue',
    ),
  ));
}

class ClassInfo {
  final String sid;
  final String sname;
  final String stime;
  final bool Check;
  ClassInfo(this.sid, this.sname, this.stime,this.Check);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClassInfo &&
        other.sid == sid &&
        other.sname == sname &&
        other.stime == stime &&
        other.Check == Check;
  }

  @override
  int get hashCode {
    return sid.hashCode ^ sname.hashCode ^ stime.hashCode ^ Check.hashCode;
  }
}

class AttendanceReportPage extends StatefulWidget {
  String? className;
  String? section;
  String? classID;
  String? instructorID;

  AttendanceReportPage(this.className, this.section, this.instructorID, this.classID);

  @override
  _AttendanceReportPageState createState() => _AttendanceReportPageState(className!, section!, classID!, instructorID!);
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  final String className;
  final String section;
  final String classID;
  final String instructorID;
  List<ClassInfo> Attendance = [];
  late RefreshController _refreshController;

  _AttendanceReportPageState(this.className, this.section, this.instructorID, this.classID);

  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();

  String selectedDocumentId = '';
  List<String> documentIds = [];

  @override
  void initState() {
    createTutorial();
    Future.delayed(const Duration(seconds: 2), getBool);
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    loadDocumentIds();
  }
  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('AttendanceReportPage') ?? false;
    if (!skipT) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }
  void getBoolSave() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('AttendanceReportPage', true);
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
                    "Attendance List",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "This list shows each student's attendance through the course, with green representing attendance and red representing absence. ",
                    style: TextStyle(fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Edit Attendance",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Hold on the student to edit his attendance states",
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
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "\nDate",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "You can choose the date to show the list of any day",
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
        identify: "keyBottom1",
        keyTarget: keyButton3,
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
                    "Export Report",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Also you could export the list as CSV file",
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
        identify: "keyBottom1",
        keyTarget: keyButton4,
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
                    "Show List",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Press on the button to see all students in this course",
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
  Future<void> loadDocumentIds() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('/instructors/$instructorID/classes/$classID/Attendance').get();
    setState(() {
      documentIds = querySnapshot.docs.map((doc) => doc.id).toList();
      if (documentIds.isNotEmpty) {
        selectedDocumentId = documentIds[documentIds.length - 1];
      }
    });
    loadAttendanceFromFirestore();
  }

  Future<void> loadAttendanceFromFirestore() async {
    try {
      if (selectedDocumentId.isNotEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('instructors')
            .doc(instructorID)
            .collection('classes')
            .doc(classID)
            .collection('Attendance')
            .doc(selectedDocumentId)
            .collection('ID')
            .get();
        Attendance.clear();
        querySnapshot.docs.forEach((QueryDocumentSnapshot doc) async {
          String studentID = doc.id;
          String stime1 = doc.get('Time');
          DocumentSnapshot nameQuery =
          await FirebaseFirestore.instance.collection('names').doc(studentID).get();
          if (nameQuery.exists) {
            String sname1 = nameQuery.get('name');
            ClassInfo newClass = ClassInfo(studentID, sname1, stime1,doc.get('Check'));
            if (!Attendance.contains(newClass)) {
              setState(() {
                Attendance.add(newClass);
              });
            }
          } else {
          }
        });
        Attendance.sort((a, b) => int.parse(a.sid).compareTo(int.parse(b.sid)));
      } else {
      }
    } catch (e) {
    }
    _refreshController.refreshCompleted();
  }

  Future<void> _onRefresh() async {
    await loadAttendanceFromFirestore();
  }
  MaterialColor check(index)  {
    if(Attendance[index].Check){
      return Colors.green;
    }else{
      return Colors.red;
    }
  }

  void setPresent(String date, String id) async{
   FirebaseFirestore.instance
        .collection('instructors')
        .doc(instructorID)
        .collection('classes')
        .doc(classID)
        .collection('Attendance')
        .doc(date)
        .collection('ID')
        .doc(id)
        .update({'Check': true});
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       backgroundColor: const Color(0xFF4BAE50),
       content: Text('$id is marked present'),
     ),
   );
   _onRefresh();

  }
  void setAbsent(String date, String id) async{
    await FirebaseFirestore.instance
        .collection('instructors')
        .doc(instructorID)
        .collection('classes')
        .doc(classID)
        .collection('Attendance')
        .doc(date)
        .collection('ID')
        .doc(id)
        .update({'Check': false});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFF24237),
        content: Text('$id is marked absent'),
      ),
    );
    _onRefresh();
  }


  void _exportReportAsCSV() async {
    List<List<dynamic>> rows = [];
    rows.add(['Name', 'ID', 'Time', 'Attendance']);

    for (var i = 0; i < Attendance.length; i++) {
      rows.add([
        Attendance[i].sname,
        Attendance[i].sid,
        Attendance[i].stime,
        Attendance[i].Check ? 'Present' : 'Absent'
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    if (!kIsWeb) {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/attendance_report.csv');
      await file.writeAsString(csv);
      Share.shareFiles(['${directory.path}/attendance_report.csv'],
          text: 'Attendance Report');
    } else {
      downloadCSV(csv);
    }
  }
  downloadCSV(String file) async {
    // Convert your CSV string to a Uint8List for downloading.
    Uint8List bytes = Uint8List.fromList(utf8.encode(file));

    // This will download the file on the device.
    await FileSaver.instance.saveFile(
      name: 'document_name', // you can give the CSV file name here.
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDCB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA11300),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              className,
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              section,
              style: const TextStyle(fontSize: 14.0),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20.0),
                const Text(
                  '     Select Date:',
                  style: TextStyle(fontSize: 16, color: Color(0xFFA11300)),
                ),
                const SizedBox(height: 10.0),
                Container(key: keyButton2,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),margin: const EdgeInsets.fromLTRB(30.0, 4, 30, 0),
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
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFECECEC),
                        Color(0xFFFFFFFF),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFB1B1B2)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedDocumentId,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDocumentId = newValue ?? '';
                      });
                      _refreshController.requestRefresh();
                    },
                    items: documentIds.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Container(
                  key: keyButton1,
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
                  child: Align(
                    alignment: Alignment.center,
                    child: DataTable(
                      columnSpacing: 25.0,
                      columns: const [
                        DataColumn(
                          label: Center(
                            child: Text(
                              'No.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'ID',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Time',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        for (int index = 0; index < Attendance.length; index++)
                          DataRow(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Change Attendance State'),
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text('Name: ${Attendance[index].sname}\nID: ${Attendance[index].sid}'),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setAbsent(selectedDocumentId, Attendance[index].sid);
                                        Navigator.of(context).pop(false);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                      ),
                                      child: const Text('Absent'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setPresent(selectedDocumentId, Attendance[index].sid);
                                        Navigator.of(context).pop(false);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.green,
                                      ),
                                      child: const Text('Present'),
                                    ),
                                  ],
                                ),
                              );

                            },
                            cells: [
                              DataCell(
                                Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    '${Attendance[index].sname} ',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    Attendance[index].sid,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.centerRight,
                                        colors: [check(index).withOpacity(0.7), check(index).withOpacity(1)],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        ' ${Attendance[index].stime} ',
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    key: keyButton3,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color(0xFFA11300)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _exportReportAsCSV();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                      child: Text('Export Report', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    key: keyButton4,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color(0xFFA11300)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListReport(className,section,classID,instructorID,selectedDocumentId),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 43.0, vertical: 15.0),
                      child: Text('   Show List   ', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    )
    );
  }

}

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    home: ListReport('className','section','classID','instructorID','selectedDocumentId')));
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
class ListReport extends StatefulWidget {
  final String className;
  final String section;
  final String classID;
  final String instructorID;
  final String selectedDocumentId;
  const ListReport(this.className, this.section,this.classID,this.instructorID,this.selectedDocumentId);

  @override
  _ListReportState createState() => _ListReportState(className,section,classID,instructorID,selectedDocumentId);
}

class _ListReportState extends State<ListReport> {
  final String className;
  final String section;
  final String classID;
  final String instructorID;
  final String selectedDocumentId;
  List<ClassInfo> Attendance = [];
  late RefreshController _refreshController;

  _ListReportState(this.className, this.section,this.classID,this.instructorID,this.selectedDocumentId);
  List<String> documentIds = [];
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();

  @override
  void initState() {
    createTutorial();
    Future.delayed(const Duration(seconds: 2), getBool);
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
  }
  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('ListReport') ?? false;
    if (!skipT) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }
  void getBoolSave() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ListReport', true);
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
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                      Text(
                        "perform a swipe gesture on student",
                        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  Text(
                    "This allows you to remove any student that no longer in the class.",
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Add Student",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "You can simply add a student to the list",
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
  Future<void> loadAttendanceFromFirestore() async {
    _refreshController.refreshCompleted();
    DocumentSnapshot class1 = await FirebaseFirestore.instance
        .collection('instructors')
        .doc(instructorID)
        .collection('classes')
        .doc(classID).get();
    try {
      if (class1.exists) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('instructors')
            .doc(instructorID)
            .collection('classes')
            .doc(classID)
            .collection('Attendancelist')
            .get();
        Attendance.clear();
        querySnapshot.docs.forEach((QueryDocumentSnapshot doc) async {
          String studentID = doc.id;
          DocumentSnapshot nameQuery =
          await FirebaseFirestore.instance.collection('names').doc(studentID).get();
          if (nameQuery.exists) {
            String sname1 = nameQuery.get('name');
            ClassInfo newClass = ClassInfo(studentID, sname1, 'stime1', false);
            if (!Attendance.contains(newClass)) {
              setState(() {
                Attendance.add(newClass);
              });
            }
          } else {
          }
        });
        Attendance.sort((a, b) => int.parse(a.sid).compareTo(int.parse(b.sid)));
        _refreshController.refreshCompleted();
      } else {
      }
    } catch (e) {
    }
  }
  void deleteClass(int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete this class?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListReport(className,section,classID,instructorID,selectedDocumentId),
                  ),
                );// Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                CollectionReference<Map<String, dynamic>> classesCollection =
                FirebaseFirestore.instance
                    .collection('instructors')
                    .doc(instructorID)
                    .collection('classes')
                    .doc(classID)
                    .collection('Attendancelist');
                String classIdentifier = Attendance[index].sid;
                await classesCollection.doc(classIdentifier).delete();

                setState(() {
                  Attendance.removeAt(index);
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _onRefresh() async {
    await loadAttendanceFromFirestore();
  }

  Future<void> _showAddStudentDialog() async {
    String studentID = '';
    final RegExp idRegExp = RegExp(r'^[0-9]{9}$'); // Regex for student ID validation

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: TextField(
            keyboardType: TextInputType.number, // Set the keyboard type to numeric
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly // Allow only numeric input
            ],
            onChanged: (value) {
              studentID = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter Student ID',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFFA11300), // Your button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Your button's shape here
                ),
              ),
              onPressed: () async{
                if (idRegExp.hasMatch(studentID)) {
                  DocumentSnapshot nameQuery =
                  await FirebaseFirestore.instance.collection('names').doc(studentID).get();
                  if(nameQuery.exists) {
                    FirebaseFirestore.instance
                        .collection('instructors')
                        .doc(instructorID)
                        .collection('classes')
                        .doc(classID)
                        .collection('Attendancelist')
                        .doc(studentID).set({'deviceId': 'X'});

                    _onRefresh();
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid 9-digit student ID'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
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
              key: keyButton1,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20.0),
                Container(
                  color: Colors.white,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3), // Width for Name column
                      1: FlexColumnWidth(2), // Width for ID column
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFECECEC),
                                    Color(0xFFFFFFFF),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1.5,
                                    blurRadius: 5,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Name',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFECECEC),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1.5,
                                    blurRadius: 5,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'ID',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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
                const SizedBox(height: 15.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: Attendance.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFECECEC),
                              Color(0xFFFFFFFF),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Dismissible(
                          key: Key(Attendance[index].sid),
                          onDismissed: (direction) {
                            deleteClass(index);
                          },
                          background: Container(
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(0.5), // Width for Name column
                                1: FlexColumnWidth(3), // Width for ID column
                                2: FlexColumnWidth(2),
                              },
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 7),
                                        child: Center(
                                          child: Text(
                                            Attendance[index].sname,
                                            style: const TextStyle(fontSize: 18.0, color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 7),
                                        child: Center(
                                          child: Text(
                                            Attendance[index].sid,
                                            style: const TextStyle(fontSize: 18.0, color: Colors.black),
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
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color(0xFFA11300)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  key: keyButton2,
                  onPressed: () {
                    _showAddStudentDialog();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                    child: Text('Add Student', style: TextStyle(fontSize: 16, color: Colors.white)),
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


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'CreateClassPage.dart';
import 'InstructorReportPage.dart';
import 'QRGenerator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(home: ClassPage(''),));
}

class ClassInfo {
  final String id;
  final String className;
  final String section;

  ClassInfo(this.id, this.className, this.section);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClassInfo &&
        other.id == id &&
        other.className == className &&
        other.section == section;
  }

  @override
  int get hashCode {
    return id.hashCode ^ className.hashCode ^ section.hashCode;
  }
}

class ClassPage extends StatefulWidget {
  String? id;
  ClassPage(this.id);

  @override
  _ClassPageState createState() => _ClassPageState(id!);
}

class _ClassPageState extends State<ClassPage> {
  List<ClassInfo> classes = [];
  final String instructorID;
  late RefreshController _refreshController;

  _ClassPageState(this.instructorID);
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey delShow = GlobalKey();


  @override
  void initState() {
    createTutorial();
    Future.delayed(const Duration(seconds: 1), getBool);
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    loadClassesFromFirestore();
  }
  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('ClassPage') ?? false;
    if (!skipT) {
      Future.delayed(const Duration(seconds: 0), showTutorial);
    }
  }
  void getBoolSave() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ClassPage', true);
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Create Class",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Press on the button to create new class",
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
                    "Classes",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Here you will see all the classes that you have",
                    style: TextStyle(fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "\ntapping on the respective class name",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "This will provide you with detailed insights into attendance and access additional features.",
                    style: TextStyle(fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "\nYou can perform a swipe gesture on the respective class listing",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "This allows you to remove any classes you no longer need.",
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
        keyTarget: keyButton3,
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
                    "QR Code",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "when tapped, navigates to a page where students can attend the class by scanning the QR code.",
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
  void addClass(ClassInfo newClass) {
    if (!classes.contains(newClass)) {
      setState(() {
        classes.add(newClass);
        saveClasses();
      });
    }
  }

  void deleteClass(int index) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete this class?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? instructorID = prefs.getString('instructorID');
                CollectionReference<Map<String, dynamic>> classesCollection =
                FirebaseFirestore.instance.collection('instructors').doc(instructorID).collection('classes');
                String classIdentifier = classes[index].id;
                await classesCollection.doc(classIdentifier).delete();
                setState(() {
                  classes.removeAt(index);
                  saveClasses();
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!confirmDelete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ClassPage(instructorID),
        ),
      );
    } else if (confirmDelete == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClassPage(instructorID),
          )
      );
    }
  }

  void saveClasses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> classList =
    classes.map((e) => "${e.id}-${e.className}-${e.section}").toList();
    await prefs.setStringList('classes', classList);
  }

  Future<void> loadClassesFromFirestore() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      CollectionReference<Map<String, dynamic>> classesCollection =
      FirebaseFirestore.instance.collection('instructors').doc(
          prefs.getString('instructorID')).collection('classes');

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await classesCollection.get();
      classes.clear();
      querySnapshot.docs.forEach((DocumentSnapshot<Map<String, dynamic>> doc) {
        String className = doc.get('Name');
        String section = doc.get('Section');
        String id = doc.id;
        ClassInfo newClass = ClassInfo(id, className, section);
        if (!classes.contains(newClass)) {
          setState(() {
            classes.add(newClass);
          });
        }
      });
      _refreshController.refreshCompleted();
    } catch (e) {
    }
  }

  Future<void> _navigateToQRCodePage(String className, String section,
      String classID, instructorID) async {
    PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return QRCodePage(className, section, classID, instructorID);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
    await Navigator.of(context).push(pageRouteBuilder);
  }

  Future<void> _onRefresh() async {
    await loadClassesFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFDCB),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFA11300),
            title: const Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '       Classes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                    ),
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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFDF3), Color(0xFFFFFDCB)],
              ),
            ),
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              header: const WaterDropMaterialHeader(
                backgroundColor: Color(0xFFA11300),
                color: Colors.white,
              ),
              child: ListView.builder(
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                      key: index == 0 ? keyButton1 : Key('${classes[index].className}-${classes[index].section}'),
                      onDismissed: (direction) {
                        deleteClass(index);
                      },
                      background: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
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
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Color(0xFFFFFFFF), Color(0xDFF1F1F1)],
                          ),
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFB1B1B2)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceReportPage(
                                    classes[index].className,
                                    classes[index].section,
                                    classes[index].id,
                                    instructorID,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  classes[index].className,
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  classes[index].section,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Color(0xFF858585),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: InkWell(
                            onTap: () async {
                              await _navigateToQRCodePage(
                                classes[index].className,
                                classes[index].section,
                                classes[index].id,
                                instructorID,
                              );
                            },
                            child: KeyedSubtree(
                              key: index == 0 ? keyButton3 : null,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(12.0, 0, 8.0, 0),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: Color(0xFFB2B2B2),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.qr_code,
                                  size: 30.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: screenWidth < 600
              ? Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateClass(addClass),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    const Color(0xFFA11300)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: const Text('Create Classes'),key: keyButton2,
            ),
          )
              : Padding(
            padding: const EdgeInsets.fromLTRB(512, 16, 512, 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateClass(addClass),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFFA11300),
              ),
              child: const Text('Create Class'),
            ),
          ), // or SizedBox() or any other widget if you want to leave an empty space
        ));
  }
}

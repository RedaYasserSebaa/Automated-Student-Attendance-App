import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/Classes.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class CreateClass extends StatefulWidget {
  final Function(ClassInfo) onClassCreated;
  CreateClass(this.onClassCreated);
  @override
  _CreateClassState createState() => _CreateClassState();
}
Future<String> addCourse(String name, String section, int startPeriod, int endPeriod) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final courses = FirebaseFirestore.instance.collection('instructors').doc(prefs.getString('instructorID')).collection('classes');
  await courses.add({
    'Name': name,
    'Section': section,
    'StartPeriod': startPeriod,
    'EndPeriod': endPeriod,
  });
  return courses.id;
}
class _CreateClassState extends State<CreateClass> {
  String SectionNumberError = '';
  String periodError = '';
  TextEditingController courseNameController = TextEditingController();
  TextEditingController SectionNumberController = TextEditingController();
  int startPeriod = 1;
  int endPeriod = 1;

  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();

  @override
  void initState() {
    createTutorial();
    Future.delayed(Duration.zero, getBool);
    super.initState();
  }

  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('CreateClass') ?? false;
    if (!skipT) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }
  void getBoolSave() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('CreateClass', true);
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
                    "Course Name",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Type the course name",
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Section",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Type the section number for this course",
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
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Start Period",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Here you can select the first period of this course\n\n\n",
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
    targets.add(
      TargetFocus(
        identify: "keyBottomNavigation1",
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
                    "End Period",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Also you can select the end period of this course\n\n\n",
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
    targets.add(
      TargetFocus(
        identify: "keyBottomNavigation1",
        keyTarget: keyButton5,
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
                    "Create",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Press the button to create the new course\n",
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDCB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA11300),
        title: const Text(
          'Create Class',
          style: TextStyle(color: Color(0xFFF7F3F3)),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF3), Color(0xFFFFFDCB)],
          ),
        ),
        child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350.0,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffe1e1e1)),
              borderRadius: BorderRadius.circular(10.0),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFFAFAFA), Color(0xFFEAEAEA)],
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Course Name:',
                  style: TextStyle(color: Color(0xFFA11300)),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: courseNameController,key: keyButton1,
                  decoration: InputDecoration(
                    hintText: 'Enter course name',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Color(0xffdfdfe0)),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Section Number:',
                  style: TextStyle(color: Color(0xFFA11300)),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: SectionNumberController,key: keyButton2,
                  decoration: InputDecoration(
                    hintText: 'Enter section Number',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Color(0xffdfdfe0)),
                    ),
                    errorText:
                    SectionNumberError.isNotEmpty ? SectionNumberError : null,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  onChanged: (text) {
                    if (text.isNotEmpty &&
                        !RegExp(r'^[0-9]*$').hasMatch(text)) {
                      setState(() {
                        SectionNumberError =
                        'Section Number must contain only numbers';
                      });
                    } else {
                      setState(() {
                        SectionNumberError = '';
                      });
                    }
                  },
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Text(
                    'Start Period:',key: keyButton3,
                    style: const TextStyle(color: Color(0xFFA11300)),
                  ),
                ),
                const SizedBox(height: 10.0),
                CounterWidget(
                  onChanged: (value) {
                    setState(() {
                      startPeriod = value;
                      if (startPeriod > endPeriod) {
                        periodError =
                        'Start period cannot be greater than end period';
                      } else {
                        periodError = '';
                      }
                    });
                  },
                  counter: startPeriod,
                  isMinusDisabled: startPeriod == 1,
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Text(
                    'End Period:', key: keyButton4,
                    style: const TextStyle(color: Color(0xFFA11300)),
                  ),
                ),
                const SizedBox(height: 10.0),
                CounterWidget(
                  onChanged: (value) {
                    setState(() {
                      endPeriod = value;
                      if (endPeriod < startPeriod) {
                        periodError =
                        'End period cannot be less than start period';
                      } else {
                        periodError = '';
                      }
                    });
                  },
                  counter: endPeriod,
                  isMinusDisabled: endPeriod == 1,
                ),
                if (periodError.isNotEmpty)
                  Text(
                    periodError,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 30.0),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: keyButton5,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color(0xFFA11300)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () async{
                      if (validateInput()) {
                        if (startPeriod > endPeriod) {
                          setState(() {
                            periodError =
                            'Start period cannot be greater than end period';
                          });
                          return;
                        }
                        final newClass = ClassInfo(await addCourse(courseNameController.text, SectionNumberController.text, startPeriod, endPeriod),
                          courseNameController.text,
                          SectionNumberController.text,
                        );
                        widget.onClassCreated(newClass);
                        saveData(newClass);
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ClassPage(prefs.getString('instructorID'))));
                      }
                    },
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }

  bool validateInput() {
    if (courseNameController.text.isEmpty ||
        SectionNumberController.text.isEmpty || periodError.isNotEmpty) {
      setState(() {
        SectionNumberError = 'Both fields are required';
      });
      return false;
    }
    return true;
  }

  void saveData(ClassInfo newClass) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> classList = prefs.getStringList('classes') ?? [];
    classList.add("${newClass.id}-${newClass.className}-${newClass.section}");
    prefs.setStringList('classes', classList);
  }
}

  class CounterWidget extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int counter;
  final bool isMinusDisabled;

  CounterWidget({
    required this.onChanged,
    required this.counter,
    this.isMinusDisabled = false,
  });

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int counter;
  late bool isMinusDisabled;

  @override
  void initState() {
    super.initState();
    counter = widget.counter;
    isMinusDisabled = widget.isMinusDisabled;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: isMinusDisabled
              ? null
              : () {
            setState(() {
              counter--;
              if (counter == 1) {
                isMinusDisabled = true;
              }
              widget.onChanged(counter);
            });
          },
        ),
        Text('$counter', style: const TextStyle(fontSize: 18)),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              counter++;
              isMinusDisabled = false;
              widget.onChanged(counter);
            });
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'StudentLoginPage.dart';
import 'InstructorLoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/QRScanner.dart';
import 'package:lit_starfield/lit_starfield.dart';
import 'dart:ui';

void main() {
  runApp(MaterialApp(
    home: WelcomeScreen(),
  ));
}
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}
class WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey keyButton1 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: 87,
          backgroundColor: Color(0xFFA11300),
          title: Text(
            'Welcome',
            style: TextStyle(
              color: Color(0xFFF7F3F3),
              fontSize: 50,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[IconButton(
            key: keyButton1,
            icon: const Icon(Icons.help),
            onPressed: () {
              SaveFalse();
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => WelcomeScreen(),
                  transitionDuration: Duration(seconds: 0), // Set the duration to 0 seconds
                ),
              );
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
        body: SingleChildScrollView(
          child: SceneS(keyButton1: keyButton1),
        ),
      ),
    );
  }

  void SaveFalse() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('doneWelcome', false);
  }
}
class SceneS extends StatefulWidget {
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton1 = GlobalKey();

  SceneS({required this.keyButton1});

  @override
  Scene createState() => Scene();
}

class Scene extends State<SceneS> {
  late TutorialCoachMark tutorialCoachMark;

  GlobalKey keyButton = GlobalKey();

  @override
  void initState() {
      Future.delayed(Duration.zero, getBool);
      super.initState();
  }
  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('doneWelcome') ?? false;
    print('$skipT');
    if (!skipT) {
      createTutorial();
      Future.delayed(Duration.zero, showTutorial);
    }
  }
  void getBoolSave() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('doneWelcome', true);
  }
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

  @override
  Widget build(BuildContext context) {
    double baseWidth = 393;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmation = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false if the user cancels
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true if the user confirms
                },
                child: Text('Exit'),
              ),
            ],
          ),
        );

        if (exitConfirmation ?? false) {
          // If the user confirms, exit the app
          SystemNavigator.pop();
        }

        return false; // Always return false to prevent the default back navigation
      },
      child:Stack(
          children: [
            LitStarfieldContainer(
              animated: true,
              number: 100,
              velocity: 0.05,
              depth: 0.6,
              scale: 4,
              starColor: Color(0xFFFFB5B5),
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
            Container(
              width: double.infinity,
              height: screenHeight,
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(31 * fem, 27 * fem, 32 * fem, 108 * fem),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 15 * fem),
                            width: 388 * fem,
                            height: 269 * fem,
                            child: Image.asset(
                              'assets/images/jic_logo_big.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 2 * fem, 40 * fem),
                            constraints: BoxConstraints(
                              maxWidth: 319 * fem,
                            ),
                            child: Text(
                              'JICode',
                              textAlign: TextAlign.center,
                              style: TextStyle(shadows: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1.5,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                                fontFamily: 'Inter',
                                fontSize: 24 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 0.8333333333 * ffem / fem,
                                color: Color(0xff0e8f6e),
                              ),
                            ),
                          ),
                          Container(
                            key: keyButton,
                            margin: EdgeInsets.fromLTRB(16 * fem, 0 * fem, 15 * fem, 0 * fem),
                            padding: EdgeInsets.fromLTRB(17 * fem, 30 * fem, 17 * fem, 35 * fem),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xffcecece)),
                              borderRadius: BorderRadius.circular(15.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFFFAFAFA), Color(0xFFEAEAEA)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1.5,
                                  blurRadius: 5,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 18 * fem),
                                  child: Text(
                                    'Choose:',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: "Raleway",
                                      fontSize: 36 * ffem,
                                      fontWeight: FontWeight.bold,
                                      height: 0.6666666667 * ffem / fem,
                                      color: Color(0xffa11300),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 22),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                      minimumSize: Size(double.infinity, 65),
                                      primary: Color(0xffa11300),
                                      onPrimary: Color(0xff000000),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15 * fem),
                                        side: BorderSide(color: Color(0xff000000)),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Student',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 30 * ffem,
                                          fontWeight: FontWeight.w500,
                                          height: 0.6666666667 * ffem / fem,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => StudentLoginPage()),
                                      );                                  },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                      minimumSize: Size(double.infinity, 65),
                                      primary: Color(0xffa11300),
                                      onPrimary: Color(0xff000000),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(color: Color(0xff000000)),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Instructor',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 30 * ffem,
                                          fontWeight: FontWeight.w500,
                                          height: 0.6666666667 * ffem / fem,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => InstructorLoginPage()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
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
      onFinish: () async{
        print("finish");
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Skip All Further Tutorials?'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Access help anytime by tapping on ',
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.help, size: 20), // Adjust the size as needed
                      ),
                      TextSpan(
                        text: ' on top right.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  getBoolSave();
                  Navigator.of(context).pop(false); // Return false if the user cancels
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey, // Adjust the button color
                ),
                child: Text('Just for This Page'),
              ),
              ElevatedButton(
                onPressed: () {
                  getBoolSaves();
                  Navigator.of(context).pop(true); // Return true if the user confirms
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Adjust the button color
                ),
                child: Text('Skip All'),
              ),
            ],
          ),
        );
      },
      onSkip: () {
        print("skip");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Skip All Further Tutorials?'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Access help anytime by tapping on ',
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.help, size: 20), // Adjust the size as needed
                      ),
                      TextSpan(
                        text: ' on top right.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  getBoolSave();
                  Navigator.of(context).pop(false); // Return false if the user cancels
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey, // Adjust the button color
                ),
                child: Text('Just for This Page'),
              ),
              ElevatedButton(
                onPressed: () {
                  getBoolSaves();
                  Navigator.of(context).pop(true); // Return true if the user confirms
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Adjust the button color
                ),
                child: Text('Skip All'),
              ),
            ],
          ),
        );
        return true;
      },
    );
  }
  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "keyBottom1",
        keyTarget: widget.keyButton1,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Help",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "If you need any help tap here",
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
                    "Choose",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Choose whether you are a student or instructor\n\n\n",
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
}

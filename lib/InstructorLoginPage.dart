import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lit_starfield/view/lit_starfield_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'WelcomeScreen.dart';
import 'Classes.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: InstructorLoginPage(),
  ));
}

class InstructorLoginPage extends StatefulWidget {
  @override
  _InstructorLoginPageState createState() => _InstructorLoginPageState();
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

class _InstructorLoginPageState extends State<InstructorLoginPage> {
  final RegExp idRegExp = RegExp(r'^[0-9]{7}$');
  String? id;
  String? password;
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPassword = false;

  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton = GlobalKey();

  @override
  void initState() {
    createTutorial();
    Future.delayed(const Duration(milliseconds: 500), getBool);
    super.initState();
  }

  String? validateID(String value) {
    if (value.isEmpty) {
      return 'Please enter your ID.';
    }
    if (!idRegExp.hasMatch(value)) {
      return 'Please enter a valid ID (only 7 numbers are allowed).';
    }
    return null;
  }

  void _saveDataToSharedPreferences(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('instructorID', id);
    await prefs.setBool('isLogged', true);
  }

  bool isLoading = false;
  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }
  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('InstructorLoginPage') ?? false;
    if (!skipT) {
      Future.delayed(const Duration(seconds: 1), showTutorial);
    }
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
  void getBoolSave() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('InstructorLoginPage', true);
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Skip All Further Tutorials?'),
            content: const Column(
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
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                ),
                child: const Text('Just for This Page'),
              ),
              ElevatedButton(
                onPressed: () {
                  getBoolSaves();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: const Text('Skip All'),
              ),
            ],
          ),
        );
        return true;
      },
    );
  }
  void _dismissLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDCB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA11300),
        leading: screenWidth < 600 ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          },
        ) : Container(),
        title: const Text(
          'Instructor',
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
      body: Stack(
        children: [
          const LitStarfieldContainer(
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/jic_logo.png',
              width: screenWidth * 0.45,
              height: screenHeight * 0.45,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.3),
            child: Center(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  child: Container(
                    width: 300.0,
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
                          'Instructor ID:',
                          style: TextStyle(color: Color(0xFFA11300)),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10.0),
                        TextField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            LengthLimitingTextInputFormatter(7),

                          ],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                              id = value;
                          },
                          key: keyButton1,
                          controller: idController,
                          decoration: InputDecoration(
                            hintText: 'Enter your ID',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xffdfdfe0)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        const Text(
                          'Password:',
                          style: TextStyle(color: Color(0xFFA11300)),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10.0),
                        TextField(
                          obscureText: !showPassword,
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            password = value;
                          },
                          key: keyButton,
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xffdfdfe0)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              icon: Icon(
                                showPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(const Color(0xFFA11300)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              _showLoadingDialog();
                              if (id == null || password == null) {
                                _dismissLoadingDialog();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all the fields.')));
                              } else {
                                String? idError = validateID(id!);

                                if (idError != null) {
                                  _dismissLoadingDialog();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(idError)));
                                } else {
                                  _saveDataToSharedPreferences(id!);

                                  WidgetsFlutterBinding.ensureInitialized();
                                  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform,
                                  );
                                  FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                      email: '${idController.text}@example.com',
                                      password: passwordController.text)
                                      .then((value) {
                                    _dismissLoadingDialog();
                                        runApp(MaterialApp(
                                    home: ClassPage(idController.text),
                                  ));
                                  }).onError((error, stackTrace) {
                                    _dismissLoadingDialog();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Color(0xFFFF4545), // #ff4545 color
                                        content: Text('Invalid Instructor ID or Password. Please try again.'),
                                      ),
                                    );
                                  });
                                  signIn();
                                }
                              }
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
                    "Instructor ID",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Type your Instructor ID \nIt must be 9 numbers",
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
                    "Password",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Type your password",
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

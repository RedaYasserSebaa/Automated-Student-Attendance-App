import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lit_starfield/view/lit_starfield_container.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'WelcomeScreen.dart';
import 'QRScanner.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: StudentLoginPage(),
  ));
}

class StudentLoginPage extends StatefulWidget {
  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
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


class _StudentLoginPageState extends State<StudentLoginPage> {
  final RegExp idRegExp = RegExp(r'^[0-9]{9}$');
  final RegExp passwordRegExp = RegExp(r'^[a-zA-Z0-9]+$');
  //String? password;
  //String? id;
  bool isLog=false;
  bool showPassword = false;

  late TutorialCoachMark tutorialCoachMark;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton = GlobalKey();

  @override
  void initState() {
    createTutorial();
    Future.delayed(Duration.zero, getBool);
    super.initState();
    getname();
  }
  void getBool() async{
    final prefs = await SharedPreferences.getInstance();
    bool skipT = await prefs.getBool('StudentLoginPage') ?? false;
    print('$skipT');
    if (!skipT) {
      Future.delayed(Duration(milliseconds: 500), showTutorial);
    }
  }
  void getBoolSave() async{
   /*final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('StudentLoginPage', true);*/
  }

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _idlTextController = TextEditingController();



  void getname() async{
    /*final prefs = await SharedPreferences.getInstance();
    _idlTextController.text = prefs.getString('StudentId')!;
    isLog = prefs.getBool('isStudentLoggedIn') as bool;*/
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

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter your password.';
    }
    if (!passwordRegExp.hasMatch(value)) {
      return 'Please enter a valid password (only alphanumeric characters are allowed).';
    }
    return null;
  }

  bool isLoading = false;

  // Function to simulate sign-in process
  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });

    // Simulate a network request or any other sign-in process here
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

  // Show the loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog();
      },
    );
  }
void getnamesave(name) async{
  /*final prefs = await SharedPreferences.getInstance();
  await prefs.setString('StudentName', name as String);
  await prefs.setBool('isStudentLoggedIn', true);*/

}
  // Dismiss the loading dialog
  void _dismissLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
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
  @override
  Widget build(BuildContext context) {
    getname();
    return Scaffold(
      backgroundColor: Color(0xFFFFFDCB),
      appBar: AppBar(
        backgroundColor: Color(0xFFA11300),
        title: Text(
          'Student',
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
          decoration: BoxDecoration(
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/jic_logo.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
            child: Center(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  child: Container(
                    width: 300.0,
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffe1e1e1)),
                      borderRadius: BorderRadius.circular(10.0),
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Student ID:',
                          style: TextStyle(color: Color(0xFFA11300)),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10.0),
                        TextField(
                          key: keyButton1,
                          //autofocus: !isLog,
                          enabled: !isLog,
                          readOnly: isLog,
                          controller: _idlTextController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            LengthLimitingTextInputFormatter(9),
                          ],
                          onChanged: (value) {
                              _idlTextController = value as TextEditingController;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your ID',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Color(0xffdfdfe0)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Password:',
                          style: TextStyle(color: Color(0xFFA11300)),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10.0),
                        TextField(
                          key: keyButton,
                          autofocus: isLog,
                          obscureText: !showPassword,
                          onChanged: (value) {
                            _passwordTextController.text = value;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Color(0xffdfdfe0)),
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

                        SizedBox(height: 30.0),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xFFA11300)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              _showLoadingDialog();
                              // Mark this callback as async
                              if (_passwordTextController.text == null || _idlTextController.text == null) {
                                _dismissLoadingDialog();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all the fields.')));
                              } else {
                                String? passwordError = validatePassword(_passwordTextController.text!);
                                String? idError = validateID(_idlTextController.text!);

                                if (passwordError != null) {
                                  _dismissLoadingDialog();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(passwordError)));
                                } else if (idError != null) {
                                  _dismissLoadingDialog();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(idError)));
                                } else {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('StudentPassword', _passwordTextController.text as String);
                                  await prefs.setString('StudentId', _idlTextController.text as String);
                                  WidgetsFlutterBinding.ensureInitialized();
                                  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform,
                                  );
                                  final FirebaseFirestore db = FirebaseFirestore.instance;
                                  final DocumentReference<Map<String, dynamic>> documentRef = db.collection("names").doc(_idlTextController.text);
                                  DocumentSnapshot documentSnapshot = await documentRef.get();
                                  FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                      email: _idlTextController.text + '@example.com',
                                      password: _passwordTextController.text)
                                      .then((value) {
                                    dynamic name = documentSnapshot.get('name');
                                    getnamesave(name);
                                    _dismissLoadingDialog();
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) => QRScannerPage('$name', _idlTextController.text)));
                                  }).onError((error, stackTrace) {
                                    _dismissLoadingDialog();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Color(0xFFFF4545), // #ff4545 color
                                        content: Text('Invalid Student ID or Password. Please try again.'),
                                      ),
                                    );
                                  });
                                  signIn();
                                }
                              }
                            },
                            child: Text(
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
                    "Student ID",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Type your student ID \nIt must be 9 numbers",
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

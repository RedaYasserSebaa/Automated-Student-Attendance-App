import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lit_starfield/lit_starfield.dart';

void main() {
  runApp(MaterialApp(
    home: AboutUsPage(),
  ));
}

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: 87,
          backgroundColor: Color(0xFFA11300),
          title: Text(
            'About Us',
            style: TextStyle(
              color: Color(0xFFF7F3F3),
              fontSize: 50,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => AboutUsPage(),
                  transitionDuration: Duration(seconds: 0),
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
          child: Scene(),
        ),
      ),
    );
  }
}


class Scene extends StatelessWidget {
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
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Exit'),
              ),
            ],
          ),
        );

        if (exitConfirmation) {
          SystemNavigator.pop();
        }
        return false;
      },
      child:Stack(
          children: [
            LitStarfieldContainer(
              animated: true,
              number: 690,
              velocity: 0.9,
              depth: 0.9,
              scale: 10,
              starColor: Colors.red,
              backgroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffffcccc),
                    Color(0xFFFFFDCB),
                    Color(0xffafb7ff),
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
                            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 2 * fem, 68 * fem),
                            constraints: BoxConstraints(
                              maxWidth: 319 * fem,
                            ),
                            child: Text(
                              'Supervised by\n Dr. Ali Al-Khalifah',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                shadows: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1.5,
                                  blurRadius: 5,
                                  offset: Offset(0, 5),
                                ),
                              ],
                                fontSize: 30 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 0.8333333333 * ffem / fem,
                                color: Color(0xff0b8c70),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0 * fem),
                            padding: EdgeInsets.fromLTRB(17 * fem, 30 * fem, 17 * fem, 25 * fem),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xffcecece)),
                              borderRadius: BorderRadius.circular(15.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xffffcccc),
                                  Color(0xFFFFFDCB),
                                  Color(0xffafb7ff),
                                ],
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
                                  margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 25 * fem),
                                  child: Text(
                                    'JICoders:',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 30 * ffem,
                                      fontWeight: FontWeight.bold,
                                      height: 0.6666666667 * ffem / fem,
                                      color: Color(0xffa11300),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 10 * fem),
                                  child: Text(
                                    'Taher Nasser Al Duabel\n\nHussain Abdulhamed Alalwan\n\nReda Yasser Sebaa\n\nHassan Mohammed Al Qassem',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 20 * ffem,
                                      fontWeight: FontWeight.w600,
                                      height: 0.6666666667 * ffem / fem,
                                      color: Color(0xff000000),
                                    ),
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
}

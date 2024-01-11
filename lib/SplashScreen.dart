import 'package:flutter/material.dart';
import 'WelcomeScreen.dart';

void main() {
  runApp(MyApp());
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorTween;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _colorTween = _animationController.drive(
      ColorTween(
        begin: Colors.greenAccent,
        end: Color(0xfffffdcb),
      ),
    );

    _animationController.forward();
    _navigateToWelcomeScreenWithDelay();
  }

  Future<void> _navigateToWelcomeScreenWithDelay() async {
    await Future.delayed(Duration(seconds: 3)); // Simulating a 3-second delay
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: _colorTween.value,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/jic_logo.png',
                          width: 300, // Adjust the size to fit the screen
                          height: 300,
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    backgroundColor: Colors.white,
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

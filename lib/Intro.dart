import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'WelcomeScreen.dart';

void main() {
  runApp(IntroApp());
}
class IntroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Intro App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Intro(),
    );
  }
}
class Intro extends StatefulWidget {
  Intro({Key? key}) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/intro/Intro.MP4')
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(false);
        _controller.setPlaybackSpeed(2.7);
        _controller.addListener(checkVideo);
        setState(() {});
      });
  }

  void checkVideo() {
    if (!_controller.value.isPlaying) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _controller.value.isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          )
              : Container(),
        ],
      ),
    );
  }
}

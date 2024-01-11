import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BubbleBackground(),
    );
  }
}

class BubbleBackground extends StatefulWidget {
  @override
  _BubbleBackgroundState createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground>
    with SingleTickerProviderStateMixin {
  List<List<Bubble>> layers = [];
  final int numberOfLayers = 4;
  final int numberOfBubbles = 15;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      moveBubbles();
    });
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeBubbles();
  }

  void initializeBubbles() {
    final Size screenSize = MediaQuery.of(context).size;
    layers.clear();
    for (int i = 0; i < numberOfLayers; i++) {
      List<Bubble> layerBubbles = [];
      for (int j = 0; j < numberOfBubbles; j++) {
        double radius = Random().nextDouble() * 20 + 5;
        Offset position = Offset(
          Random().nextDouble() * screenSize.width,
          Random().nextDouble() * screenSize.height,
        );
        layerBubbles.add(Bubble(position, radius));
      }
      layers.add(layerBubbles);
    }
  }

  void moveBubbles() {
    setState(() {
      layers.forEach((layerBubbles) {
        layerBubbles.forEach((bubble) {
          bubble.position += Offset(0, 0.2); // Adjust the speed by changing the values here
          if (bubble.position.dy > MediaQuery.of(context).size.height + bubble.radius) {
            // Reset position when bubbles move off-screen
            bubble.position = Offset(
                Random().nextDouble() * MediaQuery.of(context).size.width,
                -bubble.radius);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffffdcb),
      body: GestureDetector(
        onTap: () {
          setState(() {
            layers.forEach((layerBubbles) {
              layerBubbles.removeAt(Random().nextInt(layerBubbles.length));
            });
          });
        },
        child: CustomPaint(
          painter: BubblePainter(layers),
          child: Container(),
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final List<List<Bubble>> layers;

  BubblePainter(this.layers);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < layers.length; i++) {
      layers[i].forEach((bubble) {
        Paint paintObject = Paint()
          ..style = PaintingStyle.fill
        // Set different opacities for each layer
          ..color = Color(0xFFA11300).withOpacity(0.3 * (i + 1));

        canvas.drawCircle(bubble.position, bubble.radius, paintObject);
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Bubble {
  late Offset position;
  final double radius;

  Bubble(this.position, this.radius);
}

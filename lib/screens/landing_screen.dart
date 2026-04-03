import 'dart:async';
import 'package:flutter/material.dart';
import 'movement_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int currentFrame = 0;
  int totalFrames = 8;
  int columns = 4;
  int rows = 2;

  Timer? animationTimer;

  @override
  void initState() {
    super.initState();

    animationTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) {
        setState(() {
          currentFrame = (currentFrame + 1) % totalFrames;
        });
      },
    );
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    super.dispose();
  }

  Widget buildSprite() {
    const double frameSize = 180;

    int row = currentFrame ~/ columns;
    int col = currentFrame % columns;

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: frameSize * columns,
          maxHeight: frameSize * rows,
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: Offset(-col * frameSize, -row * frameSize),
            child: Image.asset(
              'assets/lion_sprite.png',
              width: frameSize * columns,
              height: frameSize * rows,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSprite(),

            const SizedBox(height: 30),

            const Text(
              "MoveWith Me 🦁",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MovementScreen(),
                  ),
                );
              },
              child: const Text("Get Grooving 🎵"),
            ),
          ],
        ),
      ),
    );
  }
}
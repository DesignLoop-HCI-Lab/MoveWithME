import 'dart:async';
import 'package:flutter/material.dart';
import '../services/esp_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class MovementScreen extends StatefulWidget {
  const MovementScreen({super.key});

  @override
  State<MovementScreen> createState() => _MovementScreenState();
}

class _MovementScreenState extends State<MovementScreen> {


  //frames :

  int currentFrame = 0;
  int totalFrames = 8;
  int columns = 4;
  int rows = 2;
  bool isCoolingDown = false;

Timer? animationTimer;

 List<String> actions = ["jump", "right"];
 String currentAction = "jump";
 Map<String, String> movementSounds = {
  "jump": "jumpy.mp3",
  "right": "lean.mp3",
};

Map<String, String> movementSprites = {
  "jump": "assets/lion_sprite.png",
  "right": "assets/lean_right.png",
  "success":"assets/success_sprite.png",
};

String currentSprite = "assets/lion_sprite.png";

  final EspService espService = EspService();
  final FlutterTts tts = FlutterTts();
  final AudioPlayer player = AudioPlayer();

  // 🔁 Animation frames
  // final List<String> jumpFrames = [
  //   "assets/lion_1.png",
  //   "assets/lion_2.png",
  //   "assets/lion_3.png",
  // ];

 // int currentFrame = 0;

  // 🎮 Game states
  String gameState = "prompting"; 
  String instructionText = "🦁 Jump with me!";

  //Timer? animationTimer;
  Timer? gameTimer;

  String movement = "none";

 @override
void initState() {
  super.initState();

  animationTimer = Timer.periodic(
    const Duration(milliseconds: 300),
    (_) {
      setState(() {
        currentFrame = (currentFrame + 1) % totalFrames;
      });
    },
  );

  startGameLoop(); // 🔥 THIS LINE WAS MISSING
}

 Future<void> startGameLoop() async {
  // 🎲 STEP 1: pick an action
  currentAction = (actions..shuffle()).first;
  currentSprite = movementSprites[currentAction]!;

  // 🖥️ STEP 2: update UI text
  setState(() {
    gameState = "prompting";

    if (currentAction == "jump") {
      instructionText = "🦁 Jump with me!";
    } else if (currentAction == "right") {
      instructionText = "👉 Lean right!";
    }
  });

  // 🗣️ STEP 3: speak instruction
  await tts.stop();

  if (currentAction == "jump") {
    await tts.speak("Jump with me!");
  } else if (currentAction == "right") {
    await tts.speak("Lean to the right!");
  }

  // ⏱️ STEP 4: small pause (feels natural)
  await Future.delayed(const Duration(seconds: 1));

  // 🎬 STEP 5: start animation + music
  setState(() {
    gameState = "animating";
  });

  await player.stop();
  await player.setReleaseMode(ReleaseMode.loop);

  final soundFile = movementSounds[currentAction];
  if (soundFile != null) {
    await player.play(AssetSource(soundFile));
  }

  // ⏳ STEP 6: give time for animation/demo
  await Future.delayed(const Duration(seconds: 2));

  // ⏹️ STEP 7: stop music, switch to user turn
  await player.setVolume(0.2); // 👈 softer during waiting;

  setState(() {
    gameState = "waiting";
    instructionText = "⏳ Your turn!";
  });

  // 🎮 STEP 8: start listening
  waitForMovement();
}

  @override
  void dispose() {
    animationTimer?.cancel();
    gameTimer?.cancel();
    super.dispose();
  }

  // 🖼️ Get current frame
  // String getCurrentImage() {
  //   return jumpFrames[currentFrame];
  // }

  // 🎨 Optional background color
  Color getBackgroundColor() {
    switch (gameState) {
      case "success":
        return Colors.green;
      case "waiting":
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🦁 Lion animation
            Transform.translate(
              offset: Offset(0, currentFrame == 1 ? -30 : 0),
              child: buildSprite(),   // ✅ correct
              ),
            const SizedBox(height: 20),

            // 🗣️ Instruction text
            Text(
              instructionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // 🧪 Debug info (optional, remove later)
            Text(
              "Frame: $currentFrame | State: $gameState | Movement: $movement",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
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
          offset: Offset(
            -col * frameSize,
            -row * frameSize,
          ),
          child: Image.asset(
         currentSprite,
         width: frameSize * columns,
        height: frameSize * rows,
      fit: BoxFit.fill,
          ),
        ),
      ),
    ),
  );
}

void waitForMovement() {
  bool isCoolingDown = false;
  int sameMovementCount = 0;

  gameTimer?.cancel();

  gameTimer = Timer.periodic(
    const Duration(milliseconds: 150),
    (_) async {
      final result = await espService.fetchMovement();

      if (result != null) {
        movement = result;
      }

      print("ESP: $movement | expecting: $currentAction");

      // 🎯 Count repeated same movement
      if (movement == currentAction) {
        sameMovementCount++;
      } else {
        sameMovementCount = 0;
      }

      // ✅ Trigger if movement is stable for a few reads
      if (!isCoolingDown && sameMovementCount >= 2) {
        isCoolingDown = true;

        gameTimer?.cancel();

       setState(() {
        gameState = "success";
        instructionText = "🎉 Nice!";
        currentSprite = movementSprites["success"]!;
        });

        await player.stop();
        await player.play(AssetSource('success.mp3'));

        await tts.stop();
        if (currentAction == "jump") {
          await tts.speak("Nice jump!");
        } else if (currentAction == "right") {
          await tts.speak("Smooth lean!");
        }

        await Future.delayed(const Duration(seconds: 2));

        isCoolingDown = false;

        startGameLoop();
      }
    },
  );
}

}
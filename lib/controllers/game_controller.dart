import 'dart:async';
import 'dart:math';
import '../models/game_state.dart';
import '../services/esp_service.dart';

class GameController {
  GameState gameState = GameState.prompting;

  String instructionText = "Jump with me!";
  String currentMovement = "none";

  final EspService espService = EspService();

  Timer? gameTimer;

  void start(Function(void Function()) setStateCallback) {
    gameTimer = Timer.periodic(
      const Duration(milliseconds: 400),
      (_) async {
        final movement = await espService.fetchMovement();

        setStateCallback(() {
          if (movement != null) currentMovement = movement;
          _gameLoop();
        });
      },
    );
  }

  void dispose() {
    gameTimer?.cancel();
  }

  void _gameLoop() {
    switch (gameState) {
      case GameState.prompting:
        instructionText = "🦁 Jump with me!";
        gameState = GameState.animating;
        break;

      case GameState.animating:
        Future.delayed(const Duration(seconds: 2), () {
          gameState = GameState.waiting;
        });
        break;

      case GameState.waiting:
        if (currentMovement == "jump") {
          gameState = GameState.success;
        }
        break;

      case GameState.success:
        instructionText = "🎉 Good job jumping!";
        Future.delayed(const Duration(seconds: 2), () {
          gameState = GameState.prompting;
        });
        break;
    }
  }
}
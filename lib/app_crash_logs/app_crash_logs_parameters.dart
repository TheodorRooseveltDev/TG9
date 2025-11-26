import 'package:baloon_twist/screens/game_screen.dart';
import 'package:baloon_twist/screens/onboarding_screen.dart';
import 'package:baloon_twist/state/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String appCrashLogsOneSignalString = "e3d196e1-4c85-43d8-8904-b3d16b65d9f8";
String appCrashLogsDevKeypndAppId = "6754984857";

String appCrashLogsAfDevKey1 = "hNYE575rnPs";
String appCrashLogsAfDevKey2 = "XhWgTXMRzpB";

String appCrashLogsUrl = 'https://baloontwistfly.com/appcrashlogs/';
String appCrashLogsStandartWord = "appcrashlogs";

void appCrashLogsOpenStandartAppLogic(BuildContext context) async {
  // Initialize game state
  final GameState _gameState = GameState();

  await _gameState.initialize();

  // Check if onboarding is completed
  if (!_gameState.hasCompletedOnboarding) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Go to onboarding (portrait mode)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(gameState: _gameState),
      ),
    );
  } else {
    // Switch to landscape mode before navigating to game
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Wait a bit for the orientation to settle
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }
}


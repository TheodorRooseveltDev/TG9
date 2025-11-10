import 'package:flutter/material.dart';
import '../state/game_state.dart';
import '../constants/game_assets.dart';
import 'game_hud.dart';
import 'gauge_display.dart';

/// Bottom control bar with left arrow, inflation gauge, and right arrow
class BottomControls extends StatelessWidget {
  final GameState gameState;

  const BottomControls({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 15, // More space from bottom edge
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left arrow button
          ArrowButton(
            imagePath: GameAssets.leftButton,
            onPressDown: () => gameState.moveLeft = true,
            onPressUp: () => gameState.moveLeft = false,
          ),
          
          const SizedBox(width: 20), // More space between button and gauge
          
          // Inflation gauge (takes remaining space)
          Expanded(
            child: GaugeDisplay(gameState: gameState),
          ),
          
          const SizedBox(width: 20), // More space between gauge and button
          
          // Right arrow button
          ArrowButton(
            imagePath: GameAssets.rightButton,
            onPressDown: () => gameState.moveRight = true,
            onPressUp: () => gameState.moveRight = false,
          ),
        ],
      ),
    );
  }
}

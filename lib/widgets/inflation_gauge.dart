import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/game_constants.dart';
import '../state/game_state.dart';

/// Vertical inflation gauge on the left side
class InflationGauge extends StatelessWidget {
  final GameState gameState;

  const InflationGauge({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 60,
      right: 60,
      bottom: 5, // VERY BOTTOM - 5px padding!
      child: Container(
        height: 40, // Smaller height
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none, // Allow circle to be visible
                children: [
                  // Fill based on inflation level (HORIZONTAL)
                  _buildGaugeFill(constraints.maxWidth),
                  
                  // Zone markers and multipliers (HORIZONTAL)
                  _buildZoneMarkers(),
                  
                  // Current level indicator (MOVES WITH LEVEL!)
                  _buildLevelIndicator(constraints.maxWidth),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildZoneMarkers() {
    return Row( // Horizontal zones
      children: List.generate(5, (index) {
        final zone = index + 1; // Left to right: 1, 2, 3, 4, 5
        final color = _getZoneColor(zone);
        final multiplier = 'x$zone';

        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: index < 4 ? BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ) : BorderSide.none,
              ),
            ),
            child: Center(
              child: Text(
                multiplier,
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  shadows: [
                    const Shadow(
                      color: Colors.black87,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGaugeFill(double maxWidth) {
    final fillWidth = gameState.inflationLevel * maxWidth;

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: fillWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              GameColors.gaugeSafe.withOpacity(0.7),
              GameColors.gaugeOk.withOpacity(0.7),
              GameColors.gaugeGood.withOpacity(0.7),
              GameColors.gaugeRisky.withOpacity(0.7),
              GameColors.gaugeDanger.withOpacity(0.7),
            ],
            stops: const [0.0, 0.2, 0.4, 0.6, 0.8],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(double maxWidth) {
    // Calculate position - MOVES WITH INFLATION LEVEL!
    // Account for circle width so it stays within bounds
    final maxTravel = maxWidth - 28; // 24px circle + 4px padding
    final indicatorPosition = (gameState.inflationLevel * maxTravel).clamp(0.0, maxTravel);

    return Positioned(
      left: indicatorPosition + 2, // +2px padding from left edge
      top: ((40 - 24) / 2) - 2, // Moved up by 3px
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black87,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: GameColors.balloonPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: GameColors.balloonPrimary.withOpacity(0.6),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getZoneColor(int zone) {
    switch (zone) {
      case 1:
        return GameColors.gaugeSafe;
      case 2:
        return GameColors.gaugeOk;
      case 3:
        return GameColors.gaugeGood;
      case 4:
        return GameColors.gaugeRisky;
      case 5:
        return GameColors.gaugeDanger;
      default:
        return GameColors.gaugeSafe;
    }
  }
}

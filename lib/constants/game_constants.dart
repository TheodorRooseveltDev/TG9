import 'package:flutter/material.dart';

/// Design System - Ultra Vibrant Colors (Ballonix Style)
class GameColors {
  // Sky Gradient
  static const skyTop = Color(0xFF00D4FF); // Bright Cyan
  static const skyMiddle = Color(0xFF7B68EE); // Medium Purple
  static const skyBottom = Color(0xFFFF6EC7); // Hot Pink

  // Game Elements
  static const balloonPrimary = Color(0xFFFF1493); // Deep Pink
  static const balloonHighlight = Color(0xFFFFD700); // Gold
  static const balloonShadow = Color(0x40000000); // Semi-transparent black

  // Hazards
  static const pinRed = Color(0xFFFF0000); // Pure Red
  static const pinDarkRed = Color(0xFF8B0000); // Dark Red outline
  static const pinSilver = Color(0xFFC0C0C0); // Silver tip

  // Collectibles
  static const coinGold = Color(0xFFFFD700); // Gold
  static const coinOrange = Color(0xFFFFA500); // Orange glow

  // Power-ups
  static const powerUpGreen = Color(0xFF00FF00); // Lime Green
  static const shieldBlue = Color(0xFF00BFFF); // Deep Sky Blue
  static const magnetRed = Color(0xFFFF1493); // Deep Pink
  static const freezeIce = Color(0xFF87CEEB); // Sky Blue

  // UI Elements
  static const textWhite = Color(0xFFFFFFFF); // White
  static const textBlack = Color(0xFF000000); // Black
  static const buttonHotPink = Color(0xFFFF69B4); // Hot Pink

  // Gauge Colors
  static const gaugeSafe = Color(0xFF00FF00); // Green (0-20%)
  static const gaugeOk = Color(0xFF7FFF00); // Light Green (21-40%)
  static const gaugeGood = Color(0xFFFFFF00); // Yellow (41-60%)
  static const gaugeRisky = Color(0xFFFFA500); // Orange (61-80%)
  static const gaugeDanger = Color(0xFFFF0000); // Red (81-100%)

  // Rainbow Balloon Colors
  static const rainbowColors = [
    Color(0xFFFF0000), // Red
    Color(0xFFFF7F00), // Orange
    Color(0xFFFFFF00), // Yellow
    Color(0xFF00FF00), // Green
    Color(0xFF0000FF), // Blue
    Color(0xFF4B0082), // Indigo
    Color(0xFF9400D3), // Violet
  ];
}

/// Game Physics and Mechanics
class GamePhysics {
  // Balloon
  static const double balloonMinSize = 60.0;
  static const double balloonMaxSize = 300.0;
  static const double inflationRate = 0.35; // Per second when tapping (SLOWER - was 0.8)
  static const double deflationRate = 0.08; // Auto-deflate per second (SLOWER - was 0.15)
  static const double balloonWeight = 50.0; // Gravity when deflated
  static const double movementSpeed = 200.0; // Pixels per second
  static const double movementMomentum = 0.85; // Inertia factor

  // Hazards
  static const double pinWidth = 30.0;
  static const double pinHeight = 80.0;
  static const double pinInitialSpeed = 100.0; // Pixels per second
  static const double pinAcceleration = 20.0; // Speed increase per second
  static const double pinSpawnInterval = 2.0; // Seconds

  // Collectibles
  static const double coinSize = 40.0;
  static const double coinFallSpeed = 120.0;
  static const double coinSpawnInterval = 5.0; // Seconds
  static const double coinMultiplierDuration = 5.0; // Seconds

  // Difficulty Scaling
  static const int difficultyScoreInterval = 100;
  static const double pinSpawnSpeedIncrease = 0.10; // 10% faster
  static const double pinFallSpeedIncrease = 0.05; // 5% faster
  static const double coinSpawnDecrease = 0.05; // 5% less frequently
  static const int maxDifficultyScore = 1000;
}

/// Scoring System
class GameScoring {
  // Points per second by inflation zone
  static const Map<int, int> pointsPerSecond = {
    1: 1, // 0-20%
    2: 5, // 21-40%
    3: 10, // 41-60%
    4: 20, // 61-80%
    5: 50, // 81-100%
  };

  // Multipliers by zone
  static const Map<int, int> zoneMultipliers = {
    1: 1,
    2: 2,
    3: 3,
    4: 4,
    5: 5,
  };

  // Zone boundaries (percentage)
  static const List<double> zoneBoundaries = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];

  static int getZone(double inflationPercent) {
    if (inflationPercent <= 0.2) return 1;
    if (inflationPercent <= 0.4) return 2;
    if (inflationPercent <= 0.6) return 3;
    if (inflationPercent <= 0.8) return 4;
    return 5;
  }
}

/// UI Layout Constants
class GameLayout {
  // Screen
  static const double screenWidth = 1920.0; // Reference width
  static const double screenHeight = 1080.0; // Reference height

  // Gauge
  static const double gaugeWidth = 120.0;
  static const double gaugeHeight = 900.0;
  static const double gaugeLeft = 20.0;
  static const double gaugeTop = 90.0;

  // HUD
  static const double hudPadding = 20.0;
  static const double scoreHeight = 80.0;
  static const double buttonSize = 100.0;
  static const double smallButtonSize = 60.0;

  // Game Area
  static const double gameAreaLeft = 160.0; // After gauge
  static const double gameAreaRight = 1900.0;
  static const double gameAreaTop = 100.0;
  static const double gameAreaBottom = 980.0;

  // Movement Buttons
  static const double moveButtonBottom = 120.0;
  static const double moveButtonLeft = 200.0;
  static const double moveButtonRight = 1700.0;
}

/// Animation Constants
class GameAnimations {
  static const double balloonBobAmplitude = 10.0; // Pixels
  static const double balloonBobPeriod = 2.0; // Seconds

  static const double popExpandScale = 1.5;
  static const double popDuration = 0.3; // Seconds
  static const int popPieces = 8;

  static const double screenShakeDuration = 0.2; // Seconds
  static const double screenShakeIntensity = 10.0; // Pixels

  static const double coinSpinSpeed = 2.0; // Rotations per second
  static const double particleDuration = 1.0; // Seconds
}

/// Shop Items
class ShopItems {
  static const Map<String, int> balloonSkins = {
    'classic': 0,
    'rainbow': 100,
    'fire': 200,
    'ice': 200,
    'gold': 500,
    'neon': 300,
    'highlight': 150,
    'shadow': 250,
  };

  static const Map<String, int> powerUps = {
    'shield': 50,
    'magnet': 30,
    'freeze': 40,
  };
}

/// Typography
class GameTypography {
  static const double scoreSize = 48.0;
  static const double hudTextSize = 32.0;
  static const double buttonTextSize = 24.0;
  static const double popupTextSize = 36.0;

  static const double outlineWidth = 4.0;
  static const FontWeight boldWeight = FontWeight.w900;
}

/// Audio
class GameAudio {
  static const double musicVolume = 0.3;
  static const double sfxVolume = 0.7;

  static const String inflate = 'inflate.mp3';
  static const String deflate = 'deflate.mp3';
  static const String pop = 'pop.mp3';
  static const String coinCollect = 'coin.mp3';
  static const String warning = 'warning.mp3';
  static const String backgroundMusic = 'music.mp3';
}

/// Outline/Border Constants
class GameBorders {
  static const double outlineWidth = 6.0;
  static const Color outlineColor = GameColors.textBlack;
}

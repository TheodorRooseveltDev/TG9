import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../constants/game_assets.dart';
import '../state/game_state.dart';

/// Pin hazard that falls from the top
class PinComponent extends PositionComponent {
  final GameState gameState;
  final String hazardType;
  double fallSpeed;
  bool markedForRemoval = false;
  SpriteComponent? hazardSprite;
  double actualWidth = GamePhysics.pinWidth;
  double actualHeight = GamePhysics.pinHeight;

  PinComponent({
    required this.gameState,
    required Vector2 startPosition,
    required this.hazardType,
  })  : fallSpeed = GamePhysics.pinInitialSpeed,
        super(
          position: startPosition,
          size: Vector2(GamePhysics.pinWidth, GamePhysics.pinHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Load hazard sprite with ORIGINAL ASPECT RATIO!
    final spriteImage = await Sprite.load(hazardType);
    
    // Get original image dimensions
    final originalWidth = spriteImage.image.width.toDouble();
    final originalHeight = spriteImage.image.height.toDouble();
    final aspectRatio = originalWidth / originalHeight;
    
    // Scale to fit within max height while preserving aspect ratio
    final maxHeight = GamePhysics.pinHeight;
    actualHeight = maxHeight;
    actualWidth = maxHeight * aspectRatio;
    
    // Update component size to match sprite
    size = Vector2(actualWidth, actualHeight);
    
    hazardSprite = SpriteComponent()
      ..sprite = spriteImage
      ..size = size
      ..anchor = Anchor.center;
    await add(hazardSprite!);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState.isGamePaused) return;

    // Apply freeze power-up
    final speedMultiplier = gameState.hasFreeze ? 0.3 : 1.0;

    // Fall with acceleration
    fallSpeed += GamePhysics.pinAcceleration * dt * gameState.difficultyMultiplier;
    position.y += fallSpeed * dt * speedMultiplier;

    // Remove if off screen
    if (position.y > GameLayout.gameAreaBottom + 100) {
      markedForRemoval = true;
    }
  }

  /// Get collision radius (tip of hazard)
  /// Uses smaller hitbox - only the sharp point counts!
  double getCollisionRadius() => actualWidth * 0.15; // Only 15% of width for tight hitbox

  /// Get collision position (sharp tip of hazard)
  /// This is the dangerous point that can pop the balloon
  Vector2 getCollisionPosition() {
    // Return the bottom-most point (the sharp tip)
    return Vector2(position.x, position.y + (actualHeight * 0.4));
  }
}

/// Coin collectible that falls from the top
class CoinComponent extends PositionComponent {
  final GameState gameState;
  double rotation = 0.0;
  bool markedForRemoval = false;
  SpriteComponent? coinSprite;
  SpriteComponent? glowSprite;

  CoinComponent({
    required this.gameState,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2(GamePhysics.coinSize, GamePhysics.coinSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Load glow effect (behind coin)
    glowSprite = SpriteComponent()
      ..sprite = await Sprite.load(GameAssets.coinGlow)
      ..size = size * 1.5
      ..anchor = Anchor.center
      ..priority = -1;
    await add(glowSprite!);
    
    // Load coin sprite
    coinSprite = SpriteComponent()
      ..sprite = await Sprite.load(GameAssets.coin)
      ..size = size
      ..anchor = Anchor.center
      ..priority = 0;
    await add(coinSprite!);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState.isGamePaused) return;

    // Spin animation
    rotation += GameAnimations.coinSpinSpeed * math.pi * 2 * dt;
    if (rotation > math.pi * 2) rotation -= math.pi * 2;
    
    // Apply rotation to coin sprite
    if (coinSprite != null) {
      coinSprite!.angle = rotation;
    }

    // Fall
    position.y += GamePhysics.coinFallSpeed * dt;

    // Wobble side to side
    position.x += math.sin(position.y * 0.02) * 2;

    // Remove if off screen
    if (position.y > GameLayout.gameAreaBottom + 100) {
      markedForRemoval = true;
    }
  }

  /// Get collision radius
  double getCollisionRadius() => GamePhysics.coinSize / 2;
}

/// Burst particle for pop animation
class BurstParticle extends SpriteComponent {
  Vector2 velocity;
  double lifetime = 0.0;
  final double maxLifetime = GameAnimations.popDuration;

  BurstParticle({
    required this.velocity,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2(80, 80),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Load POW effect sprite
    sprite = await Sprite.load(GameAssets.pow);
  }

  @override
  void update(double dt) {
    super.update(dt);

    lifetime += dt;
    position += velocity * dt;

    // Gravity
    velocity.y += 500 * dt;

    // Fade out
    final opacity = (1.0 - (lifetime / maxLifetime)).clamp(0.0, 1.0);
    paint.color = paint.color.withOpacity(opacity);

    if (lifetime >= maxLifetime) {
      removeFromParent();
    }
  }
}

/// Star particle for coin collect
class StarParticle extends PositionComponent {
  Vector2 velocity;
  double lifetime = 0.0;
  final double maxLifetime = GameAnimations.particleDuration;

  StarParticle({
    required this.velocity,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2(30, 30),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);

    lifetime += dt;
    position += velocity * dt;

    // Slow down
    velocity *= 0.95;

    if (lifetime >= maxLifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final opacity = (1.0 - (lifetime / maxLifetime)).clamp(0.0, 1.0);
    
    // Draw simple star
    final paint = Paint()
      ..color = GameColors.coinGold.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );
  }
}

/// Floating score text
class ScorePopup extends PositionComponent {
  final String text;
  double lifetime = 0.0;
  final double maxLifetime = 1.0;

  ScorePopup({
    required this.text,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);

    lifetime += dt;
    position.y -= 50 * dt; // Float up

    if (lifetime >= maxLifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final opacity = (1.0 - (lifetime / maxLifetime)).clamp(0.0, 1.0);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: GameTypography.popupTextSize,
          fontWeight: GameTypography.boldWeight,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = GameTypography.outlineWidth
            ..color = GameColors.textBlack.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: GameTypography.popupTextSize,
          fontWeight: GameTypography.boldWeight,
          color: GameColors.coinGold.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();

    textPainter2.paint(canvas, Offset(-textPainter2.width / 2, -textPainter2.height / 2));
  }
}

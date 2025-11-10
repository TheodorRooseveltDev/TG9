import 'package:flame/components.dart';
import '../constants/game_constants.dart';
import '../constants/game_assets.dart';
import '../state/game_state.dart';

/// Main balloon component that the player controls
class BalloonComponent extends SpriteComponent {
  final GameState gameState;
  double inflationLevel = 0.5; // Start at CENTER (50%)!
  bool isInflating = false;
  double _accumulatedScore = 0.0; // Accumulate fractional points!
  
  // Default aspect ratio - will be updated when sprite loads
  double balloonAspectRatio = 0.795;

  BalloonComponent({required this.gameState})
      : super(
          anchor: Anchor.bottomCenter, // Anchored at bottom center - grows upward!
          position: Vector2.zero(), // Will be set by game world
          size: Vector2(
            GamePhysics.balloonMinSize * 0.795,
            GamePhysics.balloonMinSize,
          ),
        );

  @override
  Future<void> onLoad() async {
    // Load the balloon sprite directly onto this component
    final skinPath = GameAssets.getBalloonSkinPath(gameState.currentSkin);
    sprite = await Sprite.load(skinPath['balloon']!);
    
    // Update aspect ratio based on actual sprite dimensions
    if (sprite != null && sprite!.srcSize.x > 0 && sprite!.srcSize.y > 0) {
      balloonAspectRatio = sprite!.srcSize.x / sprite!.srcSize.y;
      // Update size with correct aspect ratio
      final newHeight = GamePhysics.balloonMinSize +
          (GamePhysics.balloonMaxSize - GamePhysics.balloonMinSize) * inflationLevel;
      final newWidth = newHeight * balloonAspectRatio;
      size = Vector2(newWidth, newHeight);
    }
  }

  /// Call this when skin changes
  Future<void> updateSkin() async {
    final skinPath = GameAssets.getBalloonSkinPath(gameState.currentSkin);
    sprite = await Sprite.load(skinPath['balloon']!);
    
    // Update aspect ratio based on actual sprite dimensions
    if (sprite != null && sprite!.srcSize.x > 0 && sprite!.srcSize.y > 0) {
      balloonAspectRatio = sprite!.srcSize.x / sprite!.srcSize.y;
      // Update size with correct aspect ratio
      final newHeight = GamePhysics.balloonMinSize +
          (GamePhysics.balloonMaxSize - GamePhysics.balloonMinSize) * inflationLevel;
      final newWidth = newHeight * balloonAspectRatio;
      size = Vector2(newWidth, newHeight);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameState.isGameActive || gameState.isGamePaused) return;

    // Auto-deflate
    if (!isInflating && inflationLevel > 0) {
      inflationLevel -= GamePhysics.deflationRate * dt;
      inflationLevel = inflationLevel.clamp(0.0, 1.0);
    }

    // Inflate when tapping
    if (isInflating && inflationLevel < 1.0) {
      inflationLevel += GamePhysics.inflationRate * dt;
      inflationLevel = inflationLevel.clamp(0.0, 1.0);
    }

    // GAME OVER: Balloon completely deflated!
    if (inflationLevel <= 0.0) {
      print('🎈 DEFLATED! Game Over triggered');
      _deflatedGameOver();
      return;
    }

    // GAME OVER: Pop if over-inflated!
    if (inflationLevel >= 1.0) {
      print('💥 POPPED! Game Over triggered');
      _popBalloon();
      return;
    }

    // Update size based on inflation (VISUAL EFFECT!)
    // Preserve aspect ratio - balloon is taller than wide!
    final newHeight = GamePhysics.balloonMinSize +
        (GamePhysics.balloonMaxSize - GamePhysics.balloonMinSize) * inflationLevel;
    final newWidth = newHeight * balloonAspectRatio;
    size = Vector2(newWidth, newHeight);
    // The sprite automatically scales with the component size!

    // Update game state inflation level
    gameState.inflationLevel = inflationLevel;

    // NO GRAVITY! Balloon stays at bottom
    // Removed the gravity code completely

    // Horizontal movement - prioritize swipe target, then buttons
    if (gameState.targetX != null) {
      // SWIPE CONTROL: Move towards finger position!
      final targetX = gameState.targetX!;
      final distance = targetX - position.x;
      
      // Smooth follow with threshold to prevent jitter
      if (distance.abs() > 5) {
        // Move towards target, but smoothly
        final moveAmount = distance.sign * GamePhysics.movementSpeed * dt * 2.0;
        
        // Don't overshoot the target
        if (distance.abs() < moveAmount.abs()) {
          position.x = targetX;
        } else {
          position.x += moveAmount;
        }
        
        // Constrain to screen bounds
        position.x = position.x.clamp(
          size.x / 2 + 10,
          1000 - size.x / 2 - 10,
        );
      }
    } else if (gameState.moveLeft) {
      // BUTTON CONTROL: Move left
      position.x -= GamePhysics.movementSpeed * dt;
      // Constrain when moving
      position.x = position.x.clamp(
        size.x / 2 + 10,
        1000 - size.x / 2 - 10,
      );
    } else if (gameState.moveRight) {
      // BUTTON CONTROL: Move right
      position.x += GamePhysics.movementSpeed * dt;
      // Constrain when moving
      position.x = position.x.clamp(
        size.x / 2 + 10,
        1000 - size.x / 2 - 10,
      );
    }
    // IMPORTANT: Don't clamp if not moving! Let it stay centered!
    
    // LOCK Y POSITION - balloon bottom stays fixed, grows upward!
    position.y = 350;

    // NO BOBBING - removed completely for stable balloon

    // Accumulate score
    _accumulateScore(dt);
  }

  void _accumulateScore(double dt) {
    final pointsPerSecond = gameState.getPointsPerSecond();
    
    // Accumulate fractional points over time
    _accumulatedScore += pointsPerSecond * dt;
    
    // Add whole points to score when we have at least 1 point
    if (_accumulatedScore >= 1.0) {
      final wholePoints = _accumulatedScore.floor();
      gameState.addScore(wholePoints);
      _accumulatedScore -= wholePoints; // Keep the fractional part
    }
  }

  void startInflating() {
    isInflating = true;
  }

  void stopInflating() {
    isInflating = false;
  }

  // These methods are no longer needed - movement handled in update()
  void moveLeft() {
    // Movement is now handled by gameState.moveLeft in update()
  }

  void moveRight() {
    // Movement is now handled by gameState.moveRight in update()
  }

  void stopMoving() {
    // Not needed anymore
  }

  void _popBalloon() {
    gameState.endGame(reason: 'popped');
    // Pop animation will be triggered from game world
  }

  void _deflatedGameOver() {
    gameState.endGame(reason: 'deflated');
  }

  /// Check collision with a circle (pin or coin)
  /// Uses ACCURATE ELLIPSE collision for balloon shape!
  /// Only counts collision if the object is ABOVE the balloon's bottom threshold
  bool checkCollision(Vector2 otherPosition, double otherRadius, {bool isHazard = false}) {
    // For hazards, only check collision if the hazard is coming from ABOVE
    // This prevents side-hits from already-passed hazards
    if (isHazard) {
      final balloonBottom = position.y; // Bottom of balloon (anchor point)
      
      // Hazard must be above the balloon's bottom 80% to count as a hit
      // This creates a "safe zone" at the very bottom
      final safeZoneThreshold = balloonBottom - (size.y * 0.2);
      
      if (otherPosition.y > safeZoneThreshold) {
        // Hazard is too low, it already passed the balloon
        return false;
      }
    }
    
    // Balloon is an ELLIPSE (taller than wide), not a circle!
    // We need ellipse collision detection
    
    // Get balloon's semi-axes (half width and half height)
    final balloonRadiusX = size.x / 2; // Horizontal radius (narrower)
    final balloonRadiusY = size.y / 2; // Vertical radius (taller)
    
    // Calculate relative position of the other object to balloon center
    // Balloon center is at position.y - (size.y / 2) because anchor is bottom
    final balloonCenterY = position.y - (size.y / 2);
    final dx = otherPosition.x - position.x;
    final dy = otherPosition.y - balloonCenterY;
    
    // Ellipse collision formula: (dx/rx)^2 + (dy/ry)^2 <= 1
    // But we need to account for the other object's radius too
    // Expand the ellipse by the other object's radius
    final expandedRadiusX = balloonRadiusX + otherRadius;
    final expandedRadiusY = balloonRadiusY + otherRadius;
    
    // Check if point is inside the expanded ellipse
    final normalizedDistance = 
        (dx * dx) / (expandedRadiusX * expandedRadiusX) + 
        (dy * dy) / (expandedRadiusY * expandedRadiusY);
    
    return normalizedDistance <= 1.0;
  }

  /// Handle hit from pin
  void handleHit() {
    final survived = gameState.handleHit();
    if (!survived) {
      _popBalloon();
    }
  }
}

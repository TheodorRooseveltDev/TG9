import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../constants/game_assets.dart';
import '../state/game_state.dart';
import '../components/balloon_component.dart';
import '../components/game_components.dart';

/// Main Flame game world
class BalloonGameWorld extends FlameGame with TapCallbacks {
  final GameState gameState;
  BalloonComponent? balloon;
  SpriteComponent? backgroundSprite;
  
  final List<SpriteComponent> clouds = [];
  final List<Vector2> cloudPositions = [];
  final List<double> cloudSpeeds = [];
  
  double pinSpawnTimer = 0.0;
  double coinSpawnTimer = 0.0;
  final List<PinComponent> pins = [];
  final List<CoinComponent> coins = [];
  
  final math.Random random = math.Random();

  BalloonGameWorld({required this.gameState});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load background
    try {
      backgroundSprite = SpriteComponent()
        ..sprite = await Sprite.load(GameAssets.gameBg)
        ..size = size
        ..priority = -100;
      await add(backgroundSprite!);
    } catch (e) {
      print('Failed to load background: $e');
    }
    
    // Load clouds (3 layers for parallax)
    await _loadClouds();

    // Create balloon - CENTERED horizontally, bottom anchored
    balloon = BalloonComponent(gameState: gameState);
    balloon!.position = Vector2(size.x / 2, 350); // Center X, bottom at Y=350 (grows upward!)
    await add(balloon!);
  }
  
  Future<void> _loadClouds() async {
    // Add 3 big clouds
    for (int i = 0; i < 3; i++) {
      final cloud = SpriteComponent()
        ..sprite = await Sprite.load(GameAssets.bigCloud)
        ..size = Vector2(200, 100)
        ..priority = -90;
      final x = random.nextDouble() * size.x;
      final y = 100.0 + random.nextDouble() * 300;
      cloud.position = Vector2(x, y);
      await add(cloud);
      clouds.add(cloud);
      cloudPositions.add(Vector2(x, y));
      cloudSpeeds.add(20 + random.nextDouble() * 20);
    }
    
    // Add 3 medium clouds
    for (int i = 0; i < 3; i++) {
      final cloud = SpriteComponent()
        ..sprite = await Sprite.load(GameAssets.mediumCloud)
        ..size = Vector2(150, 75)
        ..priority = -80;
      final x = random.nextDouble() * size.x;
      final y = 150.0 + random.nextDouble() * 250;
      cloud.position = Vector2(x, y);
      await add(cloud);
      clouds.add(cloud);
      cloudPositions.add(Vector2(x, y));
      cloudSpeeds.add(30 + random.nextDouble() * 30);
    }
    
    // Add 3 small clouds
    for (int i = 0; i < 3; i++) {
      final cloud = SpriteComponent()
        ..sprite = await Sprite.load(GameAssets.smallCloud)
        ..size = Vector2(100, 50)
        ..priority = -70;
      final x = random.nextDouble() * size.x;
      final y = 200.0 + random.nextDouble() * 200;
      cloud.position = Vector2(x, y);
      await add(cloud);
      clouds.add(cloud);
      cloudPositions.add(Vector2(x, y));
      cloudSpeeds.add(40 + random.nextDouble() * 40);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameState.isGameActive || gameState.isGamePaused || balloon == null) return;

    // Update difficulty
    gameState.updateDifficulty();

    // Update power-ups
    gameState.updatePowerUps(dt);
    
    // Update clouds (parallax scrolling)
    for (int i = 0; i < clouds.length; i++) {
      clouds[i].position.x -= cloudSpeeds[i] * dt;
      if (clouds[i].position.x < -clouds[i].size.x) {
        clouds[i].position.x = size.x + clouds[i].size.x;
      }
    }

    // Spawn pins
    pinSpawnTimer += dt;
    final pinInterval = GamePhysics.pinSpawnInterval / gameState.difficultyMultiplier;
    if (pinSpawnTimer >= pinInterval) {
      _spawnPin();
      pinSpawnTimer = 0.0;
    }

    // Spawn coins
    coinSpawnTimer += dt;
    final coinInterval = GamePhysics.coinSpawnInterval * 
        (1.0 + (gameState.difficultyMultiplier - 1.0) * GamePhysics.coinSpawnDecrease);
    if (coinSpawnTimer >= coinInterval) {
      _spawnCoin();
      coinSpawnTimer = 0.0;
    }

    // Check collisions
    _checkCollisions();

    // Remove marked components
    pins.removeWhere((pin) {
      if (pin.markedForRemoval) {
        pin.removeFromParent();
        return true;
      }
      return false;
    });

    coins.removeWhere((coin) {
      if (coin.markedForRemoval) {
        coin.removeFromParent();
        return true;
      }
      return false;
    });

    // Check if balloon popped
    if (!gameState.isGameActive) {
      _handleGameOver();
    }
  }

  void _spawnPin() {
    // INTENSE DIFFICULTY SCALING!
    // Start with 3 hazards, scale up to 10+ hazards at high scores!
    // 1.0x = 3 hazards, 1.5x = 5 hazards, 2.0x = 7 hazards, 3.0x = 10 hazards
    final baseHazards = 3;
    final bonusHazards = ((gameState.difficultyMultiplier - 1.0) * 3.5).round();
    final numHazards = (baseHazards + bonusHazards).clamp(3, 12);
    
    for (int i = 0; i < numHazards; i++) {
      final x = GameLayout.gameAreaLeft + 
          random.nextDouble() * (GameLayout.gameAreaRight - GameLayout.gameAreaLeft);
      
      // Pick random hazard from all 8 types
      final hazardType = GameAssets.allHazards[random.nextInt(GameAssets.allHazards.length)];
      
      // Stagger vertically more for better patterns
      final yOffset = -50 - (i * 80);
      
      final pin = PinComponent(
        gameState: gameState,
        startPosition: Vector2(x, GameLayout.gameAreaTop + yOffset),
        hazardType: hazardType,
      );
      add(pin);
      pins.add(pin);
    }
  }

  void _spawnCoin() {
    final x = GameLayout.gameAreaLeft + 
        random.nextDouble() * (GameLayout.gameAreaRight - GameLayout.gameAreaLeft);
    final coin = CoinComponent(
      gameState: gameState,
      startPosition: Vector2(x, GameLayout.gameAreaTop - 50),
    );
    add(coin);
    coins.add(coin);
  }

  void _checkCollisions() {
    if (balloon == null) return;
    
    // Check pin collisions
    for (final pin in List.from(pins)) {
      if (balloon!.checkCollision(
        pin.getCollisionPosition(),
        pin.getCollisionRadius(),
        isHazard: true, // Mark as hazard for directional collision
      )) {
        balloon!.handleHit();
        pin.markedForRemoval = true;
        _triggerPopEffect();
        break;
      }
    }

    // Check coin collisions (with magnet)
    for (final coin in List.from(coins)) {
      final distance = balloon!.position.distanceTo(coin.position);
      
      // Magnet effect
      if (gameState.hasMagnet && distance < 200) {
        final direction = (balloon!.position - coin.position).normalized();
        coin.position += direction * 300 * (1.0 / 60.0); // Assuming 60 FPS
      }

      if (balloon!.checkCollision(coin.position, coin.getCollisionRadius())) {
        _collectCoin(coin);
        coin.markedForRemoval = true;
      }
    }
  }

  void _collectCoin(CoinComponent coin) {
    gameState.collectCoin();
    gameState.activateCoinMultiplier(GamePhysics.coinMultiplierDuration);
    
    // Spawn particle effect
    _spawnCoinEffect(coin.position);
    
    // Show score popup
    add(ScorePopup(
      text: '+${gameState.getCoinMultiplier()}',
      startPosition: coin.position,
    ));
  }

  void _spawnCoinEffect(Vector2 position) {
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final velocity = Vector2(
        math.cos(angle) * 200,
        math.sin(angle) * 200,
      );
      add(StarParticle(
        velocity: velocity,
        startPosition: position,
      ));
    }
  }

  void _triggerPopEffect() {
    if (!gameState.hasShield) {
      // Only pop if no shield
      _spawnPopParticles();
      _screenShake();
    }
  }

  void _spawnPopParticles() {
    if (balloon == null) return;
    
    for (int i = 0; i < GameAnimations.popPieces; i++) {
      final angle = (i * math.pi * 2) / GameAnimations.popPieces;
      final velocity = Vector2(
        math.cos(angle) * 300,
        math.sin(angle) * 300 - 200, // Up and out
      );
      add(BurstParticle(
        velocity: velocity,
        startPosition: balloon!.position,
      ));
    }
  }

  void _screenShake() {
    // Screen shake effect (simplified - just a visual effect)
    // In a real implementation, you'd offset the camera
  }

  void _handleGameOver() {
    // Wait a moment then restart
    Future.delayed(const Duration(milliseconds: 500), () {
      _restartGame();
    });
  }

  void _restartGame() {
    final b = balloon;
    if (b == null) return;
    
    // Clear all game objects
    for (final pin in pins) {
      pin.removeFromParent();
    }
    pins.clear();

    for (final coin in coins) {
      coin.removeFromParent();
    }
    coins.clear();

    // Reset timers
    pinSpawnTimer = 0.0;
    coinSpawnTimer = 0.0;

    // Reset balloon position - CENTERED, bottom anchored (grows upward!)
    b.position = Vector2(size.x / 2, 350);
    b.inflationLevel = 0.5; // Start at CENTER (50%)!

    // Reset game state
    gameState.resetGame();
  }

  /// Public method to restart game (called from UI)
  void restartGame() {
    _restartGame();
  }

  @override
  void onTapDown(TapDownEvent info) {
    balloon?.startInflating();
  }

  @override
  void onTapUp(TapUpEvent info) {
    balloon?.stopInflating();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    balloon?.stopInflating();
  }

  @override
  void render(Canvas canvas) {
    // Background is now a sprite component, no need to draw gradient
    super.render(canvas);
  }
}

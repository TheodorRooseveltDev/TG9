import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/balloon_game_world.dart';
import '../state/game_state.dart';
import '../widgets/game_hud.dart';
import '../widgets/shop_overlay.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/bottom_controls.dart';
import '../constants/game_constants.dart';
import './settings_screen.dart';

/// Main game screen that combines Flame game with Flutter UI overlays
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameState gameState;
  late final BalloonGameWorld gameWorld;
  bool showShop = false;
  bool showGameOver = false;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    gameState.initialize();
    gameWorld = BalloonGameWorld(gameState: gameState);
    
    // Check for game over state periodically
    _startGameOverListener();
  }

  void _startGameOverListener() {
    // Check every 100ms if game is over
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;
      
      if (!gameState.isGameActive && !showGameOver && !showShop) {
        setState(() {
          showGameOver = true;
        });
      }
      
      return mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Flame game (background with balloon, pins, coins)
          // WRAP WITH GESTURE DETECTOR FOR TAP AND SWIPE!
          GestureDetector(
            // TAP GAME AREA TO INFLATE THE BALLOON!
            onTapDown: (_) {
              if (gameState.isGameActive && !gameState.isGamePaused) {
                final b = gameWorld.balloon;
                if (b != null) {
                  b.startInflating();
                }
              }
            },
            onTapUp: (_) {
              final b = gameWorld.balloon;
              if (b != null) {
                b.stopInflating();
              }
            },
            onTapCancel: () {
              final b = gameWorld.balloon;
              if (b != null) {
                b.stopInflating();
              }
            },
            // SWIPE TO MOVE BALLOON!
            onHorizontalDragStart: (details) {
              if (gameState.isGameActive && !gameState.isGamePaused) {
                // Set target X to finger position
                gameState.targetX = details.localPosition.dx;
              }
            },
            onHorizontalDragUpdate: (details) {
              if (gameState.isGameActive && !gameState.isGamePaused) {
                // Update target X to follow finger position
                gameState.targetX = details.localPosition.dx;
              }
            },
            onHorizontalDragEnd: (_) {
              // Clear target when swipe ends
              gameState.targetX = null;
              gameState.moveLeft = false;
              gameState.moveRight = false;
            },
            onHorizontalDragCancel: () {
              // Clear target if swipe cancelled
              gameState.targetX = null;
              gameState.moveLeft = false;
              gameState.moveRight = false;
            },
            child: GameWidget(game: gameWorld),
          ),

          // Bottom controls: [Left Arrow] [Inflation Gauge] [Right Arrow]
          StreamBuilder(
            stream: Stream.periodic(const Duration(milliseconds: 16)),
            builder: (context, snapshot) {
              return BottomControls(gameState: gameState);
            },
          ),

          // HUD overlay (score, coins, buttons)
          StreamBuilder(
            stream: Stream.periodic(const Duration(milliseconds: 16)),
            builder: (context, snapshot) {
              return GameHUD(
                gameState: gameState,
                onShopPressed: _openShop,
                onSettingsPressed: _openSettings,
              );
            },
          ),

          // Shop overlay (when opened)
          if (showShop)
            StreamBuilder(
              stream: Stream.periodic(const Duration(milliseconds: 16)),
              builder: (context, snapshot) {
                return ShopOverlay(
                  gameState: gameState,
                  onClose: _closeShop,
                  onSkinPurchase: (String skin) async {
                    // Check if already unlocked - if so, just equip it
                    if (gameState.isSkinUnlocked(skin)) {
                      gameState.setSkin(skin);
                      final b = gameWorld.balloon;
                      if (b != null) {
                        await b.updateSkin();
                      }
                      setState(() {});
                      return;
                    }
                    
                    // If not unlocked, try to purchase it
                    final price = ShopItems.balloonSkins[skin] ?? 0;
                    
                    if (price == 0 || gameState.spendCoins(price)) {
                      gameState.unlockSkin(skin);
                      gameState.setSkin(skin);
                      final b = gameWorld.balloon;
                      if (b != null) {
                        await b.updateSkin();
                      }
                      setState(() {});
                      _showPurchaseSuccess();
                    } else {
                      _showInsufficientFunds();
                    }
                  },
                  onPowerUpPurchase: _purchasePowerUp,
                );
              },
            ),
          
          // Game Over overlay (when game ends)
          if (showGameOver)
            GameOverOverlay(
              gameState: gameState,
              onRestart: _restartGame,
              onMainMenu: () {
                // TODO: Navigate to main menu
                _restartGame(); // For now, just restart
              },
            ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      showGameOver = false;
      gameWorld.restartGame();
    });
  }

  void _openShop() {
    setState(() {
      showShop = true;
      gameState.pauseGame();
    });
  }

  void _closeShop() {
    setState(() {
      showShop = false;
      gameState.resumeGame();
    });
  }

  void _openSettings() {
    // Pause game and navigate to settings
    gameState.pauseGame();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(gameState: gameState),
      ),
    ).then((_) {
      // Resume game when returning from settings
      gameState.resumeGame();
    });
  }

  void _purchasePowerUp(String powerUp) {
    final price = ShopItems.powerUps[powerUp] ?? 0;
    
    // Check if power-up stack is full
    int currentCount = 0;
    switch (powerUp) {
      case 'shield':
        currentCount = gameState.shieldCount;
        break;
      case 'magnet':
        currentCount = gameState.magnetCount;
        break;
      case 'freeze':
        currentCount = gameState.freezeCount;
        break;
    }
    
    if (currentCount >= GameState.maxPowerUpStack) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Power-up inventory is full! (Max 25)'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (gameState.spendCoins(price)) {
      setState(() {
        switch (powerUp) {
          case 'shield':
            gameState.shieldCount++;
            break;
          case 'magnet':
            gameState.magnetCount++;
            break;
          case 'freeze':
            gameState.freezeCount++;
            break;
        }
        gameState.saveData(); // Save inventory
      });
      _showPurchaseSuccess();
    } else {
      _showInsufficientFunds();
    }
  }

  void _showPurchaseSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Purchase successful!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showInsufficientFunds() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not enough coins!'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ),
    );
  }
}

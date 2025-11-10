import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/game_constants.dart';
import '../constants/game_assets.dart';
import '../state/game_state.dart';

/// HUD overlay showing score, coins, and controls
class GameHUD extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onShopPressed;
  final VoidCallback onSettingsPressed;

  const GameHUD({
    super.key,
    required this.gameState,
    required this.onShopPressed,
    required this.onSettingsPressed,
  });

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> {
  GameState get gameState => widget.gameState;

  void _showShop() {
    widget.onShopPressed();
  }

  void _showSettings() {
    widget.onSettingsPressed();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fixed margin that works for landscape mode
        // On real devices, this will automatically adjust with safe area
        final powerUpMarginRight = 60.0;
        
        return Stack(
      children: [
        // Top bar with score and buttons - LEFT AND RIGHT ALIGNED
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Score
              SizedBox(
                width: 120,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      GameAssets.scoreFrame,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      '${gameState.currentScore}',
                      style: GoogleFonts.rubik(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: GameColors.textWhite,
                        shadows: [
                          const Shadow(
                            color: GameColors.textBlack,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Shop and Settings buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Shop button
                  _buildTapButton(
                    imagePath: GameAssets.shopButton,
                    onTap: gameState.isGameActive ? _showShop : null,
                    width: 78,
                    height: 78,
                  ),
                  const SizedBox(width: 10),
                  
                  // Settings button
                  _buildTapButton(
                    imagePath: GameAssets.settingsButton,
                    onTap: _showSettings,
                    width: 78,
                    height: 78,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Coins - ABSOLUTELY CENTERED
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 160,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    GameAssets.coinBg,
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          GameAssets.shopCoin,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${gameState.totalCoins}',
                          style: GoogleFonts.rubik(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: GameColors.textWhite,
                            shadows: [
                              const Shadow(
                                color: GameColors.textBlack,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Power-up buttons - Right side, vertically centered
        if (gameState.isGameActive && !gameState.isGamePaused)
          Positioned(
            right: powerUpMarginRight,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shield button
                  _buildPowerUpButton(
                    imagePath: GameAssets.shieldEffectImage,
                    count: gameState.shieldCount,
                    isActive: gameState.hasShield,
                    onTap: () {
                      if (gameState.useShieldFromInventory()) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Magnet button
                  _buildPowerUpButton(
                    imagePath: GameAssets.magnetEffectImage,
                    count: gameState.magnetCount,
                    isActive: gameState.hasMagnet,
                    onTap: () {
                      if (gameState.useMagnetFromInventory()) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Freeze button
                  _buildPowerUpButton(
                    imagePath: GameAssets.freezeEffectImage,
                    count: gameState.freezeCount,
                    isActive: gameState.hasFreeze,
                    onTap: () {
                      if (gameState.useFreezeFromInventory()) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

        // Multiplier indicator - BIG and PLAYFUL! 🎈
        if (gameState.coinMultiplierTime > 0)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'x${gameState.getCoinMultiplier()}',
                style: GoogleFonts.rubik(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: GameColors.powerUpGreen,
                  shadows: [
                    const Shadow(
                      color: GameColors.textBlack,
                      blurRadius: 6,
                      offset: Offset(3, 3),
                    ),
                    Shadow(
                      color: GameColors.powerUpGreen.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
      },
    );
  }

  Widget _buildPowerUpButton({
    required String imagePath,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final bool canUse = count > 0 && !isActive;
    
    return GestureDetector(
      onTap: canUse ? onTap : null,
      child: Opacity(
        opacity: canUse ? 1.0 : 0.5,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isActive ? GameColors.powerUpGreen.withOpacity(0.8) : GameColors.textBlack.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? GameColors.powerUpGreen : GameColors.textWhite,
              width: 3,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: GameColors.powerUpGreen.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Power-up icon
              Image.asset(
                imagePath,
                width: 45,
                height: 45,
                color: canUse ? null : Colors.grey,
                colorBlendMode: canUse ? null : BlendMode.saturation,
              ),
              
              // Count badge
              if (count > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GameColors.textWhite,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: GameColors.textWhite,
                        shadows: [
                          const Shadow(
                            color: GameColors.textBlack,
                            blurRadius: 1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build tap button with scale effect (for shop, sound, etc.)
  Widget _buildTapButton({
    required String imagePath,
    required VoidCallback? onTap,
    required double width,
    required double height,
  }) {
    return _TapButton(
      imagePath: imagePath,
      onTap: onTap,
      width: width,
      height: height,
    );
  }
}

// Stateful arrow button with scale animation
class ArrowButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onPressDown;
  final VoidCallback onPressUp;

  const ArrowButton({
    super.key,
    required this.imagePath,
    required this.onPressDown,
    required this.onPressUp,
  });

  @override
  State<ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<ArrowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      // CRITICAL: Use Listener to completely absorb pointer events
      onPointerDown: (_) {
        setState(() => _isPressed = true);
        widget.onPressDown();
      },
      onPointerUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressUp();
      },
      onPointerCancel: (_) {
        setState(() => _isPressed = false);
        widget.onPressUp();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Image.asset(
          widget.imagePath,
          width: 90, // Bigger buttons - easier to press!
          height: 90,
        ),
      ),
    );
  }
}

// Stateful tap button with scale animation (for shop, sound, etc.)
class _TapButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const _TapButton({
    required this.imagePath,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  State<_TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<_TapButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.onTap != null ? (_) {
        setState(() => _isPressed = true);
      } : null,
      onPointerUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap!();
      } : null,
      onPointerCancel: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
      } : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Image.asset(
          widget.imagePath,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}

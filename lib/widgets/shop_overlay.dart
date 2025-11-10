import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/game_constants.dart';
import '../constants/game_assets.dart';
import '../state/game_state.dart';

/// Shop overlay for purchasing skins and power-ups
class ShopOverlay extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onClose;
  final Function(String) onSkinPurchase;
  final Function(String) onPowerUpPurchase;

  const ShopOverlay({
    super.key,
    required this.gameState,
    required this.onClose,
    required this.onSkinPurchase,
    required this.onPowerUpPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(GameAssets.shopBg),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with coins and close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    'SHOP',
                    style: GoogleFonts.rubik(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: GameColors.textWhite,
                      shadows: [
                        const Shadow(
                          color: GameColors.textBlack,
                          blurRadius: 6,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                  // Coins and close
                  Row(
                    children: [
                      // Coin display using coin_bg
                      Stack(
                        children: [
                          Image.asset(
                            GameAssets.coinBg,
                            width: 160,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.textWhite,
                                      shadows: [
                                        const Shadow(
                                          color: GameColors.textBlack,
                                          blurRadius: 2,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      _buildCloseButton(),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balloon Skins Section
                    _buildSectionTitle('BALLOON SKINS'),
                    const SizedBox(height: 20),
                    _buildSkinsGrid(),
                    
                    const SizedBox(height: 40),
                    
                    // Power-ups Section
                    _buildSectionTitle('POWER-UPS'),
                    const SizedBox(height: 20),
                    _buildPowerUpsGrid(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final bool isSkins = title == 'BALLOON SKINS';
    return Image.asset(
      isSkins ? GameAssets.skins : GameAssets.powerUps,
      height: isSkins ? 60 : 85,
      fit: BoxFit.contain,
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: onClose,
      child: Image.asset(
        GameAssets.closeButton,
        width: 50,
        height: 50,
      ),
    );
  }

  Widget _buildSkinsGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 30,
      children: ShopItems.balloonSkins.entries.map((entry) {
        return _buildSkinItem(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildSkinItem(String skin, int price) {
    final isUnlocked = gameState.isSkinUnlocked(skin);
    final isSelected = gameState.currentSkin == skin;
    final canAfford = gameState.totalCoins >= price;

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          onSkinPurchase(skin);
        } else if (canAfford) {
          onSkinPurchase(skin);
        }
      },
      child: Transform.scale(
        scale: isSelected ? 1.1 : 1.0,
        child: SizedBox(
          width: 150,
          child: Column(
            children: [
              // Name above frame
              Text(
                skin.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: GameColors.textWhite,
                  shadows: [
                    const Shadow(
                      color: GameColors.textBlack,
                      blurRadius: 3,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              
              // Frame with item inside
              Stack(
                alignment: Alignment.center,
                children: [
                  // Item frame
                  Image.asset(
                    GameAssets.itemFrame,
                    width: 150,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                  
                  // Balloon skin image (only the balloon inside the frame)
                  Positioned(
                    child: isUnlocked
                        ? Image.asset(
                            GameAssets.getBalloonSkinImagePath(skin)['balloon']!,
                            width: 80,
                            height: 80,
                          )
                        : ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                            child: Image.asset(
                              GameAssets.getBalloonSkinImagePath(skin)['balloon']!,
                              width: 80,
                              height: 80,
                            ),
                          ),
                  ),
                  
                  // Lock icon centered if locked
                  if (!isUnlocked)
                    Positioned(
                      child: Image.asset(
                        GameAssets.lock,
                        width: 40,
                        height: 40,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Price below frame using coin_bg OR equipped badge
              if (!isUnlocked)
                Stack(
                  children: [
                    Image.asset(
                      GameAssets.coinBg,
                      width: 115,
                      height: 42,
                      fit: BoxFit.contain,
                      color: canAfford ? null : Colors.red.withOpacity(0.7),
                      colorBlendMode: canAfford ? BlendMode.dst : BlendMode.modulate,
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              GameAssets.shopCoin,
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$price',
                              style: GoogleFonts.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: GameColors.textWhite,
                                shadows: [
                                  const Shadow(
                                    color: GameColors.textBlack,
                                    blurRadius: 2,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else if (isSelected)
                Image.asset(
                  GameAssets.equipped,
                  height: 40,
                  fit: BoxFit.contain,
                )
              else
                Image.asset(
                  GameAssets.owned,
                  height: 40,
                  fit: BoxFit.contain,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerUpsGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 30,
      children: ShopItems.powerUps.entries.map((entry) {
        return _buildPowerUpItem(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildPowerUpItem(String powerUp, int price) {
    final canAfford = gameState.totalCoins >= price;
    
    // Get current count of this power-up
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
    
    final bool isFull = currentCount >= GameState.maxPowerUpStack;

    return GestureDetector(
      onTap: () {
        if (canAfford && !isFull) {
          onPowerUpPurchase(powerUp);
        }
      },
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            // Name above frame
            Text(
              powerUp.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: GameColors.textWhite,
                shadows: [
                  const Shadow(
                    color: GameColors.textBlack,
                    blurRadius: 3,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            
            // Frame with item inside
            Stack(
              alignment: Alignment.center,
              children: [
                // Item frame
                Image.asset(
                  GameAssets.itemFrame,
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                ),
                
                // Power-up image (only the icon inside the frame)
                Positioned(
                  child: (canAfford && !isFull)
                      ? Image.asset(
                          _getPowerUpImage(powerUp),
                          width: 80,
                          height: 80,
                        )
                      : ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                          child: Image.asset(
                            _getPowerUpImage(powerUp),
                            width: 80,
                            height: 80,
                          ),
                        ),
                ),
                
                // Lock icon centered if can't afford or inventory full
                if (!canAfford || isFull)
                  Positioned(
                    child: Image.asset(
                      GameAssets.lock,
                      width: 40,
                      height: 40,
                    ),
                  ),
                
                // Quantity badge in top-right corner if owned
                if (currentCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFull ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GameColors.textWhite,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$currentCount',
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: GameColors.textWhite,
                          shadows: [
                            const Shadow(
                              color: GameColors.textBlack,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Price below frame using coin_bg OR "FULL" text
            if (isFull)
              Text(
                'FULL',
                style: GoogleFonts.rubik(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  shadows: [
                    const Shadow(
                      color: GameColors.textBlack,
                      blurRadius: 3,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              )
            else
              Stack(
                children: [
                  Image.asset(
                    GameAssets.coinBg,
                    width: 115,
                    height: 42,
                    fit: BoxFit.contain,
                    color: canAfford ? null : Colors.red.withOpacity(0.7),
                    colorBlendMode: canAfford ? BlendMode.dst : BlendMode.modulate,
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            GameAssets.shopCoin,
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$price',
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: GameColors.textWhite,
                              shadows: [
                                const Shadow(
                                  color: GameColors.textBlack,
                                  blurRadius: 2,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getPowerUpImage(String powerUp) {
    switch (powerUp) {
      case 'shield':
        return GameAssets.shieldEffectImage;
      case 'magnet':
        return GameAssets.magnetEffectImage;
      case 'freeze':
        return GameAssets.freezeEffectImage;
      default:
        return GameAssets.shieldEffectImage;
    }
  }
}

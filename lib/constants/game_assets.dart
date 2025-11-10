/// Asset paths for all game images
/// NOTE: Flame auto-prefixes with "assets/images/", so we use relative paths from there
/// Flutter widgets use Image.asset() which needs full "assets/" paths
class GameAssets {
  // Balloons (for Flame - relative to assets/images/)
  static const String balloonClassic = '../baloons/balloon_classic.png';
  static const String balloonFire = '../baloons/balloon_fire.png';
  static const String balloonGold = '../baloons/balloon_gold.png';
  static const String balloonHighlight = '../baloons/balloon_highlight.png';
  static const String balloonIce = '../baloons/balloon_ice.png';
  static const String balloonNeon = '../baloons/balloon_neon.png';
  static const String balloonRainbow = '../baloons/balloon_rainbow.png';
  static const String balloonShadow = '../baloons/balloon_shadow.png';
  static const String balloonString = '../baloons/balloon_string.png';

  // Background Elements (for Flame)
  static const String bigCloud = '../bg_elements/big_cloude.png';
  static const String gameBg = '../bg_elements/game_bg.png';
  static const String mediumCloud = '../bg_elements/medium_cloude.png';
  static const String smallCloud = '../bg_elements/small_cloude.png';

  // Collectibles (for Flame)
  static const String coin = '../collectibles/coin.png';
  static const String coinGlow = '../collectibles/coin_glow.png';

  // Display Backgrounds (for Flutter widgets - full path)
  static const String coinBg = 'assets/display_bg/coin_bg.png';
  static const String pow = '../display_bg/pow.png';
  static const String scoreFrame = 'assets/display_bg/score_frame.png';

  // Effects (for Flame)
  static const String shieldEffect = '../effects/0001_1_cartoon-shield-shape-bright-blue-3498db-_UgYDLnK9SbOJyc5AXP35EA_OS2-DVi8RiaO0scJXoDVYQ.png';
  static const String magnetEffect = '../effects/0002_1_cartoon-horseshoe-magnet-red-ff0000-and-_uhS3BgNNSoOjL41aLxGtdg_pKogbs8WQpys_X3UbRNQUw.png';
  static const String freezeEffect = '../effects/0003_1_cartoon-snowflake-ice-crystal-light-blue_g1JPX1Y4TRO4pGgB4Yq60A_aPxcu9xoQauUOHuT80vVnA.png';
  
  // Effects for Flutter widgets (full paths)
  static const String shieldEffectImage = 'assets/effects/0001_1_cartoon-shield-shape-bright-blue-3498db-_UgYDLnK9SbOJyc5AXP35EA_OS2-DVi8RiaO0scJXoDVYQ.png';
  static const String magnetEffectImage = 'assets/effects/0002_1_cartoon-horseshoe-magnet-red-ff0000-and-_uhS3BgNNSoOjL41aLxGtdg_pKogbs8WQpys_X3UbRNQUw.png';
  static const String freezeEffectImage = 'assets/effects/0003_1_cartoon-snowflake-ice-crystal-light-blue_g1JPX1Y4TRO4pGgB4Yq60A_aPxcu9xoQauUOHuT80vVnA.png';

  // Hazards (for Flame)
  static const String dartGreen = '../hazards/dart_green.png';
  static const String icicleCyan = '../hazards/icicle_cyan.png';
  static const String nailSilver = '../hazards/nail_silver.png';
  static const String needleBlue = '../hazards/needle_blue.png';
  static const String pencilPink = '../hazards/pencil_pink.png';
  static const String pinRed = '../hazards/pin_red.png';
  static const String screwGray = '../hazards/screw_gray.png';
  static const String tackYellow = '../hazards/tack_yellow.png';

  // Shop UI (for Flutter widgets - full path)
  static const String shopCoin = 'assets/shop_ui/coin.png';
  static const String itemFrame = 'assets/shop_ui/item_frame-Photoroom.png';
  static const String lock = 'assets/shop_ui/lock.png';
  static const String shopBg = 'assets/shop_ui/shop_bg.png';
  static const String equipped = 'assets/shop_ui/equipped.png';
  static const String owned = 'assets/shop_ui/owned.png';
  static const String skins = 'assets/shop_ui/skins.png';
  static const String powerUps = 'assets/shop_ui/power_ups.png';
  static const String dialogueModal = 'assets/shop_ui/dialogue_modal.png';

  // UI Elements (for Flutter widgets - full path)
  static const String bigModal = 'assets/ui_elements/modal.png';
  static const String closeButton = 'assets/ui_elements/close.png';
  static const String elementFrame = 'assets/ui_elements/element_frame.png';
  static const String leftButton = 'assets/ui_elements/left.png';
  static const String playButton = 'assets/ui_elements/play.png';
  static const String restartButton = 'assets/ui_elements/restart.png';
  static const String rightButton = 'assets/ui_elements/right.png';
  static const String settingsButton = 'assets/ui_elements/settings.png';
  static const String shopButton = 'assets/ui_elements/shop.png';
  static const String soundOffButton = 'assets/ui_elements/sound_off.png';
  static const String soundOnButton = 'assets/ui_elements/sound_on.png';
  static const String resetAllButton = 'assets/ui_elements/reset_all.png';
  static const String changeNameButton = 'assets/ui_elements/change_name.png';
  static const String startButton = 'assets/ui_elements/start.png';

  // Balloon skin map
  static Map<String, String> getBalloonSkinPath(String skin) {
    switch (skin) {
      case 'classic':
        return {'balloon': balloonClassic};
      case 'fire':
        return {'balloon': balloonFire};
      case 'gold':
        return {'balloon': balloonGold};
      case 'ice':
        return {'balloon': balloonIce};
      case 'neon':
        return {'balloon': balloonNeon};
      case 'rainbow':
        return {'balloon': balloonRainbow};
      case 'highlight':
        return {'balloon': balloonHighlight};
      case 'shadow':
        return {'balloon': balloonShadow};
      default:
        return {'balloon': balloonClassic};
    }
  }

  // Balloon skin images for Flutter widgets (full paths)
  static Map<String, String> getBalloonSkinImagePath(String skin) {
    switch (skin) {
      case 'classic':
        return {'balloon': 'assets/baloons/balloon_classic.png'};
      case 'fire':
        return {'balloon': 'assets/baloons/balloon_fire.png'};
      case 'gold':
        return {'balloon': 'assets/baloons/balloon_gold.png'};
      case 'ice':
        return {'balloon': 'assets/baloons/balloon_ice.png'};
      case 'neon':
        return {'balloon': 'assets/baloons/balloon_neon.png'};
      case 'rainbow':
        return {'balloon': 'assets/baloons/balloon_rainbow.png'};
      case 'highlight':
        return {'balloon': 'assets/baloons/balloon_highlight.png'};
      case 'shadow':
        return {'balloon': 'assets/baloons/balloon_shadow.png'};
      default:
        return {'balloon': 'assets/baloons/balloon_classic.png'};
    }
  }

  // Hazard list (all 8 types)
  static const List<String> allHazards = [
    dartGreen,
    icicleCyan,
    nailSilver,
    needleBlue,
    pencilPink,
    pinRed,
    screwGray,
    tackYellow,
  ];

  // Cloud list (all 3 sizes)
  static const List<String> allClouds = [
    bigCloud,
    mediumCloud,
    smallCloud,
  ];
}

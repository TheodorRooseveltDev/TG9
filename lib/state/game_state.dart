import 'package:shared_preferences/shared_preferences.dart';

/// Manages persistent game state (scores, coins, unlocks, settings)
class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  // Current game session
  int currentScore = 0;
  int sessionCoins = 0;
  double inflationLevel = 0.0; // 0.0 to 1.0
  bool isGameActive = true;
  bool isGamePaused = false;
  String gameOverReason = ''; // 'popped', 'deflated', 'hit'
  
  // Movement controls
  bool moveLeft = false;
  bool moveRight = false;
  double? targetX; // Target X position for swipe-to-position control

  // Difficulty scaling
  double difficultyMultiplier = 1.0;

  // Power-ups (active states)
  bool hasShield = false;
  bool hasMagnet = false;
  bool hasFreeze = false;
  double coinMultiplierTime = 0.0;
  int coinMultiplierValue = 0; // The actual multiplier value to display (1-5)
  double shieldTime = 0.0;
  double magnetTime = 0.0;
  double freezeTime = 0.0;

  // Power-up inventory (how many of each the player owns)
  int shieldCount = 0;
  int magnetCount = 0;
  int freezeCount = 0;
  static const int maxPowerUpStack = 25;

  // Persistent data
  int highScore = 0;
  int totalCoins = 0;
  String currentSkin = 'classic';
  Set<String> unlockedSkins = {'classic'};
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool notificationsEnabled = false;
  String username = 'Player';
  bool hasCompletedOnboarding = false;

  // SharedPreferences instance
  SharedPreferences? _prefs;

  /// Initialize and load saved data
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadData();
  }

  /// Load data from persistent storage
  Future<void> loadData() async {
    if (_prefs == null) return;

    highScore = _prefs!.getInt('highScore') ?? 0;
    totalCoins = _prefs!.getInt('totalCoins') ?? 0;
    currentSkin = _prefs!.getString('currentSkin') ?? 'classic';
    soundEnabled = _prefs!.getBool('soundEnabled') ?? true;
    musicEnabled = _prefs!.getBool('musicEnabled') ?? true;
    notificationsEnabled = _prefs!.getBool('notificationsEnabled') ?? false;
    username = _prefs!.getString('username') ?? 'Player';
    hasCompletedOnboarding = _prefs!.getBool('hasCompletedOnboarding') ?? false;
    
    // Load power-up inventory
    shieldCount = _prefs!.getInt('shieldCount') ?? 0;
    magnetCount = _prefs!.getInt('magnetCount') ?? 0;
    freezeCount = _prefs!.getInt('freezeCount') ?? 0;

    final skinsJson = _prefs!.getStringList('unlockedSkins');
    if (skinsJson != null) {
      unlockedSkins = skinsJson.toSet();
    }
  }

  /// Save data to persistent storage
  Future<void> saveData() async {
    if (_prefs == null) return;

    await _prefs!.setInt('highScore', highScore);
    await _prefs!.setInt('totalCoins', totalCoins);
    await _prefs!.setString('currentSkin', currentSkin);
    await _prefs!.setBool('soundEnabled', soundEnabled);
    await _prefs!.setBool('musicEnabled', musicEnabled);
    await _prefs!.setBool('notificationsEnabled', notificationsEnabled);
    await _prefs!.setString('username', username);
    await _prefs!.setBool('hasCompletedOnboarding', hasCompletedOnboarding);
    await _prefs!.setStringList('unlockedSkins', unlockedSkins.toList());
    
    // Save power-up inventory
    await _prefs!.setInt('shieldCount', shieldCount);
    await _prefs!.setInt('magnetCount', magnetCount);
    await _prefs!.setInt('freezeCount', freezeCount);
  }

  /// Reset all data to defaults (for settings reset)
  void resetToDefaults() {
    // Reset persistent data
    highScore = 0;
    totalCoins = 0;
    currentSkin = 'classic';
    unlockedSkins = {'classic'};
    soundEnabled = true;
    musicEnabled = true;
    notificationsEnabled = false;
    username = 'Player';
    hasCompletedOnboarding = false;
    
    // Reset power-up inventory
    shieldCount = 0;
    magnetCount = 0;
    freezeCount = 0;
    
    // Reset current game session
    resetGame();
  }

  /// Reset game session (for new game)
  void resetGame() {
    currentScore = 0;
    sessionCoins = 0;
    inflationLevel = 0.5; // Start at CENTER (50%)!
    gameOverReason = '';
    isGameActive = true;
    isGamePaused = false;
    difficultyMultiplier = 1.0;

    // Clear power-ups
    hasShield = false;
    hasMagnet = false;
    hasFreeze = false;
    coinMultiplierTime = 0.0;
    shieldTime = 0.0;
    magnetTime = 0.0;
    freezeTime = 0.0;
  }

  /// Add points to score
  void addScore(int points) {
    currentScore += points;
    if (currentScore > highScore) {
      highScore = currentScore;
      saveData();
    }
    // Update difficulty every time score changes!
    updateDifficulty();
  }

  /// Collect a coin (value multiplied by inflation zone!)
  void collectCoin() {
    final multiplier = getInflationZone(); // 1x to 5x based on zone when caught!
    sessionCoins += multiplier;
    totalCoins += multiplier;
    
    // Show the multiplier for 2.5 seconds!
    coinMultiplierValue = multiplier;
    coinMultiplierTime = 2.5;
    
    saveData(); // Auto-save coins
  }

  /// Spend coins (for shop purchases)
  bool spendCoins(int amount) {
    if (totalCoins >= amount) {
      totalCoins -= amount;
      saveData();
      return true;
    }
    return false;
  }

  /// Add coins (for debugging or rewards)
  void addCoins(int amount) {
    totalCoins += amount;
    saveData();
  }

  /// Unlock a balloon skin
  void unlockSkin(String skin) {
    unlockedSkins.add(skin);
    saveData();
  }

  /// Set current skin
  void setSkin(String skin) {
    if (unlockedSkins.contains(skin)) {
      currentSkin = skin;
      saveData();
    }
  }

  /// Check if a skin is unlocked
  bool isSkinUnlocked(String skin) {
    return unlockedSkins.contains(skin);
  }

  /// Activate shield power-up
  void activateShield() {
    hasShield = true;
    shieldTime = 0.0; // Lasts until one hit
  }

  /// Use shield from inventory
  bool useShieldFromInventory() {
    if (shieldCount > 0 && !hasShield) {
      shieldCount--;
      activateShield();
      saveData();
      return true;
    }
    return false;
  }

  /// Activate magnet power-up
  void activateMagnet(double duration) {
    hasMagnet = true;
    magnetTime = duration;
  }

  /// Use magnet from inventory
  bool useMagnetFromInventory() {
    if (magnetCount > 0 && !hasMagnet) {
      magnetCount--;
      activateMagnet(10.0); // 10 seconds duration
      saveData();
      return true;
    }
    return false;
  }

  /// Activate freeze power-up
  void activateFreeze(double duration) {
    hasFreeze = true;
    freezeTime = duration;
  }

  /// Use freeze from inventory
  bool useFreezeFromInventory() {
    if (freezeCount > 0 && !hasFreeze) {
      freezeCount--;
      activateFreeze(5.0); // 5 seconds duration
      saveData();
      return true;
    }
    return false;
  }

  /// Activate coin multiplier
  void activateCoinMultiplier(double duration) {
    coinMultiplierTime = duration;
  }

  /// Update power-up timers
  void updatePowerUps(double dt) {
    if (magnetTime > 0) {
      magnetTime -= dt;
      if (magnetTime <= 0) {
        hasMagnet = false;
      }
    }

    if (freezeTime > 0) {
      freezeTime -= dt;
      if (freezeTime <= 0) {
        hasFreeze = false;
      }
    }

    if (coinMultiplierTime > 0) {
      coinMultiplierTime -= dt;
      if (coinMultiplierTime <= 0) {
        coinMultiplierValue = 0; // Clear the value when timer expires
      }
    }
  }

  /// Handle balloon hit (removes shield or ends game)
  bool handleHit() {
    if (hasShield) {
      hasShield = false;
      return true; // Survived
    }
    return false; // Game over
  }

  /// Get current coin multiplier (for display only!)
  int getCoinMultiplier() {
    return coinMultiplierValue; // Shows the value from when coin was caught
  }

  /// Calculate difficulty based on score - REAL GAME DIFFICULTY!
  void updateDifficulty() {
    // Every 50 points = difficulty increase
    // Score 0-49: 1.0x
    // Score 50-99: 1.2x
    // Score 100-149: 1.4x
    // Score 150-199: 1.6x
    // etc... up to 3.0x max
    final scoreIntervals = currentScore ~/ 50;
    difficultyMultiplier = (1.0 + (scoreIntervals * 0.2)).clamp(1.0, 3.0);
  }

  /// Toggle sound effects
  void toggleSound() {
    soundEnabled = !soundEnabled;
    saveData();
  }

  /// Toggle music
  void toggleMusic() {
    musicEnabled = !musicEnabled;
    saveData();
  }

  /// Get inflation zone (1-5)
  int getInflationZone() {
    if (inflationLevel <= 0.2) return 1;
    if (inflationLevel <= 0.4) return 2;
    if (inflationLevel <= 0.6) return 3;
    if (inflationLevel <= 0.8) return 4;
    return 5;
  }

  /// Get points per second for current inflation level
  /// Base: 1 point/second, multiplied by zone (1x to 5x)
  int getPointsPerSecond() {
    final zone = getInflationZone();
    // Simple: 1 point/sec × zone multiplier
    return zone; // Zone 1 = 1pt/s, Zone 2 = 2pts/s, ... Zone 5 = 5pts/s
  }

  /// Get current multiplier for display
  int getCurrentMultiplier() {
    return getInflationZone();
  }

  /// Pause/Resume game
  void pauseGame() {
    isGamePaused = true;
  }

  void resumeGame() {
    isGamePaused = false;
  }

  void endGame({String reason = 'popped'}) {
    print('🎮 Game Over! Reason: $reason, isGameActive: $isGameActive -> false');
    isGameActive = false;
    gameOverReason = reason;
  }
}

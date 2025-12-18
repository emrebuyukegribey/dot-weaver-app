import 'package:shared_preferences/shared_preferences.dart';

class GameDataManager {
  static final GameDataManager _instance = GameDataManager._internal();
  factory GameDataManager() => _instance;
  GameDataManager._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // --- Keys ---
  String _getStarKey(String islandId, int levelId) => 'stars_${islandId}_$levelId';
  String _getIslandUnlockKey(String islandId) => 'island_unlocked_$islandId';
  String _getHintKey(String islandId, int levelId) => 'hint_used_${islandId}_$levelId';

  // --- Stars ---
  int getStars(String islandId, int levelId) {
    return _prefs.getInt(_getStarKey(islandId, levelId)) ?? 0;
  }

  Future<void> saveStars(String islandId, int levelId, int stars) async {
    // Only overwrite if new score is higher
    int current = getStars(islandId, levelId);
    if (stars > current) {
      await _prefs.setInt(_getStarKey(islandId, levelId), stars);
    }
  }

  // --- Unlocking ---
  bool isIslandUnlocked(String islandId) {
    // First island (id="1") is always open, others default to false
    if (islandId == "1") return true; 
    return _prefs.getBool(_getIslandUnlockKey(islandId)) ?? false;
  }

  Future<void> unlockIsland(String islandId) async {
    await _prefs.setBool(_getIslandUnlockKey(islandId), true);
  }
  
  // --- Hints ---
  bool isHintUsed(String islandId, int levelId) {
    return _prefs.getBool(_getHintKey(islandId, levelId)) ?? false;
  }
  
  Future<void> markHintUsed(String islandId, int levelId) async {
    await _prefs.setBool(_getHintKey(islandId, levelId), true);
  }

  // --- Helpers ---
  int getLastUnlockedLevelIndex(String islandId, int totalLevels) {
    // Iterate to find the highest unlocked level index (0-based)
    for (int i = totalLevels - 1; i >= 0; i--) {
       int levelId = i + 1;
       // A level is unlocked if it's Level 1 OR previous level has stars
       bool unlocked = false;
       if (levelId == 1) {
         unlocked = true;
       } else {
         int prevStars = getStars(islandId, levelId - 1);
         unlocked = prevStars > 0;
       }
       
       if (unlocked) return i;
    }
    return 0;
  }
}

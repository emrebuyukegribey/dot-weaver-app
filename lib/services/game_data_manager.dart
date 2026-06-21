import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class GameDataManager {
  static final GameDataManager _instance = GameDataManager._internal();
  factory GameDataManager() => _instance;
  GameDataManager._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Debug helper: when true every level/island is unlocked. Keep false for
  /// production builds.
  static const bool debugUnlockAll = false;

  /// Playable islands and their level counts. Ocean ("4") is a "coming soon"
  /// island and intentionally has 0 levels so it stays locked.
  static const Map<String, int> islandLevelCounts = {
    "1": 100, // Color Realm (1-50 hand-made + 51-100 generated)
    "2": 100, // Number Nexus (1-50 hand-made + 51-100 generated)
    "3": 100, // Logic Core (1-35 hand-made + 36-100 generated)
  };

  /// Previous island that must be progressed to unlock a given island.
  static const Map<String, String> _islandPrerequisite = {
    "2": "1",
    "3": "2",
  };

  /// Fraction of the previous island that must be completed to unlock the next.
  /// Islands now hold 100 levels each, so 0.25 keeps the gate at ~25 completed
  /// levels (the same feel as the original 50-level islands at 0.5).
  static const double _unlockFraction = 0.25;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // --- Keys ---
  String _getStarKey(String islandId, int levelId) => 'stars_${islandId}_$levelId';
  String _getIslandUnlockKey(String islandId) => 'island_unlocked_$islandId';
  String _getHintKey(String islandId, int levelId) => 'hint_used_${islandId}_$levelId';
  static const String _kRemoveAds = 'remove_ads';
  static const String _kSoundEnabled = 'sound_enabled';

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
    // Unlock the next island if this progress crosses the threshold.
    await _maybeUnlockNextIsland(islandId);
  }

  /// Total stars earned on a single island.
  int getIslandStars(String islandId, int levelCount) {
    int total = 0;
    for (int i = 1; i <= levelCount; i++) {
      total += getStars(islandId, i);
    }
    return total;
  }

  /// Number of completed levels (stars > 0) on an island.
  int getCompletedCount(String islandId, int levelCount) {
    int count = 0;
    for (int i = 1; i <= levelCount; i++) {
      if (getStars(islandId, i) > 0) count++;
    }
    return count;
  }

  /// Total stars across all playable islands.
  int getTotalStars() {
    int total = 0;
    islandLevelCounts.forEach((islandId, levelCount) {
      total += getIslandStars(islandId, levelCount);
    });
    return total;
  }

  // --- Unlocking ---
  bool isIslandUnlocked(String islandId) {
    if (debugUnlockAll) return true;
    // First island is always open.
    if (islandId == "1") return true;
    // Islands without a defined level count (e.g. Ocean "coming soon") stay locked.
    if (!islandLevelCounts.containsKey(islandId)) return false;
    if (_prefs.getBool(_getIslandUnlockKey(islandId)) ?? false) return true;
    return _hasReachedUnlockThreshold(islandId);
  }

  bool _hasReachedUnlockThreshold(String islandId) {
    final prereq = _islandPrerequisite[islandId];
    if (prereq == null) return false;
    final prevCount = islandLevelCounts[prereq] ?? 0;
    if (prevCount == 0) return false;
    final required = math.max(1, (prevCount * _unlockFraction).ceil());
    return getCompletedCount(prereq, prevCount) >= required;
  }

  Future<void> _maybeUnlockNextIsland(String islandId) async {
    // Find the island that depends on this one.
    String? next;
    _islandPrerequisite.forEach((island, prereq) {
      if (prereq == islandId) next = island;
    });
    if (next == null) return;
    if (_hasReachedUnlockThreshold(next!)) {
      await unlockIsland(next!);
    }
  }

  Future<void> unlockIsland(String islandId) async {
    await _prefs.setBool(_getIslandUnlockKey(islandId), true);
  }

  /// How many completed levels are still required to unlock [islandId], or 0 if
  /// already unlocked / not applicable.
  int levelsRequiredToUnlock(String islandId) {
    if (isIslandUnlocked(islandId)) return 0;
    final prereq = _islandPrerequisite[islandId];
    if (prereq == null) return 0;
    final prevCount = islandLevelCounts[prereq] ?? 0;
    final required = math.max(1, (prevCount * _unlockFraction).ceil());
    return math.max(0, required - getCompletedCount(prereq, prevCount));
  }

  // --- Hints ---
  bool isHintUsed(String islandId, int levelId) {
    return _prefs.getBool(_getHintKey(islandId, levelId)) ?? false;
  }

  Future<void> markHintUsed(String islandId, int levelId) async {
    await _prefs.setBool(_getHintKey(islandId, levelId), true);
  }

  Future<void> resetHint(String islandId, int levelId) async {
    await _prefs.remove(_getHintKey(islandId, levelId));
  }

  // --- Monetization ---
  bool get removeAds => _prefs.getBool(_kRemoveAds) ?? false;

  Future<void> setRemoveAds(bool value) async {
    await _prefs.setBool(_kRemoveAds, value);
  }

  // --- Settings ---
  bool get soundEnabled => _prefs.getBool(_kSoundEnabled) ?? true;

  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(_kSoundEnabled, value);
  }

  // --- Helpers ---
  int getLastUnlockedLevelIndex(String islandId, int totalLevels) {
    if (debugUnlockAll) return totalLevels - 1;
    // Iterate to find the highest unlocked level index (0-based)
    for (int i = totalLevels - 1; i >= 0; i--) {
      int levelId = i + 1;
      // A level is unlocked if it's Level 1 OR previous level has stars
      bool unlocked;
      if (levelId == 1) {
        unlocked = true;
      } else {
        unlocked = getStars(islandId, levelId - 1) > 0;
      }
      if (unlocked) return i;
    }
    return 0;
  }

  /// Whether a specific level is unlocked: level 1 always, or previous completed.
  bool isLevelUnlocked(String islandId, int levelId) {
    if (debugUnlockAll) return true;
    if (levelId <= 1) return true;
    return getStars(islandId, levelId - 1) > 0;
  }
}

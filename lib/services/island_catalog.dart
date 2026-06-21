import 'package:flutter/material.dart';
import '../models/island_model.dart';
import '../models/level_model.dart';
import 'game_data_manager.dart';

/// Single source of truth for island metadata so the world map and the
/// in-game "next island" transition stay in sync.
class _IslandMeta {
  final String id;
  final String name;
  final String backgroundImagePath;
  final String iconAssetPath;
  final int colorValue;
  final int levelCount;
  final String? dotAssetPath;
  final bool comingSoon;

  const _IslandMeta({
    required this.id,
    required this.name,
    required this.backgroundImagePath,
    required this.iconAssetPath,
    required this.colorValue,
    required this.levelCount,
    this.dotAssetPath,
    this.comingSoon = false,
  });
}

class IslandCatalog {
  static const List<_IslandMeta> _meta = [
    _IslandMeta(
      id: "1",
      name: "COLOR REALM",
      backgroundImagePath: "assets/images/islands/color_island_bg.png",
      iconAssetPath: "assets/images/islands/color_island_icon.png",
      colorValue: 0xFF00E5FF,
      levelCount: 50,
    ),
    _IslandMeta(
      id: "2",
      name: "NUMBER NEXUS",
      backgroundImagePath: "assets/images/islands/number_island_bg.png",
      iconAssetPath: "assets/images/islands/number_island_icon.png",
      colorValue: 0xFFD500F9,
      levelCount: 50,
      dotAssetPath: "assets/images/dots/number_dot.png",
    ),
    _IslandMeta(
      id: "3",
      name: "LOGIC CORE",
      backgroundImagePath: "assets/images/islands/operation_island_bg.png",
      iconAssetPath: "assets/images/islands/operation_island_icon.png",
      colorValue: 0xFF00E676,
      levelCount: 35,
      dotAssetPath: "assets/images/dots/operation_dot.png",
    ),
    _IslandMeta(
      id: "4",
      name: "OCEAN DEPTHS",
      backgroundImagePath: "assets/images/islands/ocean_island_bg.png",
      iconAssetPath: "assets/images/islands/ocean_island_icon.png",
      colorValue: 0xFF18B6FF,
      levelCount: 0,
      comingSoon: true,
    ),
  ];

  /// All islands in display order, with live lock/star state applied.
  static List<IslandModel> all() => _meta.map(_build).toList();

  /// Build a single island by id, or null if unknown.
  static IslandModel? byId(String id) {
    for (final m in _meta) {
      if (m.id == id) return _build(m);
    }
    return null;
  }

  /// The next playable island after [id]. Returns null when there is none or
  /// the next island is a "coming soon" placeholder.
  static IslandModel? nextPlayable(String id) {
    final idx = _meta.indexWhere((m) => m.id == id);
    if (idx < 0 || idx + 1 >= _meta.length) return null;
    final next = _meta[idx + 1];
    if (next.comingSoon || next.levelCount == 0) return null;
    return _build(next);
  }

  static IslandModel _build(_IslandMeta m) {
    final data = GameDataManager();
    return IslandModel(
      id: m.id,
      name: m.name,
      backgroundImagePath: m.backgroundImagePath,
      iconAssetPath: m.iconAssetPath,
      primaryColor: Color(m.colorValue),
      isLocked: m.comingSoon ? true : !data.isIslandUnlocked(m.id),
      dotAssetPath: m.dotAssetPath,
      levels: List.generate(
        m.levelCount,
        (i) => LevelModel(
          id: i + 1,
          assetPath: '',
          starsEarned: data.getStars(m.id, i + 1),
          isLocked: !data.isLevelUnlocked(m.id, i + 1),
        ),
      ),
    );
  }
}

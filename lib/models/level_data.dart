import 'package:flutter/material.dart';

class WorldTheme {
  final String id;
  final String name;
  final String backgroundImagePath;
  final Color primaryColor;
  final String levelIconPath;

  const WorldTheme({
    required this.id,
    required this.name,
    required this.backgroundImagePath,
    required this.primaryColor,
    required this.levelIconPath,
  });
}

class LevelData {
  final int id;
  final String worldId;
  final int stars; // 0 to 3
  final bool isLocked;

  const LevelData({
    required this.id,
    required this.worldId,
    this.stars = 0,
    this.isLocked = true,
  });

  LevelData copyWith({
    int? stars,
    bool? isLocked,
  }) {
    return LevelData(
      id: this.id,
      worldId: this.worldId,
      stars: stars ?? this.stars,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

import 'level_model.dart';
import 'package:flutter/material.dart';

class IslandModel {
  final String id;
  final String name;
  final String backgroundImagePath;
  final String iconAssetPath;
  final Color primaryColor;
  final List<LevelModel> levels;
  final bool isLocked;
  final String? dotAssetPath;

  const IslandModel({
    required this.id,
    required this.name,
    required this.backgroundImagePath,
    required this.iconAssetPath,
    required this.primaryColor,
    required this.levels,
    required this.isLocked,
    this.dotAssetPath,
  });
}

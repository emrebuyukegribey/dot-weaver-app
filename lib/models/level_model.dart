class LevelModel {
  final int id;
  final String assetPath;
  final int starsEarned;
  final bool isLocked;

  const LevelModel({
    required this.id,
    required this.assetPath,
    required this.starsEarned,
    this.isLocked = true,
  });
}

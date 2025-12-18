import '../models/game_level_model.dart';

class LevelGenerator {
  static final Map<int, List<DotColor>> levelConfigs = {
    1: [DotColor.red, DotColor.blue],
    2: [DotColor.red, DotColor.blue, DotColor.yellow],
    3: [DotColor.red, DotColor.blue, DotColor.yellow, DotColor.green],
    4: [DotColor.red, DotColor.blue, DotColor.yellow, DotColor.green],
    5: [DotColor.blue, DotColor.yellow, DotColor.pink], // 5x5, 3 colors
    6: [DotColor.purple, DotColor.red, DotColor.teal, DotColor.pink], // 5x5, 4 colors
    7: [DotColor.orange, DotColor.blue, DotColor.green, DotColor.amber], // 6x6, 4 colors
    8: [DotColor.green, DotColor.purple, DotColor.pink, DotColor.red], // 6x6, 4 colors
    9: [DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange], // 6x6, 6 colors (Columns)
    10: [DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange], // 6x6, 6 colors
    11: [DotColor.green, DotColor.yellow, DotColor.pink, DotColor.teal, DotColor.amber], // 7x7, 5 colors
    12: [DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange], // 7x7, 5 colors (Convergence)
    13: [DotColor.red, DotColor.green, DotColor.yellow, DotColor.blue, DotColor.pink, DotColor.teal], // 7x7, 6 colors
    14: [DotColor.blue, DotColor.yellow, DotColor.orange, DotColor.purple, DotColor.amber, DotColor.indigo], // 8x8, 6 colors
    15: [DotColor.purple, DotColor.red, DotColor.green, DotColor.pink, DotColor.teal, DotColor.yellow, DotColor.orange], // 8x8, 7 colors
    16: [DotColor.orange, DotColor.blue, DotColor.amber, DotColor.indigo, DotColor.red, DotColor.green, DotColor.pink], // 8x8, 7 colors
    17: [DotColor.green, DotColor.purple, DotColor.teal, DotColor.pink, DotColor.yellow, DotColor.orange, DotColor.red], // 9x9, 7 colors
    18: [DotColor.yellow, DotColor.orange, DotColor.red, DotColor.blue, DotColor.green, DotColor.purple, DotColor.pink, DotColor.amber], // 9x9, 8 colors
    19: [DotColor.red, DotColor.yellow, DotColor.cyan, DotColor.teal, DotColor.indigo, DotColor.purple, DotColor.orange, DotColor.pink], // 10x10, 8 colors
    20: [DotColor.blue, DotColor.green, DotColor.red, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber], // 10x10, 9 colors
  };

  static GameLevel generate(int levelId) {
    final List<DotColor> colors = levelConfigs[levelId] ?? [DotColor.red, DotColor.blue];
    final Map<DotColor, List<GridPoint>> positions = {};
    // y x
    if (levelId == 1) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(1, 0)];
    } else if (levelId == 2) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(1, 0)];
      positions[DotColor.blue] = [const GridPoint(2, 0), const GridPoint(2, 2)];
    } else if (levelId == 3) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(0, 2)];
      positions[DotColor.yellow] = [const GridPoint(1, 0), const GridPoint(1, 1)];
    } else if (levelId == 4) {
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(1, 0)];
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(2, 0)];
    } else if (levelId == 5) {
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(0, 2)];
      positions[DotColor.yellow] = [const GridPoint(1, 0), const GridPoint(2, 2)];
    } else if (levelId == 6) {
      positions[DotColor.purple] = [const GridPoint(0, 0), const GridPoint(2, 0)];
      positions[DotColor.red] = [const GridPoint(0, 1), const GridPoint(2, 1)];
      positions[DotColor.teal] = [const GridPoint(0, 2), const GridPoint(2, 2)];
    } else if (levelId == 7) {
      positions[DotColor.orange] = [const GridPoint(0, 0), const GridPoint(1, 2)];
      positions[DotColor.blue] = [const GridPoint(1, 1), const GridPoint(2, 3)];
    } else if (levelId == 8) {
      positions[DotColor.green] = [const GridPoint(0, 0), const GridPoint(3, 1)];
      positions[DotColor.purple] = [const GridPoint(2, 1), const GridPoint(0, 3)];
    } else if (levelId == 9) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(3, 3)];
      positions[DotColor.blue] = [const GridPoint(2, 1), const GridPoint(1, 2)];

    } else if (levelId == 10) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(2, 0)];
      positions[DotColor.yellow] = [const GridPoint(0, 3), const GridPoint(2, 3)];
      positions[DotColor.blue] = [const GridPoint(3, 0), const GridPoint(3, 3)];
    } else if (levelId == 11) {
      positions[DotColor.green] = [const GridPoint(0, 0), const GridPoint(0, 3)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(0, 2)];
      positions[DotColor.pink] = [const GridPoint(2, 1), const GridPoint(2, 2)];
    } else if (levelId == 12) {
      positions[DotColor.green] = [const GridPoint(0, 3), const GridPoint(3, 2)];
      positions[DotColor.purple] = [const GridPoint(0, 1), const GridPoint(0, 2)];
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(3, 1)];
    } else if (levelId == 13) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(0, 1)];
      positions[DotColor.green] = [const GridPoint(0, 2), const GridPoint(4, 2)];
      positions[DotColor.yellow] = [const GridPoint(4, 4), const GridPoint(4, 3)];
    } else if (levelId == 14) {
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(2, 4)];
      positions[DotColor.orange] = [const GridPoint(2, 0), const GridPoint(4, 4)];
      positions[DotColor.purple] = [const GridPoint(1, 0), const GridPoint(3, 4)];
    } else if (levelId == 15) {
      positions[DotColor.green] = [const GridPoint(3, 0), const GridPoint(4, 0)];
      positions[DotColor.pink] = [const GridPoint(0, 3), const GridPoint(0, 4)];
      positions[DotColor.orange] = [const GridPoint(2, 2), const GridPoint(4, 4)];
    } else if (levelId == 16) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(3, 3)];
      positions[DotColor.blue] = [const GridPoint(2, 1), const GridPoint(4, 4)];
      positions[DotColor.yellow] = [const GridPoint(3, 1), const GridPoint(2, 3)];
    } else if (levelId == 17) {
      positions[DotColor.blue]   = [const GridPoint(0, 4), const GridPoint(2, 1)];
      positions[DotColor.pink]   = [const GridPoint(2, 0), const GridPoint(4, 4)];
      positions[DotColor.yellow] = [const GridPoint(1, 4), const GridPoint(3, 3)];
    } else if (levelId == 18) {
      positions[DotColor.red]    = [const GridPoint(0, 4), const GridPoint(3, 4)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(2, 3)];
      positions[DotColor.pink]   = [const GridPoint(4, 0), const GridPoint(4, 4)];
      positions[DotColor.yellow] = [const GridPoint(2, 1), const GridPoint(4, 2)];
    } else if (levelId == 19) {
      positions[DotColor.red]    = [const GridPoint(0, 4), const GridPoint(3, 4)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(2, 3)];
      positions[DotColor.pink]   = [const GridPoint(4, 0), const GridPoint(4, 4)];
      positions[DotColor.orange] = [const GridPoint(1, 1), const GridPoint(1, 2)];
    } else if (levelId == 20) {
      positions[DotColor.red]    = [const GridPoint(0, 4), const GridPoint(3, 4)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(3, 2)];
      positions[DotColor.pink]   = [const GridPoint(4, 0), const GridPoint(4, 4)];
      positions[DotColor.orange] = [const GridPoint(1, 1), const GridPoint(3, 0)];
    } else if (levelId == 21) {
      positions[DotColor.red]    = [const GridPoint(0, 4), const GridPoint(3, 4)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(3, 2)];
      positions[DotColor.pink]   = [const GridPoint(4, 0), const GridPoint(4, 4)];
      positions[DotColor.orange] = [const GridPoint(1, 1), const GridPoint(3, 0)];
    }else {
      // Generic Mock: Sequential pair placement to avoid collisions
      for (int i = 0; i < colors.length; i++) {
        positions[colors[i]] = [GridPoint(i, 0), GridPoint(i, 1)];
      }
    }

    // Grid Size Scaling Logic
    int size = 2;
    if (levelId >= 2 && levelId <= 6) size = 3;
    else if (levelId >= 7 && levelId <= 12) size = 4;
    else if (levelId >= 13 && levelId <= 24) size = 5;
    else if (levelId >= 25 && levelId <= 35) size = 6;
    /*
    else if (levelId >= 17 && levelId <= 18) size = 9;
    else if (levelId >= 19) size = 10;
    */

    return GameLevel(
      id: levelId,
      rows: size,
      cols: size,
      dotPositions: positions,
    );
  }
}

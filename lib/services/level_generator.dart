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
    9: [DotColor.yellow, DotColor.orange, DotColor.teal, DotColor.indigo, DotColor.red], // 6x6, 5 colors
    10: [DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange], // 6x6, 6 colors
    11: [DotColor.green, DotColor.yellow, DotColor.pink, DotColor.teal, DotColor.amber], // 7x7, 5 colors
    12: [DotColor.purple, DotColor.orange, DotColor.indigo, DotColor.red, DotColor.blue, DotColor.green], // 7x7, 6 colors
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

    if (levelId == 1) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(2, 2)];
      positions[DotColor.blue] = [const GridPoint(0, 3), const GridPoint(3, 0)];
    } else if (levelId == 2) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(1, 0)];
      positions[DotColor.blue] = [const GridPoint(2, 0), const GridPoint(2, 4)];
      positions[DotColor.yellow] = [const GridPoint(3, 4), const GridPoint(4, 4)];
    } else if (levelId == 3) {
      // LEVEL 3: 5x5 Spiral (Colors Island) - 100% SOLVABLE & COVERAGE
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(0, 4)];
      positions[DotColor.blue] = [const GridPoint(1, 4), const GridPoint(4, 4)];
      positions[DotColor.green] = [const GridPoint(1, 3), const GridPoint(4, 3)];
      positions[DotColor.yellow] = [const GridPoint(1, 2), const GridPoint(4, 0)];
    } else if (levelId == 4) {
      // LEVEL 4: 5x5 Zipper (Colors Island) - 4 Colors, 100% Solvable & Coverage
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(4, 0)];
      positions[DotColor.green] = [const GridPoint(0, 1), const GridPoint(4, 1)];
      positions[DotColor.red] = [const GridPoint(0, 4), const GridPoint(4, 4)];
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(4, 3)];
    } else if (levelId == 5) {
      // LEVEL 5: 5x5 Triple Row Snake
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(4, 0)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(4, 2)];
      positions[DotColor.pink] = [const GridPoint(0, 3), const GridPoint(4, 4)];
    } else if (levelId == 6) {
      // LEVEL 6: 5x5 Vertical Zipper
      positions[DotColor.purple] = [const GridPoint(0, 0), const GridPoint(4, 0)];
      positions[DotColor.red] = [const GridPoint(0, 1), const GridPoint(4, 1)];
      positions[DotColor.teal] = [const GridPoint(0, 2), const GridPoint(4, 2)];
      positions[DotColor.pink] = [const GridPoint(0, 3), const GridPoint(0, 4)];
    } else if (levelId == 7) {
      // LEVEL 7: 6x6 Four Quadrants
      positions[DotColor.orange] = [const GridPoint(0, 0), const GridPoint(2, 2)];
      positions[DotColor.blue] = [const GridPoint(0, 5), const GridPoint(2, 3)];
      positions[DotColor.green] = [const GridPoint(5, 0), const GridPoint(3, 2)];
      positions[DotColor.amber] = [const GridPoint(5, 5), const GridPoint(3, 3)];
    } else if (levelId == 8) {
      // LEVEL 8: 6x6 Nested Spirals
      positions[DotColor.green] = [const GridPoint(0, 0), const GridPoint(1, 1)];
      positions[DotColor.purple] = [const GridPoint(0, 5), const GridPoint(1, 4)];
      positions[DotColor.pink] = [const GridPoint(5, 0), const GridPoint(4, 1)];
      positions[DotColor.red] = [const GridPoint(5, 5), const GridPoint(4, 4)];
    } else if (levelId == 9) {
      // LEVEL 9: 6x6 Striped Zipper - 100% Solvable & Coverage
      positions[DotColor.yellow] = [const GridPoint(0, 0), const GridPoint(5, 0)];
      positions[DotColor.orange] = [const GridPoint(0, 1), const GridPoint(5, 1)];
      positions[DotColor.teal] = [const GridPoint(0, 2), const GridPoint(5, 2)];
      positions[DotColor.indigo] = [const GridPoint(0, 3), const GridPoint(5, 3)];
      positions[DotColor.red] = [const GridPoint(0, 4), const GridPoint(0, 5)];
    } else if (levelId == 10) {
      // LEVEL 10: 6x6 Rainbow Rows
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(0, 5)];
      positions[DotColor.blue] = [const GridPoint(1, 0), const GridPoint(1, 5)];
      positions[DotColor.green] = [const GridPoint(2, 0), const GridPoint(2, 5)];
      positions[DotColor.yellow] = [const GridPoint(3, 0), const GridPoint(3, 5)];
      positions[DotColor.purple] = [const GridPoint(4, 0), const GridPoint(4, 5)];
      positions[DotColor.orange] = [const GridPoint(5, 0), const GridPoint(5, 5)];
    } else if (levelId == 11) {
      // LEVEL 11: 7x7 Maze
      positions[DotColor.green] = [const GridPoint(0, 0), const GridPoint(6, 0)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(6, 2)];
      positions[DotColor.pink] = [const GridPoint(0, 3), const GridPoint(6, 4)];
      positions[DotColor.teal] = [const GridPoint(0, 5), const GridPoint(6, 6)];
      positions[DotColor.amber] = [const GridPoint(0, 6), const GridPoint(5, 6)];
    } else if (levelId == 12) {
      // LEVEL 12: 7x7 Rainbow Columns - 100% Solvable & Coverage
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(6, 0)];
      positions[DotColor.green] = [const GridPoint(0, 1), const GridPoint(6, 1)];
      positions[DotColor.red] = [const GridPoint(0, 2), const GridPoint(6, 2)];
      positions[DotColor.purple] = [const GridPoint(0, 3), const GridPoint(6, 3)];
      positions[DotColor.orange] = [const GridPoint(0, 4), const GridPoint(6, 4)];
      positions[DotColor.indigo] = [const GridPoint(0, 5), const GridPoint(0, 6)];
    } else if (levelId == 13) {
      // LEVEL 13: 7x7 Alternating Snakes
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(6, 1)];
      positions[DotColor.green] = [const GridPoint(0, 2), const GridPoint(6, 3)];
      positions[DotColor.yellow] = [const GridPoint(0, 4), const GridPoint(6, 5)];
      positions[DotColor.blue] = [const GridPoint(0, 6), const GridPoint(1, 6)];
      positions[DotColor.pink] = [const GridPoint(2, 6), const GridPoint(3, 6)];
      positions[DotColor.teal] = [const GridPoint(4, 6), const GridPoint(6, 6)];
    } else if (levelId == 14) {
      // LEVEL 14: 8x8 Grid Master - 100% Solvable & Coverage
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(7, 0)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(0, 2)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(0, 4)];
      positions[DotColor.purple] = [const GridPoint(0, 5), const GridPoint(0, 6)];
      positions[DotColor.amber] = [const GridPoint(0, 7), const GridPoint(1, 7)];
      positions[DotColor.indigo] = [const GridPoint(2, 7), const GridPoint(7, 7)];
    } else if (levelId == 15) {
      // LEVEL 15: 8x8 Rainbow Mix - 100% Solvable & Coverage
      positions[DotColor.purple] = [const GridPoint(0, 0), const GridPoint(7, 0)];
      positions[DotColor.red] = [const GridPoint(0, 1), const GridPoint(7, 1)];
      positions[DotColor.green] = [const GridPoint(0, 2), const GridPoint(7, 2)];
      positions[DotColor.pink] = [const GridPoint(0, 3), const GridPoint(7, 3)];
      positions[DotColor.teal] = [const GridPoint(0, 4), const GridPoint(7, 4)];
      positions[DotColor.yellow] = [const GridPoint(0, 5), const GridPoint(7, 5)];
      positions[DotColor.orange] = [const GridPoint(0, 6), const GridPoint(0, 7)];
    } else if (levelId == 16) {
      // LEVEL 16: 8x8 Symmetry Break - 100% Solvable & Coverage
      positions[DotColor.orange] = [const GridPoint(0, 0), const GridPoint(7, 0)];
      positions[DotColor.blue] = [const GridPoint(0, 1), const GridPoint(7, 1)];
      positions[DotColor.amber] = [const GridPoint(0, 2), const GridPoint(7, 2)];
      positions[DotColor.indigo] = [const GridPoint(0, 3), const GridPoint(7, 3)];
      positions[DotColor.red] = [const GridPoint(0, 4), const GridPoint(7, 4)];
      positions[DotColor.green] = [const GridPoint(0, 5), const GridPoint(7, 5)];
      positions[DotColor.pink] = [const GridPoint(0, 6), const GridPoint(0, 7)];
    } else if (levelId == 17) {
      // LEVEL 17: 9x9 The Abyss - 100% Solvable & Coverage
      positions[DotColor.green] = [const GridPoint(0, 0), const GridPoint(8, 0)];
      positions[DotColor.purple] = [const GridPoint(0, 1), const GridPoint(8, 1)];
      positions[DotColor.teal] = [const GridPoint(0, 2), const GridPoint(8, 2)];
      positions[DotColor.pink] = [const GridPoint(0, 3), const GridPoint(8, 3)];
      positions[DotColor.yellow] = [const GridPoint(0, 4), const GridPoint(8, 4)];
      positions[DotColor.orange] = [const GridPoint(0, 5), const GridPoint(0, 6)];
      positions[DotColor.red] = [const GridPoint(0, 7), const GridPoint(0, 8)];
    } else if (levelId == 18) {
      // LEVEL 18: 9x9 Chaos Theory - 100% Solvable & Coverage
      positions[DotColor.yellow] = [const GridPoint(0, 0), const GridPoint(8, 0)];
      positions[DotColor.orange] = [const GridPoint(0, 1), const GridPoint(8, 1)];
      positions[DotColor.red] = [const GridPoint(0, 2), const GridPoint(8, 2)];
      positions[DotColor.blue] = [const GridPoint(0, 3), const GridPoint(8, 3)];
      positions[DotColor.green] = [const GridPoint(0, 4), const GridPoint(8, 4)];
      positions[DotColor.purple] = [const GridPoint(0, 5), const GridPoint(8, 5)];
      positions[DotColor.pink] = [const GridPoint(0, 6), const GridPoint(8, 6)];
      positions[DotColor.amber] = [const GridPoint(0, 7), const GridPoint(0, 8)];
    } else if (levelId == 19) {
      // LEVEL 19: 10x10 Dot Weaver - 100% Solvable & Coverage
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(9, 0)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(9, 1)];
      positions[DotColor.cyan] = [const GridPoint(0, 2), const GridPoint(9, 2)];
      positions[DotColor.teal] = [const GridPoint(0, 3), const GridPoint(9, 3)];
      positions[DotColor.indigo] = [const GridPoint(0, 4), const GridPoint(9, 4)];
      positions[DotColor.purple] = [const GridPoint(0, 5), const GridPoint(9, 5)];
      positions[DotColor.orange] = [const GridPoint(0, 6), const GridPoint(0, 7)];
      positions[DotColor.pink] = [const GridPoint(0, 8), const GridPoint(0, 9)];
    } else if (levelId == 20) {
      // LEVEL 20: 10x10 The Grand Finale - 100% Solvable & Coverage
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(9, 0)];
      positions[DotColor.green] = [const GridPoint(0, 1), const GridPoint(9, 1)];
      positions[DotColor.red] = [const GridPoint(0, 2), const GridPoint(9, 2)];
      positions[DotColor.yellow] = [const GridPoint(0, 3), const GridPoint(9, 3)];
      positions[DotColor.purple] = [const GridPoint(0, 4), const GridPoint(9, 4)];
      positions[DotColor.orange] = [const GridPoint(0, 5), const GridPoint(9, 5)];
      positions[DotColor.pink] = [const GridPoint(0, 6), const GridPoint(9, 6)];
      positions[DotColor.teal] = [const GridPoint(0, 7), const GridPoint(9, 7)];
      positions[DotColor.amber] = [const GridPoint(0, 8), const GridPoint(0, 9)];
    } else {
      // Generic Mock: Sequential pair placement to avoid collisions
      for (int i = 0; i < colors.length; i++) {
        positions[colors[i]] = [GridPoint(i, 0), GridPoint(i, 1)];
      }
    }

    // Grid Size Scaling Logic
    int size = 4;
    if (levelId >= 2 && levelId <= 6) size = 5;
    else if (levelId >= 7 && levelId <= 10) size = 6;
    else if (levelId >= 11 && levelId <= 13) size = 7;
    else if (levelId >= 14 && levelId <= 16) size = 8;
    else if (levelId >= 17 && levelId <= 18) size = 9;
    else if (levelId >= 19) size = 10;

    return GameLevel(
      id: levelId,
      rows: size,
      cols: size,
      dotPositions: positions,
    );
  }
}

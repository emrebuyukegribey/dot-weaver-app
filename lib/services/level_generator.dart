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
    20: [DotColor.blue, DotColor.green, DotColor.red, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber], // 5x5 (Compact)
    // Level 21-30: 6x6 Grid
    21: [DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple],
    22: [DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo],
    23: [DotColor.red, DotColor.blue, DotColor.yellow, DotColor.green, DotColor.purple, DotColor.orange],
    24: [DotColor.cyan, DotColor.teal, DotColor.pink, DotColor.amber, DotColor.indigo, DotColor.blue],
    25: [DotColor.red, DotColor.green, DotColor.blue, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink],
    26: [DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red, DotColor.green, DotColor.blue],
    27: [DotColor.pink, DotColor.orange, DotColor.purple, DotColor.yellow, DotColor.green, DotColor.blue, DotColor.red, DotColor.cyan],
    28: [DotColor.indigo, DotColor.teal, DotColor.amber, DotColor.pink, DotColor.orange, DotColor.purple, DotColor.yellow, DotColor.green],
    29: [DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal],
    30: [DotColor.cyan, DotColor.indigo, DotColor.amber, DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple],

    // Level 31-40: 7x7 Grid
    31: [DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange],
    32: [DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red],
    33: [DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal],
    34: [DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow],
    35: [DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red],
    36: [DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber],
    37: [DotColor.indigo, DotColor.cyan, DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange],
    38: [DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red, DotColor.blue, DotColor.green],
    39: [DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red],
    40: [DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo],

    // Level 41-50: 8x8 Grid
    41: [DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink],
    42: [DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red, DotColor.blue, DotColor.green],
    43: [DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan],
    44: [DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal],
    45: [DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple],
    46: [DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red, DotColor.blue, DotColor.green],
    47: [DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan, DotColor.red],
    48: [DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo, DotColor.cyan],
    49: [DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo],
    50: [DotColor.cyan, DotColor.red, DotColor.blue, DotColor.green, DotColor.yellow, DotColor.purple, DotColor.orange, DotColor.pink, DotColor.teal, DotColor.amber, DotColor.indigo],
  };

  // Generate level based on island context
  static GameLevel generate(int levelId, {String? islandId}) {
    if (islandId == "2" || islandId == 2.toString()) {
      return generateNumberLevel(levelId);
    }

    // Route to Operation Island
    if (islandId == "3" || islandId == 3.toString()) {
      return generateOperationLevel(levelId);
    }
    
    // Default: Color dot puzzle
    return generateColorLevel(levelId);
  }

  static GameLevel generateNumberLevel(int levelId) {
    if (levelId == 1) {
      // Level 1: 3x3 Intro
      return GameLevel(
        id: levelId,
        rows: 3,
        cols: 3,
        timeLimit: 120,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.purple: [const GridPoint(1, 1), const GridPoint(2, 2)],
        },
        startNode: const GridPoint(1, 1),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(1, 1): 1,
          const GridPoint(0, 0): 5,
          const GridPoint(2, 2): 9,
        },
      );
    } else if (levelId == 2) {
      // Level 2: 3x3 Spiral
      return GameLevel(
        id: levelId,
        rows: 3,
        cols: 3,
        timeLimit: 90,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.blue: [const GridPoint(0, 0), const GridPoint(1, 1)],
        },
        startNode: const GridPoint(0, 0),
        startValue: 5,
        fixedNumbers: {
          const GridPoint(0, 0): 5,
          const GridPoint(0, 2): 7,
          const GridPoint(2, 2): 9,
          const GridPoint(2, 0): 11,
          const GridPoint(1, 1): 13,
        },
      );
    } else if (levelId == 3) {
      // Level 3: 3x3 Zig-Zag
      return GameLevel(
        id: levelId,
        rows: 3,
        cols: 3,
        timeLimit: 90,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.green: [const GridPoint(0, 0), const GridPoint(0, 2)],
        },
        startNode: const GridPoint(0, 0),
        startValue: 10,
        fixedNumbers: {
          const GridPoint(0, 0): 10,
          const GridPoint(2, 0): 12,
          const GridPoint(2, 1): 13,
          const GridPoint(0, 1): 15,
          const GridPoint(2, 2): 18,
        },
      );
    } else if (levelId == 4) {
      // Level 4: 3x3 Corners
      return GameLevel(
        id: levelId,
        rows: 3,
        cols: 3,
        timeLimit: 60,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.yellow: [const GridPoint(0, 0), const GridPoint(1, 0)],
        },
        startNode: const GridPoint(0, 0),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(0, 0): 1,
          const GridPoint(2, 2): 5,
          const GridPoint(1, 1): 9,
        },
      );
    } else if (levelId == 5) {
      // Level 5: 3x3 Middle Start Advanced
      return GameLevel(
        id: levelId,
        rows: 3,
        cols: 3,
        timeLimit: 60,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.orange: [const GridPoint(1, 1), const GridPoint(0, 0)],
        },
        startNode: const GridPoint(1, 1),
        startValue: 20,
        fixedNumbers: {
          const GridPoint(1, 1): 20,
          const GridPoint(0, 0): 28,
        },
      );
    } else if (levelId == 6) {
      // Level 6: 4x4 Introduction
      return GameLevel(
        id: levelId,
        rows: 4,
        cols: 4,
        timeLimit: 150,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.red: [const GridPoint(0, 0), const GridPoint(3, 3)],
        },
        startNode: const GridPoint(0, 0),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(0, 0): 1,
          const GridPoint(0, 3): 4,
          const GridPoint(3, 3): 7,
          const GridPoint(3, 0): 10,
          const GridPoint(2, 1): 16,
        },
      );
    } else if (levelId == 7) {
      // Level 7: 4x4 S-Shape
      return GameLevel(
        id: levelId,
        rows: 4,
        cols: 4,
        timeLimit: 140,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.teal: [const GridPoint(0, 0), const GridPoint(0, 3)],
        },
        startNode: const GridPoint(0, 0),
        startValue: 10,
        fixedNumbers: {
          const GridPoint(0, 0): 10,
          const GridPoint(3, 0): 13,
          const GridPoint(3, 1): 14,
          const GridPoint(0, 1): 17,
          const GridPoint(0, 2): 18,
          const GridPoint(3, 2): 21,
          const GridPoint(3, 3): 22,
          const GridPoint(0, 3): 25,
        },
      );
    } else if (levelId == 8) {
      // Level 8: 4x4 Middle Start
      return GameLevel(
        id: levelId,
        rows: 4,
        cols: 4,
        timeLimit: 120,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.pink: [const GridPoint(1, 1), const GridPoint(2, 2)],
        },
        startNode: const GridPoint(1, 1),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(1, 1): 1,
          const GridPoint(2, 3): 16,
        },
      );
    } else if (levelId == 9) {
      // Level 9: 4x4 Cross
      return GameLevel(
        id: levelId,
        rows: 4,
        cols: 4,
        timeLimit: 120,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.purple: [const GridPoint(0, 1), const GridPoint(3, 2)],
        },
        startNode: const GridPoint(0, 1),
        startValue: 40,
        fixedNumbers: {
          const GridPoint(0, 1): 40,
          const GridPoint(0, 0): 41,
          const GridPoint(3, 0): 44,
          const GridPoint(3, 3): 47,
          const GridPoint(0, 3): 50,
          const GridPoint(0, 2): 51,
          const GridPoint(2, 2): 55,
        },
      );
    } else if (levelId == 10) {
      // Level 10: 4x4 Hard
      return GameLevel(
        id: levelId,
        rows: 4,
        cols: 4,
        timeLimit: 100,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.indigo: [const GridPoint(2, 0), const GridPoint(1, 3)],
        },
        startNode: const GridPoint(2, 0),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(2, 0): 1,
          const GridPoint(3, 3): 5,
          const GridPoint(0, 0): 11,
          const GridPoint(0, 3): 16,
        },
      );
    } else if (levelId == 11) {
      // Level 11: 5x5 Classic Snake
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 180,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.blue: [const GridPoint(0, 0), const GridPoint(4, 4)]},
        startNode: const GridPoint(0, 0),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(0, 0): 1,
          const GridPoint(0, 4): 5,
          const GridPoint(1, 4): 6,
          const GridPoint(4, 4): 25,
        },
      );
    } else if (levelId == 12) {
      // Level 12: 5x5 Center Out
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 170,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.green: [const GridPoint(2, 2), const GridPoint(0, 0)]},
        startNode: const GridPoint(2, 2),
        startValue: 10,
        fixedNumbers: {
          const GridPoint(2, 2): 10,
          const GridPoint(0, 0): 34,
          const GridPoint(2, 4): 24,
        },
      );
    } else if (levelId == 13) {
      // Level 13: 5x5 Corner To Corner
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 160,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.yellow: [const GridPoint(0, 4), const GridPoint(4, 0)]},
        startNode: const GridPoint(0, 4),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(0, 4): 1,
          const GridPoint(4, 4): 5,
          const GridPoint(2, 2): 13,
          const GridPoint(4, 0): 25,
        },
      );
    } else if (levelId == 14) {
      // Level 14: 5x5 Vertical Snake
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 150,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.orange: [const GridPoint(4, 0), const GridPoint(4, 4)]},
        startNode: const GridPoint(4, 0),
        startValue: 50,
        fixedNumbers: {
          const GridPoint(4, 0): 50,
          const GridPoint(0, 0): 54,
          const GridPoint(0, 1): 55,
          const GridPoint(4, 1): 59,
          const GridPoint(4, 4): 74,
        },
      );
    } else if (levelId == 15) {
      // Level 15: 5x5 Maze Like
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 140,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.pink: [const GridPoint(1, 1), const GridPoint(3, 3)]},
        startNode: const GridPoint(1, 1),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(1, 1): 1,
          const GridPoint(0, 0): 5,
          const GridPoint(4, 0): 9,
          const GridPoint(4, 4): 13,
          const GridPoint(0, 4): 17,
          const GridPoint(2, 2): 21,
          const GridPoint(3, 3): 25,
        },
      );
    } else if (levelId == 16) {
      // Level 16: 5x5 Spiral Out
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 200,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.purple: [const GridPoint(2, 2), const GridPoint(0, 0)]},
        startNode: const GridPoint(2, 2),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(2, 2): 1,
          const GridPoint(1, 2): 2,
          const GridPoint(3, 3): 13,
          const GridPoint(0, 0): 25,
        },
      );
    } else if (levelId == 17) {
      // Level 17: 5x5 Zig Zag
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 180,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.red: [const GridPoint(0, 0), const GridPoint(4, 0)]},
        startNode: const GridPoint(0, 0),
        startValue: 10,
        fixedNumbers: {
          const GridPoint(0, 0): 10,
          const GridPoint(0, 4): 14,
          const GridPoint(2, 2): 20,
          const GridPoint(4, 0): 34,
        },
      );
    } else if (levelId == 18) {
      // Level 18: 5x5 Reverse Snake
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 170,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.teal: [const GridPoint(4, 4), const GridPoint(0, 0)]},
        startNode: const GridPoint(4, 4),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(4, 4): 1,
          const GridPoint(4, 0): 5,
          const GridPoint(2, 2): 25,
        },
      );
    } else if (levelId == 19) {
      // Level 19: 5x5 Complex
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 160,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.amber: [const GridPoint(0, 2), const GridPoint(4, 2)]},
        startNode: const GridPoint(0, 2),
        startValue: 7,
        fixedNumbers: {
          const GridPoint(0, 2): 7,
          const GridPoint(4, 0): 15,
          const GridPoint(2, 2): 31,
        },
      );
    } else if (levelId == 20) {
      // Level 20: 5x5 Master
      return GameLevel(
        id: levelId,
        rows: 5,
        cols: 5,
        timeLimit: 150,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.indigo: [const GridPoint(3, 1), const GridPoint(1, 3)]},
        startNode: const GridPoint(3, 1),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(3, 1): 1,
          const GridPoint(0, 0): 9,
          const GridPoint(2,4): 25,
        },
      );
    } else if (levelId == 21) {
      // Level 21: 6x6 Introduction
      return GameLevel(
        id: levelId,
        rows: 6,
        cols: 6,
        timeLimit: 240,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.blue: [const GridPoint(0, 0), const GridPoint(5, 5)]},
        startNode: const GridPoint(0, 0),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(0, 0): 1,
          const GridPoint(0, 5): 6,
          const GridPoint(5, 5): 19, // Parite kuralı: 0+0=0 (çift), 5+5=10 (çift). 6x6=36 (çift). 1'den 36'ya son nokta tek olmalı.
          const GridPoint(3, 2): 36, // Değiştirildi parite için
        },
      );
    } else if (levelId == 22) {
      // Level 22: 6x6 Spiral
      return GameLevel(
        id: levelId,
        rows: 6,
        cols: 6,
        timeLimit: 220,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.green: [const GridPoint(0, 0), const GridPoint(2, 2)]},
        startNode: const GridPoint(0, 0),
        startValue: 10,
        fixedNumbers: {
          const GridPoint(0, 0): 10,
          const GridPoint(0, 5): 15,
          const GridPoint(5, 5): 20,
          const GridPoint(2, 3): 45,
        },
      );
    } else if (levelId == 23) {
      // Level 23: 6x6 vertical snake
      return GameLevel(
        id: levelId,
        rows: 6,
        cols: 6,
        timeLimit: 210,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.orange: [const GridPoint(0, 5), const GridPoint(0, 0)]},
        startNode: const GridPoint(0, 5),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(0, 5): 1,
          const GridPoint(5, 5): 6,
          const GridPoint(4, 2): 16,
          const GridPoint(0, 0): 36,
        },
      );
    } else if (levelId == 24) {
      // Level 24: 6x6 Blocks
      return GameLevel(
        id: levelId,
        rows: 6,
        cols: 6,
        timeLimit: 200,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.pink: [const GridPoint(5, 0), const GridPoint(0, 5)]},
        startNode: const GridPoint(5, 0),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(5, 0): 1,
          const GridPoint(2, 2): 26,
          const GridPoint(1, 3): 36,
        },
      );
    } else if (levelId == 25) {
      // Level 25: 6x6 Middle start
      return GameLevel(
        id: levelId,
        rows: 6,
        cols: 6,
        timeLimit: 190,
        gameType: GameType.numberPath,
        dotPositions: {DotColor.purple: [const GridPoint(2, 2), const GridPoint(5, 5)]},
        startNode: const GridPoint(2, 2),
        startValue: 1,
        fixedNumbers: {
          const GridPoint(2, 2): 1,
          const GridPoint(0, 0): 9,
          const GridPoint(1, 2): 36, // Parite kontrolü gerektirir, 2+2=4 (çift), 5+5=10 (çift). 36. nokta odd olmalı.

        },
      );
    } else if (levelId == 26) {
      // Level 26: 6x6 Zig Zag Hard
      return GameLevel(
        id: levelId,rows: 6,cols: 6,timeLimit: 180,gameType: GameType.numberPath,
        dotPositions: {DotColor.teal: [const GridPoint(0, 0), const GridPoint(5, 5)]},
        startNode: const GridPoint(0, 0),startValue: 101,
        fixedNumbers: {const GridPoint(0, 0): 101, const GridPoint(0, 5): 106, const GridPoint(1, 5): 107, const GridPoint(2, 5): 136},
      );
    } else if (levelId == 27) {
      // Level 27: 6x6 Vertical Focus
      return GameLevel(
        id: levelId,rows: 6,cols: 6,timeLimit: 170,gameType: GameType.numberPath,
        dotPositions: {DotColor.amber: [const GridPoint(0, 3), const GridPoint(5, 2)]},
        startNode: const GridPoint(0, 3),startValue: 150,
        fixedNumbers: {const GridPoint(0, 3): 150, const GridPoint(2, 5): 158, const GridPoint(0, 2): 165, const GridPoint(4, 4): 185},
      );
    } else if (levelId == 28) {
      // Level 28: 6x6 Outer Ring
      return GameLevel(
        id: levelId,rows: 6,cols: 6,timeLimit: 160,gameType: GameType.numberPath,
        dotPositions: {DotColor.indigo: [const GridPoint(0, 0), const GridPoint(1, 1)]},
        startNode: const GridPoint(0, 0),startValue: 100,
        fixedNumbers: {const GridPoint(0, 0): 100, const GridPoint(0, 5): 105, const GridPoint(5, 5): 110, const GridPoint(5, 0): 115, const GridPoint(1, 2): 135},
      );
    } else if (levelId == 29) {
      // Level 29: 6x6 Inner Maze
      return GameLevel(
        id: levelId,rows: 6,cols: 6,timeLimit: 150,gameType: GameType.numberPath,
        dotPositions: {DotColor.pink: [const GridPoint(2, 2), const GridPoint(3, 3)]},
        startNode: const GridPoint(2, 2),startValue: 120,
        fixedNumbers: {const GridPoint(2, 2): 120, const GridPoint(2, 1): 137, const GridPoint(5, 5): 150, const GridPoint(3, 2): 155},
      );
    } else if (levelId == 30) {
      // Level 30: 6x6 Challenge
      return GameLevel(
        id: levelId,rows: 6,cols: 6,timeLimit: 140,gameType: GameType.numberPath,
        dotPositions: {DotColor.red: [const GridPoint(0, 0), const GridPoint(5, 0)]},
        startNode: const GridPoint(0, 0),startValue: 160,
        fixedNumbers: {const GridPoint(0, 0): 160, const GridPoint(5, 5): 190, const GridPoint(5, 0): 195},
      );
    } else if (levelId == 31) {
      // Level 31: 7x7 Entry
      return GameLevel(
        id: levelId,rows: 7,cols: 7,timeLimit: 300,gameType: GameType.numberPath,
        dotPositions: {DotColor.blue: [const GridPoint(0, 0), const GridPoint(6, 6)]},
        startNode: const GridPoint(0, 0),startValue: 100,
        fixedNumbers: {const GridPoint(0, 0): 100, const GridPoint(3, 3): 126, const GridPoint(6, 6): 148},
      );
    } else if (levelId == 32) {
      // Level 32: 7x7 Spiral
      return GameLevel(
        id: levelId,rows: 7,cols: 7,timeLimit: 280,gameType: GameType.numberPath,
        dotPositions: {DotColor.green: [const GridPoint(0, 0), const GridPoint(3, 3)]},
        startNode: const GridPoint(0, 0),startValue: 120,
        fixedNumbers: {const GridPoint(0, 0): 120, const GridPoint(6, 6): 132,  const GridPoint(3, 3): 168},
      );
    } else if (levelId == 33) {
      // Level 33: 7x7 Corners
      return GameLevel(
        id: levelId,rows: 7,cols: 7,timeLimit: 260,gameType: GameType.numberPath,
        dotPositions: {DotColor.yellow: [const GridPoint(0, 0), const GridPoint(0, 6)]},
        startNode: const GridPoint(0, 0),startValue: 150,
        fixedNumbers: {const GridPoint(0, 0): 150,  const GridPoint(2, 1): 191, const GridPoint(0, 6): 198},
      );
    } else if (levelId == 34) {
      // Level 34: 7x7 Cross
      return GameLevel(
        id: levelId,rows: 7,cols: 7,timeLimit: 240,gameType: GameType.numberPath,
        dotPositions: {DotColor.orange: [const GridPoint(3, 0), const GridPoint(3, 6)]},
        startNode: const GridPoint(2, 0),startValue: 100,
        fixedNumbers: {const GridPoint(2, 0): 100, const GridPoint(0, 0): 104, const GridPoint(0, 6): 110, const GridPoint(6, 0): 122,  const GridPoint(2, 4): 148},
      );
    } else if (levelId == 35) {
      // Level 35: 7x7 Master
      return GameLevel(
        id: levelId,rows: 7,cols: 7,timeLimit: 220,gameType: GameType.numberPath,
        dotPositions: {DotColor.teal: [const GridPoint(1, 1), const GridPoint(5, 5)]},
        startNode: const GridPoint(1, 1),startValue: 140,
        fixedNumbers: {const GridPoint(1, 1): 140, const GridPoint(0, 0): 144, const GridPoint(6, 6): 184, const GridPoint(5, 5): 188},
      );
    } else if (levelId == 36) {
      // Level 36: 8x8 Entry
      return GameLevel(
        id: levelId,rows: 8,cols: 8,timeLimit: 400,gameType: GameType.numberPath,
        dotPositions: {DotColor.purple: [const GridPoint(0, 0), const GridPoint(7, 6)]},
        startNode: const GridPoint(0, 0),startValue: 100,
        fixedNumbers: {const GridPoint(0, 0): 100, const GridPoint(4, 2): 120, const GridPoint(7, 6): 163},
      );
    } else if (levelId == 37) {
      // Level 37: 8x8 Zig Zag
      return GameLevel(
        id: levelId,rows: 8,cols: 8,timeLimit: 380,gameType: GameType.numberPath,
        dotPositions: {DotColor.pink: [const GridPoint(0, 0), const GridPoint(7, 0)]},
        startNode: const GridPoint(0, 0),startValue: 130,
        fixedNumbers: {const GridPoint(0, 0): 130, const GridPoint(0, 7): 137, const GridPoint(1, 7): 138, const GridPoint(2, 2): 168, const GridPoint(3, 4): 193},
      );
    } else if (levelId == 38) {
      // Level 38: 8x8 Inner Workings
      return GameLevel(
        id: levelId,rows: 8,cols: 8,timeLimit: 360,gameType: GameType.numberPath,
        dotPositions: {DotColor.blue: [const GridPoint(3, 3), const GridPoint(4, 4)]},
        startNode: const GridPoint(3, 3),startValue: 101,
        fixedNumbers: {const GridPoint(3, 3): 101, const GridPoint(0, 0): 119, const GridPoint(7, 7): 137, const GridPoint(4, 3): 164},
      );
    } else if (levelId == 39) {
      // Level 39: 8x8 Dual Spiral
      return GameLevel(
        id: levelId,rows: 8,cols: 8,timeLimit: 340,gameType: GameType.numberPath,
        dotPositions: {DotColor.green: [const GridPoint(0, 7), const GridPoint(7, 0)]},
        startNode: const GridPoint(0, 7),startValue: 110,
        fixedNumbers: {const GridPoint(0, 7): 110, const GridPoint(7, 7): 117, const GridPoint(0, 0): 151, const GridPoint(6, 0): 173},
      );
    } else if (levelId == 40) {
      // Level 40: 8x8 Grandmaster Intro
      return GameLevel(
        id: levelId,rows: 8,cols: 8,timeLimit: 300,gameType: GameType.numberPath,
        dotPositions: {DotColor.red: [const GridPoint(0, 0), const GridPoint(7, 6)]},
        startNode: const GridPoint(0, 0),startValue: 120,
        fixedNumbers: {const GridPoint(0, 0): 120, const GridPoint(2, 2): 128, const GridPoint(5, 4): 149, const GridPoint(7, 0): 183},
      );
    } else if (levelId == 41) {
      // Level 41: 9x9 Entry
      return GameLevel(
        id: levelId,rows: 9,cols: 9,timeLimit: 500,gameType: GameType.numberPath,
        dotPositions: {DotColor.blue: [const GridPoint(0, 0), const GridPoint(8, 8)]},
        startNode: const GridPoint(0, 0),startValue: 100,
        fixedNumbers: {const GridPoint(0, 0): 100, const GridPoint(2, 1): 117, const GridPoint(4, 4): 140, const GridPoint(8, 8): 180},
      );
    } else if (levelId == 42) {
      // Level 42: 9x9 Spiral
      return GameLevel(
        id: levelId,rows: 9,cols: 9,timeLimit: 480,gameType: GameType.numberPath,
        dotPositions: {DotColor.green: [const GridPoint(0, 0), const GridPoint(4, 4)]},
        startNode: const GridPoint(0, 0),startValue: 110,
        fixedNumbers: {const GridPoint(0, 0): 110, const GridPoint(8, 8): 140, const GridPoint(4, 4): 190},
      );
    } else if (levelId == 43) {
      // Level 43: 9x9 Zig Zag
      return GameLevel(
        id: levelId,rows: 9,cols: 9,timeLimit: 460,gameType: GameType.numberPath,
        dotPositions: {DotColor.yellow: [const GridPoint(0, 0), const GridPoint(8, 0)]},
        startNode: const GridPoint(0, 0),startValue: 101,
        fixedNumbers: {const GridPoint(0, 0): 101, const GridPoint(0, 8): 109, const GridPoint(8, 8): 145, const GridPoint(8, 0): 181},
      );
    } else if (levelId == 44) {
      // Level 44: 9x9 Inner Maze
      return GameLevel(
        id: levelId,rows: 9,cols: 9,timeLimit: 440,gameType: GameType.numberPath,
        dotPositions: {DotColor.orange: [const GridPoint(1, 1), const GridPoint(7, 7)]},
        startNode: const GridPoint(1, 1),startValue: 110,
        fixedNumbers: {const GridPoint(1, 1): 110, const GridPoint(0, 0): 114, const GridPoint(8, 8): 186, const GridPoint(7, 7): 190},
      );
    } else if (levelId == 45) {
      // Level 45: 9x9 Master
      return GameLevel(
        id: levelId,rows: 9,cols: 9,timeLimit: 400,gameType: GameType.numberPath,
        dotPositions: {DotColor.teal: [const GridPoint(0, 4), const GridPoint(8, 4)]},
        startNode: const GridPoint(0, 4),startValue: 115,
        fixedNumbers: {const GridPoint(0, 4): 115, const GridPoint(8, 4): 195},
      );
    } else if (levelId == 46) {
      // Level 46: 10x10 Entry
      return GameLevel(
        id: levelId,rows: 10,cols: 10,timeLimit: 600,gameType: GameType.numberPath,
        dotPositions: {DotColor.purple: [const GridPoint(0, 0), const GridPoint(9, 8)]},
        startNode: const GridPoint(0, 0),startValue: 101,
        fixedNumbers: {const GridPoint(0, 0): 101, const GridPoint(5, 5): 151, const GridPoint(9, 8): 200},
      );
    } else if (levelId == 47) {
      // Level 47: 10x10 Spiral
      return GameLevel(
        id: levelId,rows: 10,cols: 10,timeLimit: 580,gameType: GameType.numberPath,
        dotPositions: {DotColor.pink: [const GridPoint(0, 0), const GridPoint(5, 4)]},
        startNode: const GridPoint(0, 0),startValue: 1,
        fixedNumbers: {const GridPoint(0, 0): 1, const GridPoint(9, 9): 39, const GridPoint(5, 4): 100},
      );
    } else if (levelId == 48) {
      // Level 48: 10x10 Hard Maze
      return GameLevel(
        id: levelId,rows: 10,cols: 10,timeLimit: 560,gameType: GameType.numberPath,
        dotPositions: {DotColor.blue: [const GridPoint(0, 0), const GridPoint(0, 1)]},
        startNode: const GridPoint(5, 5),startValue: 101,
        fixedNumbers: {const GridPoint(5, 5): 101, const GridPoint(9, 8): 150, const GridPoint(0, 1): 200},
      );
    } else if (levelId == 49) {
      // Level 49: 10x10 Zig Zag Master - Revised
      return GameLevel(
        id: levelId,
        rows: 10,
        cols: 10,
        timeLimit: 540,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.green: [const GridPoint(1, 1), const GridPoint(9, 9)],
        },
        startNode: const GridPoint(1, 1),
        startValue: 10,
        fixedNumbers: {
          const GridPoint(1, 1): 10,
          const GridPoint(0, 3): 15,
          const GridPoint(3, 0): 21,
          const GridPoint(5, 5): 40,
          const GridPoint(9, 2): 71,
          const GridPoint(7, 8):105,
          const GridPoint(8, 9): 109,
        },
      );
    } else if (levelId == 50) {
      // Level 50: 10x10 Grandmaster Finals - Revised
      return GameLevel(
        id: levelId,
        rows: 10,
        cols: 10,
        timeLimit: 500,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.red: [const GridPoint(4, 4), const GridPoint(5, 4)],
        },
        startNode: const GridPoint(4, 4),
        startValue: 20,
        fixedNumbers: {
          const GridPoint(4, 4): 20,
          const GridPoint(0, 0): 44,
          const GridPoint(0, 9): 59,
          const GridPoint(9, 9): 74,
          const GridPoint(9, 0): 83,
          const GridPoint(5, 4): 119,
        },
      );
    }
    
    // Fallback: use color levels for undefined number levels
    return generateColorLevel(levelId);
  }
  static GameLevel generateColorLevel(int levelId) {
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
      positions[DotColor.purple] = [const GridPoint(0, 0), const GridPoint(3, 0)];
      positions[DotColor.red] = [const GridPoint(0, 1), const GridPoint(3, 1)];
      positions[DotColor.teal] = [const GridPoint(0, 2), const GridPoint(3, 2)];
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
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(0, 3)];
    }else if (levelId == 22) {
      positions[DotColor.red]    = [const GridPoint(0, 4), const GridPoint(3, 4)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(3, 2)];
      positions[DotColor.pink]   = [const GridPoint(4, 0), const GridPoint(4, 4)];
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(2, 1)];
    }else if (levelId == 23) {
      positions[DotColor.red]    = [const GridPoint(0, 5), const GridPoint(4, 5)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(4, 2)];
      positions[DotColor.pink]   = [const GridPoint(5, 0), const GridPoint(5, 5)];
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(2, 1)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(3, 3)];
    }else if (levelId == 24) {
      positions[DotColor.red]    = [const GridPoint(0, 5), const GridPoint(4, 5)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(4, 2)];
      positions[DotColor.pink]   = [const GridPoint(5, 0), const GridPoint(5, 5)];
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(2, 1)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(2, 4)];
      positions[DotColor.green]  = [const GridPoint(3, 3), const GridPoint(4, 3)];
    }else if (levelId == 25) {
      positions[DotColor.red]    = [const GridPoint(0, 5), const GridPoint(4, 5)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(4, 2)];
      positions[DotColor.pink]   = [const GridPoint(5, 0), const GridPoint(5, 5)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(2, 4)];
      positions[DotColor.green]  = [const GridPoint(0, 2), const GridPoint(4, 3)];
    }else if(levelId == 26) {
      positions[DotColor.red]    = [const GridPoint(0, 5), const GridPoint(4, 5)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(4, 2)];
      positions[DotColor.pink]   = [const GridPoint(5, 0), const GridPoint(5, 5)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(2, 4)];
      positions[DotColor.green]  = [const GridPoint(0, 2), const GridPoint(4, 3)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(3, 1)];
    }else if (levelId == 27) {
      positions[DotColor.red]    = [const GridPoint(0, 5), const GridPoint(5, 5)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(4, 2)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(2, 4)];
      positions[DotColor.green]  = [const GridPoint(0, 2), const GridPoint(4, 3)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(4, 1)];
    }else if (levelId == 28) {
      positions[DotColor.red]    = [const GridPoint(0, 5), const GridPoint(5, 5)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(4, 2)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(2, 4)];
      positions[DotColor.green]  = [const GridPoint(0, 2), const GridPoint(4, 3)];
      positions[DotColor.yellow] = [const GridPoint(1, 0), const GridPoint(4, 0)];
      positions[DotColor.pink]   = [const GridPoint(5, 0), const GridPoint(5, 4)];
    }else if (levelId == 29) {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(0, 5)];
      positions[DotColor.blue]   = [const GridPoint(1, 0), const GridPoint(5, 0)];
      positions[DotColor.yellow] = [const GridPoint(5, 2), const GridPoint(5, 5)];
      positions[DotColor.green]  = [const GridPoint(1, 5), const GridPoint(4, 5)]; 
      positions[DotColor.pink]   = [const GridPoint(1, 1), const GridPoint(3, 2)]; 
      positions[DotColor.orange] = [const GridPoint(3, 3), const GridPoint(4, 4)];
    }else if(levelId == 30){
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(5, 0)];
      positions[DotColor.blue]   = [const GridPoint(0, 5), const GridPoint(5, 5)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(0, 4)];
      positions[DotColor.green]  = [const GridPoint(5, 1), const GridPoint(5, 4)];
      positions[DotColor.pink]   = [const GridPoint(1, 1), const GridPoint(1, 2)]; 
      positions[DotColor.orange] = [const GridPoint(4, 3), const GridPoint(4, 4)];
    }else if(levelId == 31){
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(6, 0)];
      positions[DotColor.blue]   = [const GridPoint(0, 6), const GridPoint(6, 6)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(0, 5)];
      positions[DotColor.green]  = [const GridPoint(6, 1), const GridPoint(6, 5)];
      positions[DotColor.pink]   = [const GridPoint(1, 1), const GridPoint(5, 1)];
      positions[DotColor.orange] = [const GridPoint(1, 5), const GridPoint(5, 5)];
      positions[DotColor.purple] = [const GridPoint(1, 2), const GridPoint(5, 4)];
    }else if(levelId == 32){
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(0, 6)];
      positions[DotColor.blue]   = [const GridPoint(6, 0), const GridPoint(6, 6)];
      positions[DotColor.purple] = [const GridPoint(4, 1), const GridPoint(3, 5)];
      positions[DotColor.yellow] = [const GridPoint(1, 0), const GridPoint(5, 0)];
      positions[DotColor.green]  = [const GridPoint(1, 6), const GridPoint(5, 6)];
      positions[DotColor.pink]   = [const GridPoint(2, 1), const GridPoint(1, 5)];
      positions[DotColor.orange] = [const GridPoint(5, 1), const GridPoint(5, 5)];
    }else if(levelId == 33) {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(6, 0)];
      positions[DotColor.blue]   = [const GridPoint(0, 6), const GridPoint(6, 6)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(0, 5)];
      positions[DotColor.green]  = [const GridPoint(6, 1), const GridPoint(6, 5)];
      positions[DotColor.pink]   = [const GridPoint(2, 1), const GridPoint(5, 1)];
      positions[DotColor.orange] = [const GridPoint(1, 5), const GridPoint(5, 5)];
    }else if (levelId == 34) {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(0, 6)];
      positions[DotColor.yellow] = [const GridPoint(1, 0), const GridPoint(1, 6)];
      positions[DotColor.green]  = [const GridPoint(5, 0), const GridPoint(5, 6)];
      positions[DotColor.blue]   = [const GridPoint(6, 0), const GridPoint(6, 6)];
      positions[DotColor.pink]   = [const GridPoint(2, 0), const GridPoint(4, 2)];
      positions[DotColor.orange] = [const GridPoint(2, 3), const GridPoint(4, 3)];
      positions[DotColor.purple] = [const GridPoint(4, 4), const GridPoint(2, 6)];
    }else if (levelId == 35) {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(6, 0)];
      positions[DotColor.blue]   = [const GridPoint(0, 6), const GridPoint(6, 6)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(0, 5)];
      positions[DotColor.green]  = [const GridPoint(6, 1), const GridPoint(6, 5)];
      positions[DotColor.pink]   = [const GridPoint(1, 1), const GridPoint(5, 1)];
      positions[DotColor.orange] = [const GridPoint(1, 2), const GridPoint(5, 2)];
      positions[DotColor.purple] = [const GridPoint(1, 3), const GridPoint(5, 5)];
   }else if(levelId == 36) {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(6, 0)];
      positions[DotColor.blue]   = [const GridPoint(0, 6), const GridPoint(6, 6)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(0, 5)];
      positions[DotColor.green]  = [const GridPoint(6, 1), const GridPoint(6, 5)];
      positions[DotColor.pink]   = [const GridPoint(1, 1), const GridPoint(1, 5)];
      positions[DotColor.orange] = [const GridPoint(2, 1), const GridPoint(2, 5)];
      positions[DotColor.purple] = [const GridPoint(3, 1), const GridPoint(3, 5)];
      positions[DotColor.cyan]   = [const GridPoint(4, 5), const GridPoint(5, 5)];
    }else if (levelId == 37) {
      positions[DotColor.red]    = [const GridPoint(0, 3), const GridPoint(2, 3)];
      positions[DotColor.blue]   = [const GridPoint(3, 0), const GridPoint(3, 6)];
      positions[DotColor.yellow] = [const GridPoint(4, 3), const GridPoint(6, 3)];
      positions[DotColor.pink]   = [const GridPoint(0, 0), const GridPoint(1, 1)];
      positions[DotColor.orange] = [const GridPoint(6, 6), const GridPoint(5, 5)];
      positions[DotColor.purple] = [const GridPoint(6, 0), const GridPoint(5, 1)];
      positions[DotColor.teal]   = [const GridPoint(0, 6), const GridPoint(1, 5)];
    }else if (levelId == 38) {
      positions[DotColor.red]    = [const GridPoint(3, 3), const GridPoint(0, 0)];
      positions[DotColor.blue]   = [const GridPoint(3, 2), const GridPoint(6, 0)];
      positions[DotColor.yellow] = [const GridPoint(4, 3), const GridPoint(6, 6)];
      positions[DotColor.green]  = [const GridPoint(3, 4), const GridPoint(0, 6)];
      positions[DotColor.orange] = [const GridPoint(5, 3), const GridPoint(6, 3)];
      positions[DotColor.purple] = [const GridPoint(3, 0), const GridPoint(3, 1)];
    }else if (levelId == 39) {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(0, 6)];
      positions[DotColor.blue]   = [const GridPoint(6, 0), const GridPoint(6, 6)];
      positions[DotColor.yellow] = [const GridPoint(1, 0), const GridPoint(5, 0)];
      positions[DotColor.green]  = [const GridPoint(1, 6), const GridPoint(5, 6)];
      positions[DotColor.pink]   = [const GridPoint(1, 1), const GridPoint(5, 2)];
      positions[DotColor.orange] = [const GridPoint(1, 5), const GridPoint(5, 4)];
      positions[DotColor.purple] = [const GridPoint(1, 3), const GridPoint(5, 3)];
    }else if (levelId == 40) {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(6, 0)];
      positions[DotColor.blue]   = [const GridPoint(0, 6), const GridPoint(6, 6)];
      positions[DotColor.yellow] = [const GridPoint(0, 1), const GridPoint(0, 5)];
      positions[DotColor.green]  = [const GridPoint(6, 1), const GridPoint(6, 5)];
      positions[DotColor.pink]   = [const GridPoint(1, 1), const GridPoint(1, 5)];
      positions[DotColor.orange] = [const GridPoint(5, 1), const GridPoint(5, 5)];
      positions[DotColor.purple] = [const GridPoint(2, 1), const GridPoint(4, 3)];
      positions[DotColor.white]   = [const GridPoint(2, 4), const GridPoint(4, 5)];
    }else if (levelId == 41) {
      positions[DotColor.purple] = [const GridPoint(3, 0), const GridPoint(3, 7)];
      positions[DotColor.orange] = [const GridPoint(4, 0), const GridPoint(4, 7)];
      positions[DotColor.yellow] = [const GridPoint(0, 3), const GridPoint(2, 3)];
      positions[DotColor.white]   = [const GridPoint(5, 4), const GridPoint(7, 4)];
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(0, 2)];
      positions[DotColor.blue]   = [const GridPoint(0, 4), const GridPoint(0, 7)];
      positions[DotColor.green]  = [const GridPoint(7, 0), const GridPoint(7, 3)];
      positions[DotColor.pink]   = [const GridPoint(7, 5), const GridPoint(7, 7)];
    }else if (levelId == 42) {
      positions[DotColor.red] = [const GridPoint(7, 0), const GridPoint(0, 7)];
      positions[DotColor.green] = [const GridPoint(3, 0), const GridPoint(4, 0)];
      positions[DotColor.pink] = [const GridPoint(0, 3), const GridPoint(0, 4)];
      positions[DotColor.yellow] = [const GridPoint(3, 7), const GridPoint(4, 7)];
      positions[DotColor.orange] = [const GridPoint(2, 2), const GridPoint(4, 4)];
    } else if (levelId == 43) {
      positions[DotColor.red] = [const GridPoint(0, 0), const GridPoint(3, 3)];
      positions[DotColor.blue] = [const GridPoint(7, 0), const GridPoint(4, 3)];
      positions[DotColor.green] = [const GridPoint(7, 7), const GridPoint(4, 4)];
      positions[DotColor.yellow] = [const GridPoint(0, 7), const GridPoint(3, 4)];
      positions[DotColor.purple] = [const GridPoint(3, 0), const GridPoint(4, 0)];
      positions[DotColor.orange] = [const GridPoint(7, 3), const GridPoint(7, 4)];
      positions[DotColor.pink] = [const GridPoint(3, 7), const GridPoint(4, 7)];
      positions[DotColor.indigo] = [const GridPoint(0, 3), const GridPoint(0, 4)];
    } else if (levelId == 44) {
      positions[DotColor.teal] = [const GridPoint(1, 1), const GridPoint(7, 1)];
      positions[DotColor.yellow] = [const GridPoint(3, 2), const GridPoint(5, 2)];
      positions[DotColor.orange] = [const GridPoint(2, 6), const GridPoint(6, 5)];
      positions[DotColor.red] = [const GridPoint(4, 2), const GridPoint(4, 6)];
      positions[DotColor.blue] = [const GridPoint(3, 4), const GridPoint(4, 5)];
    } else if (levelId == 45) {
      positions[DotColor.teal] = [const GridPoint(1, 1), const GridPoint(7, 0)];
      positions[DotColor.red]  = [const GridPoint(1, 7), const GridPoint(7, 7)];
      positions[DotColor.blue]   = [const GridPoint(0, 3), const GridPoint(0, 5)]; 
      positions[DotColor.pink] = [const GridPoint(5, 3), const GridPoint(5, 5)];
      positions[DotColor.yellow] = [const GridPoint(6, 3), const GridPoint(6, 5)];
    } else if (levelId == 46) {
      positions[DotColor.teal] = [const GridPoint(0, 0), const GridPoint(6, 0)];
      positions[DotColor.red]  = [const GridPoint(0, 8), const GridPoint(6, 8)];
      positions[DotColor.orange] = [const GridPoint(0, 2), const GridPoint(6, 2)];
      positions[DotColor.purple] = [const GridPoint(0, 6), const GridPoint(6, 6)];
      positions[DotColor.blue]   = [const GridPoint(1, 3), const GridPoint(1, 5)];
      positions[DotColor.yellow] = [const GridPoint(5, 3), const GridPoint(5, 5)];
      positions[DotColor.pink] = [const GridPoint(3, 1), const GridPoint(3, 7)];
    } else if (levelId == 47) {
      positions[DotColor.blue] = [const GridPoint(0, 0), const GridPoint(1, 1)];
      positions[DotColor.purple] = [const GridPoint(4, 0), const GridPoint(5, 0)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(0, 4)];
      positions[DotColor.amber] = [const GridPoint(3, 3), const GridPoint(6, 6)];
      positions[DotColor.white] = [const GridPoint(6, 3), const GridPoint(3, 6)];
    }else if (levelId == 48) {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(8, 0)];
      positions[DotColor.blue]   = [const GridPoint(0, 7), const GridPoint(7, 7)];
      positions[DotColor.green]  = [const GridPoint(0, 1), const GridPoint(0, 6)];
      positions[DotColor.yellow] = [const GridPoint(7, 1), const GridPoint(7, 6)];
      positions[DotColor.purple] = [const GridPoint(1, 1), const GridPoint(3, 3)];
      positions[DotColor.orange] = [const GridPoint(4, 1), const GridPoint(6, 3)];
      positions[DotColor.pink]   = [const GridPoint(1, 4), const GridPoint(3, 6)];
      positions[DotColor.teal]   = [const GridPoint(4, 4), const GridPoint(6, 6)];
    }else if (levelId == 49) {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(0, 8)];
      positions[DotColor.blue]   = [const GridPoint(7, 0), const GridPoint(7, 7)];
      positions[DotColor.green]  = [const GridPoint(1, 0), const GridPoint(2, 7)];
      positions[DotColor.yellow] = [const GridPoint(3, 7), const GridPoint(4, 0)];
      positions[DotColor.purple] = [const GridPoint(6, 0), const GridPoint(6, 7)];
    }else {
      positions[DotColor.red]    = [const GridPoint(0, 0), const GridPoint(3, 3)];
      positions[DotColor.blue]   = [const GridPoint(7, 0), const GridPoint(4, 3)];
      positions[DotColor.green]  = [const GridPoint(0, 7), const GridPoint(3, 4)];
      positions[DotColor.yellow] = [const GridPoint(7, 7), const GridPoint(4, 4)];
      positions[DotColor.purple] = [const GridPoint(1, 2), const GridPoint(2, 1)];
      positions[DotColor.orange] = [const GridPoint(5, 1), const GridPoint(6, 2)];
      positions[DotColor.pink]   = [const GridPoint(1, 5), const GridPoint(2, 6)];
      positions[DotColor.white]   = [const GridPoint(5, 6), const GridPoint(7, 5)];
    }

    // Grid Size Scaling Logic
    int size = 2;
    if (levelId >= 2 && levelId <= 5) size = 3;
    else if (levelId >= 6 && levelId <= 12) size = 4;
    else if (levelId >= 13 && levelId <= 22) size = 5;
    else if (levelId >= 22 && levelId <= 30) size = 6;
    else if (levelId >= 31 && levelId <= 40) size = 7;
    else if (levelId >= 41 && levelId <= 45) size = 8;
    else if (levelId > 45) size = 9;
    // Determine time limit based on custom User Request
    int timeLimit = 60;
    if (levelId == 1) timeLimit = 5;
    else if (levelId <= 5) timeLimit = 7;
    else if (levelId <= 12) timeLimit = 10;
    else if (levelId <= 22) timeLimit = 13;
    else if (levelId <= 30) timeLimit = 23;
    else if (levelId <= 40) timeLimit = 30;
    else if (levelId <= 45) timeLimit = 40;
    else timeLimit = 60; // Level 46-50
    
    return GameLevel(
      id: levelId,
      rows: size,
      cols: size,
      timeLimit: timeLimit,
      dotPositions: positions,
    );
  }

  static GameLevel generateOperationLevel(int levelId) {
    if (levelId == 1) {
      // Level 1: Start (0,0)=2 -> +3 -> *2 -> Target(1,0)+0 = 10
      return GameLevel(
        id: levelId,
        rows: 2,
        cols: 2,
        timeLimit: 60,
        gameType: GameType.operationPath,
        dotPositions: {
          DotColor.green: [const GridPoint(0, 0), const GridPoint(1, 0)],
        },
        startNode: const GridPoint(0, 0),
        startValue: 2,
        targetNode: const GridPoint(1, 0),
        targetValue: 10,
        operations: {
          const GridPoint(0, 1): const OperationCell(type: OperationType.add, operand: 3),
          const GridPoint(1, 1): const OperationCell(type: OperationType.multiply, operand: 2),
          const GridPoint(1, 0): const OperationCell(type: OperationType.add, operand: 0),
        },
      );
    } else if (levelId == 2) {
      // Level 2: Start (1,1)=10 -> -4 -> +1 -> Target(0,1)*3 = 21
      return GameLevel(
        id: levelId,
        rows: 2,
        cols: 2,
        timeLimit: 60,
        gameType: GameType.operationPath,
        dotPositions: {
          DotColor.green: [const GridPoint(1, 1), const GridPoint(0, 1)],
        },
        startNode: const GridPoint(1, 1),
        startValue: 10,
        targetNode: const GridPoint(0, 1),
        targetValue: 21,
        operations: {
          const GridPoint(1, 0): const OperationCell(type: OperationType.subtract, operand: 4),
          const GridPoint(0, 0): const OperationCell(type: OperationType.add, operand: 1),
          const GridPoint(0, 1): const OperationCell(type: OperationType.multiply, operand: 3),
        },
      );
    } else if (levelId == 3) {
      // Level 3: Start (1,0)=4 -> *4 -> -6 -> Target(1,1)/2 = 5
      return GameLevel(
        id: levelId,
        rows: 2,
        cols: 2,
        timeLimit: 60,
        gameType: GameType.operationPath,
        dotPositions: {
          DotColor.green: [const GridPoint(1, 0), const GridPoint(1, 1)],
        },
        startNode: const GridPoint(1, 0),
        startValue: 4,
        targetNode: const GridPoint(1, 1),
        targetValue: 5,
        operations: {
          const GridPoint(0, 0): const OperationCell(type: OperationType.multiply, operand: 4),
          const GridPoint(0, 1): const OperationCell(type: OperationType.subtract, operand: 6),
          const GridPoint(1, 1): const OperationCell(type: OperationType.divide, operand: 2),
        },
      );
    } else if (levelId == 4) {
      // Level 4: Start (0,1)=100 -> /2 -> -10 -> Target(1,1)*2 = 80
      return GameLevel(
        id: levelId,
        rows: 2,
        cols: 2,
        timeLimit: 60,
        gameType: GameType.operationPath,
        dotPositions: {
          DotColor.green: [const GridPoint(0, 1), const GridPoint(1, 1)],
        },
        startNode: const GridPoint(0, 1),
        startValue: 100,
        targetNode: const GridPoint(1, 1),
        targetValue: 80,
        operations: {
          const GridPoint(0, 0): const OperationCell(type: OperationType.divide, operand: 2),
          const GridPoint(1, 0): const OperationCell(type: OperationType.subtract, operand: 10),
          const GridPoint(1, 1): const OperationCell(type: OperationType.multiply, operand: 2),
        },
      );
    } else if (levelId == 5) {
      // Level 5: Start (0,0)=7 -> +3 -> *4 -> Target(0,1)/2 = 20
      return GameLevel(
        id: levelId,
        rows: 2,
        cols: 2,
        timeLimit: 60,
        gameType: GameType.operationPath,
        dotPositions: {
          DotColor.green: [const GridPoint(0, 0), const GridPoint(0, 1)],
        },
        startNode: const GridPoint(0, 0),
        startValue: 7,
        targetNode: const GridPoint(0, 1),
        targetValue: 20,
        operations: {
          const GridPoint(1, 0): const OperationCell(type: OperationType.add, operand: 3),
          const GridPoint(1, 1): const OperationCell(type: OperationType.multiply, operand: 4),
          const GridPoint(0, 1): const OperationCell(type: OperationType.divide, operand: 2),
        },
      );
    }
    // Fallback: use color levels for undefined operation levels
    return generateColorLevel(levelId);
  }
}

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
    // Route to number matching for Number Island
    if (islandId == "2") {
      return generateNumberLevel(levelId);
    }
    
    // Default: Color dot puzzle
    return generateColorLevel(levelId);
  }

  // Generate number matching puzzle (for Number Island)
  // Uses color dot system but displays as numbers (1→1, 2→2, etc.)
  static GameLevel generateNumberLevel(int levelId) {
    if (levelId == 1) {
      // Level 1: Simple 3x3, match 1→1 and 2→2
      return GameLevel(
        id: levelId,
        rows: 3,
        cols: 3,
        timeLimit: 15,
        gameType: GameType.numberPath, // Use numberPath to trigger number rendering
        dotPositions: {
          DotColor.red: [const GridPoint(0, 0), const GridPoint(2, 2)],    // Will show as 1→1
          DotColor.blue: [const GridPoint(0, 2), const GridPoint(2, 0)],   // Will show as 2→2
        },
        fixedNumbers: {
          // Map positions to numbers for display
          const GridPoint(0, 0): 1,
          const GridPoint(2, 2): 1,
          const GridPoint(0, 2): 2,
          const GridPoint(2, 0): 2,
        },
      );
    } else if (levelId == 2) {
      // Level 2: 4x4, match 1→1, 2→2, 3→3
      return GameLevel(
        id: levelId,
        rows: 4,
        cols: 4,
        timeLimit: 20,
        gameType: GameType.numberPath,
        dotPositions: {
          DotColor.red: [const GridPoint(0, 0), const GridPoint(3, 3)],
          DotColor.blue: [const GridPoint(0, 3), const GridPoint(3, 0)],
          DotColor.green: [const GridPoint(1, 1), const GridPoint(2, 2)],
        },
        fixedNumbers: {
          const GridPoint(0, 0): 1,
          const GridPoint(3, 3): 1,
          const GridPoint(0, 3): 2,
          const GridPoint(3, 0): 2,
          const GridPoint(1, 1): 3,
          const GridPoint(2, 2): 3,
        },
      );
    }
    
    // Fallback: use color levels for undefined number levels
    return generateColorLevel(levelId);
  }

  // Generate color dot puzzle (original logic)
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
}

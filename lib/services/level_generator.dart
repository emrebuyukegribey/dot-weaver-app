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
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(0, 3)];
    } else if (levelId == 22) {
      positions[DotColor.red]    = [const GridPoint(0, 4), const GridPoint(3, 4)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(3, 2)];
      positions[DotColor.pink]   = [const GridPoint(4, 0), const GridPoint(4, 4)];
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(2, 1)];
    } else if (levelId == 23) {
      positions[DotColor.red]    = [const GridPoint(0, 5), const GridPoint(4, 5)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(4, 2)];
      positions[DotColor.pink]   = [const GridPoint(5, 0), const GridPoint(5, 5)];
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(2, 1)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(3, 3)];
    } else if (levelId == 24) {
      positions[DotColor.red]    = [const GridPoint(0, 5), const GridPoint(4, 5)];
      positions[DotColor.blue]   = [const GridPoint(0, 0), const GridPoint(4, 2)];
      positions[DotColor.pink]   = [const GridPoint(5, 0), const GridPoint(5, 5)];
      positions[DotColor.yellow] = [const GridPoint(0, 2), const GridPoint(2, 1)];
      positions[DotColor.orange] = [const GridPoint(0, 3), const GridPoint(2, 4)];
      positions[DotColor.green]  = [const GridPoint(3, 3), const GridPoint(4, 3)];
    } else if (levelId == 25) {
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
} else if (levelId == 28) {
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
    }else if (levelId >= 40 && levelId <= 50) {
      // Procedural fallback for 26-50 to ensure solvability without manually writing 25 more cases
      // We place dots in pairs using a deterministic pattern based on levelId
      // Pattern: Perimeter Walk + Crosses
      final int size = (levelId <= 30) ? 6 : (levelId <= 40) ? 7 : 8;
      
      for (int i = 0; i < colors.length; i++) {
        GridPoint p1, p2;
        int mode = (levelId + i) % 4;
        
        if (mode == 0) {
          // Vertical columns
          p1 = GridPoint(i % size, 0); 
          p2 = GridPoint(i % size, size - 1);
        } else if (mode == 1) {
          // Horizontal rows
          p1 = GridPoint(0, i % size);
          p2 = GridPoint(size - 1, i % size);
        } else if (mode == 2) {
          // Diagonal TL-BR offset
          int offset = i % (size - 1);
          p1 = GridPoint(0, offset);
          p2 = GridPoint(size - 1 - offset, size - 1);
        } else {
          // Scattered
          p1 = GridPoint((i * 2) % size, (i * 3) % size);
          p2 = GridPoint(size - 1 - ((i * 2) % size), size - 1 - ((i * 3) % size));
        }

        // Safety check to ensure distinct points - simplified
        if (p1 == p2) p2 = GridPoint(p1.row, (p1.col + 1) % size);
        
        positions[colors[i]] = [p1, p2];
      }
    } else {
      // Generic Fallback
      for (int i = 0; i < colors.length; i++) {
        positions[colors[i]] = [GridPoint(i, 0), GridPoint(i, 1)];
      }
    }

    // Grid Size Scaling Logic
    // Grid Size Scaling Logic
    int size = 2;
    if (levelId >= 2 && levelId <= 5) size = 3;
    else if (levelId >= 6 && levelId <= 12) size = 4;
    else if (levelId >= 13 && levelId <= 22) size = 5;
    else if (levelId >= 22 && levelId <= 30) size = 6;
    else if (levelId >= 31 && levelId <= 40) size = 7;
    else if (levelId >= 41 && levelId <= 50) size = 8;
    else if (levelId > 50) size = 8; // Cap at 8x8 for now

    return GameLevel(
      id: levelId,
      rows: size,
      cols: size,
      dotPositions: positions,
    );
  }
}

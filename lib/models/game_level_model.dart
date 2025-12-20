import 'package:flutter/material.dart';

enum DotColor {
  red,
  blue,
  green,
  yellow,
  purple,
  orange,
  pink,
  teal,
  amber,
  indigo,
  cyan,
  white,
  grey,
  black,
}

extension DotColorExtension on DotColor {
  Color get color {
    switch (this) {
      case DotColor.red: return Colors.redAccent;
      case DotColor.blue: return Colors.blueAccent;
      case DotColor.green: return Colors.greenAccent;
      case DotColor.yellow: return Colors.yellowAccent;
      case DotColor.purple: return Colors.purpleAccent;
      case DotColor.orange: return Colors.orangeAccent;
      case DotColor.pink: return Colors.pinkAccent;
      case DotColor.teal: return Colors.tealAccent;
      case DotColor.amber: return Colors.amberAccent;
      case DotColor.indigo: return Colors.indigoAccent;
      case DotColor.cyan: return Colors.cyanAccent;
      case DotColor.white: return Colors.white;
      case DotColor.grey: return Colors.grey;
      case DotColor.black: return Colors.black;
    }
  }
}

class GridPoint {
  final int row;
  final int col;

  const GridPoint(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPoint &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'GridPoint($row, $col)';
}

class GameLevel {
  final int id;
  final int rows;
  final int cols;
  final int timeLimit; // Time in seconds
  final Map<DotColor, List<GridPoint>> dotPositions; // Defines START and END points for each color

  const GameLevel({
    required this.id,
    required this.rows,
    required this.cols,
    this.timeLimit = 60, // Default 60 seconds
    required this.dotPositions,
  });
}

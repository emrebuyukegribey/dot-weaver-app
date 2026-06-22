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
  /// Hand-tuned, perceptually-separated palette (bright on the dark board).
  /// The default Material *Accent* colors were too close at higher levels —
  /// blue≈indigo, cyan≈teal, yellow≈amber, red≈pink — so these spread the hues
  /// (and re-purpose amber as a lime, indigo as a violet) to stay distinguishable
  /// even when many colors appear together.
  Color get color {
    switch (this) {
      case DotColor.red: return const Color(0xFFFF4438);     // red
      case DotColor.orange: return const Color(0xFFFF8A00);  // orange
      case DotColor.amber: return const Color(0xFFB6F500);   // lime / chartreuse
      case DotColor.yellow: return const Color(0xFFFFE600);  // yellow
      case DotColor.green: return const Color(0xFF2BD94B);   // green
      case DotColor.teal: return const Color(0xFF00E5C0);    // teal / aqua
      case DotColor.cyan: return const Color(0xFF18C8FF);    // sky / cyan
      case DotColor.blue: return const Color(0xFF2D7DFF);    // blue
      case DotColor.indigo: return const Color(0xFF8C5BFF);  // violet
      case DotColor.purple: return const Color(0xFFD64BFF);  // magenta-purple
      case DotColor.pink: return const Color(0xFFFF4D88);    // rose pink
      case DotColor.white: return Colors.white;
      case DotColor.grey: return const Color(0xFFAEBFCB);
      case DotColor.black: return const Color(0xFF5A6B78);
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

// NEW: Game type enum
enum GameType {
  colorDots,    // Original color-matching puzzle
  numberPath,   // Sequential number path puzzle
  operationPath, // Sequential math operation puzzle
}

enum OperationType { add, subtract, multiply, divide }

class OperationCell {
  final OperationType type;
  final int operand;

  const OperationCell({required this.type, required this.operand});

  String get display => switch (type) {
        OperationType.add => '+$operand',
        OperationType.subtract => '-$operand',
        OperationType.multiply => '×$operand',
        OperationType.divide => '÷$operand',
      };
}

class GameLevel {
  final int id;
  final int rows;
  final int cols;
  final int timeLimit; // Time in seconds
  final GameType gameType; // NEW: Type of puzzle
  final Map<DotColor, List<GridPoint>> dotPositions; // For color dot puzzles
  final Map<GridPoint, int>? fixedNumbers; // NEW: For number path puzzles (pre-filled cells)
  final GridPoint? startNode; // NEW: Dynamic Start Node coordinate
  final int startValue; // NEW: Value of the start node

  // NEW: For Operation Island
  final int? targetValue;
  final GridPoint? targetNode;
  final Map<GridPoint, OperationCell>? operations;

  const GameLevel({
    required this.id,
    required this.rows,
    required this.cols,
    this.timeLimit = 60,
    this.gameType = GameType.colorDots, // Default to original type
    required this.dotPositions,
    this.fixedNumbers,
    this.startNode,
    this.startValue = 1,
    this.targetValue,
    this.targetNode,
    this.operations,
  });

  /// Serializes this level to a JSON-safe map (only primitives/lists/maps) so it
  /// can be persisted to an asset or sent across an isolate boundary.
  Map<String, dynamic> toJson() => {
        'id': id,
        'rows': rows,
        'cols': cols,
        'timeLimit': timeLimit,
        'gameType': gameType.name,
        'dotPositions': dotPositions.map((color, pts) => MapEntry(
              color.name,
              pts.map((p) => [p.row, p.col]).toList(),
            )),
        if (fixedNumbers != null)
          'fixedNumbers': fixedNumbers!.entries
              .map((e) => {'r': e.key.row, 'c': e.key.col, 'v': e.value})
              .toList(),
        if (startNode != null) 'startNode': [startNode!.row, startNode!.col],
        'startValue': startValue,
        if (targetValue != null) 'targetValue': targetValue,
        if (targetNode != null) 'targetNode': [targetNode!.row, targetNode!.col],
        if (operations != null)
          'operations': operations!.entries
              .map((e) => {
                    'r': e.key.row,
                    'c': e.key.col,
                    'type': e.value.type.name,
                    'operand': e.value.operand,
                  })
              .toList(),
      };

  /// Rebuilds a level from [toJson] output.
  factory GameLevel.fromJson(Map<String, dynamic> j) {
    GridPoint? point(dynamic v) =>
        v == null ? null : GridPoint((v[0] as num).toInt(), (v[1] as num).toInt());

    final dots = <DotColor, List<GridPoint>>{};
    (j['dotPositions'] as Map?)?.forEach((key, value) {
      dots[DotColor.values.byName(key as String)] = (value as List)
          .map((e) => GridPoint((e[0] as num).toInt(), (e[1] as num).toInt()))
          .toList();
    });

    Map<GridPoint, int>? fixed;
    if (j['fixedNumbers'] != null) {
      fixed = {};
      for (final e in (j['fixedNumbers'] as List)) {
        fixed[GridPoint((e['r'] as num).toInt(), (e['c'] as num).toInt())] =
            (e['v'] as num).toInt();
      }
    }

    Map<GridPoint, OperationCell>? ops;
    if (j['operations'] != null) {
      ops = {};
      for (final e in (j['operations'] as List)) {
        ops[GridPoint((e['r'] as num).toInt(), (e['c'] as num).toInt())] =
            OperationCell(
          type: OperationType.values.byName(e['type'] as String),
          operand: (e['operand'] as num).toInt(),
        );
      }
    }

    return GameLevel(
      id: (j['id'] as num).toInt(),
      rows: (j['rows'] as num).toInt(),
      cols: (j['cols'] as num).toInt(),
      timeLimit: (j['timeLimit'] as num?)?.toInt() ?? 60,
      gameType: GameType.values.byName(j['gameType'] as String),
      dotPositions: dots,
      fixedNumbers: fixed,
      startNode: point(j['startNode']),
      startValue: (j['startValue'] as num?)?.toInt() ?? 1,
      targetValue: (j['targetValue'] as num?)?.toInt(),
      targetNode: point(j['targetNode']),
      operations: ops,
    );
  }

  /// Validates a mathematical operation path
  bool validateOperationPath(List<GridPoint> path) {
    if (gameType != GameType.operationPath) return false;
    if (path.isEmpty) return false;
    if (path.first != startNode) return false;
    if (path.last != targetNode) return false;
    if (path.length != rows * cols) return false;

    int current = startValue;
    for (int i = 1; i < path.length; i++) {
      final point = path[i];
      final op = operations?[point];
      if (op == null) return false;

      switch (op.type) {
        case OperationType.add:
          current += op.operand;
          break;
        case OperationType.subtract:
          current -= op.operand;
          break;
        case OperationType.multiply:
          current *= op.operand;
          break;
        case OperationType.divide:
          if (op.operand == 0) return false;
          if (current % op.operand != 0) return false; // Integer division only
          current ~/= op.operand;
          break;
      }
    }

    return current == targetValue;
  }
}

import 'package:flutter/foundation.dart';

import '../models/game_level_model.dart';

/// Runtime solver used to power the in-game hint for the numberPath and
/// operationPath islands. Solving runs on a background isolate (via [compute])
/// so the UI never blocks, and returns the full solution path as an ordered
/// list of [GridPoint]s (or null if no solution was found within the budget).
///
/// The level is passed in as serialized data so the background isolate never
/// needs to reach for assets or shared static state (which it cannot access).
class PuzzleSolver {
  /// Solves a numberPath level. Returns the ordered path from the start cell
  /// through every cell, or null on failure/timeout.
  static Future<List<GridPoint>?> solveNumberPath(
    GameLevel level, {
    int budgetMs = 5000,
  }) async {
    final raw = await compute(_solveNumberEntry, {
      'level': level.toJson(),
      'budgetMs': budgetMs,
    });
    return _toPoints(raw);
  }

  /// Solves an operationPath level. Returns the ordered path from start to
  /// target, or null on failure/timeout.
  static Future<List<GridPoint>?> solveOperationPath(
    GameLevel level, {
    int budgetMs = 5000,
  }) async {
    final raw = await compute(_solveOperationEntry, {
      'level': level.toJson(),
      'budgetMs': budgetMs,
    });
    return _toPoints(raw);
  }

  static List<GridPoint>? _toPoints(List<List<int>>? raw) {
    if (raw == null) return null;
    return raw.map((e) => GridPoint(e[0], e[1])).toList();
  }
}

// ---------------------------------------------------------------------------
// Isolate entry points (top-level so they can be passed to compute).
// ---------------------------------------------------------------------------

List<List<int>>? _solveNumberEntry(Map<String, dynamic> args) {
  final level = GameLevel.fromJson(Map<String, dynamic>.from(args['level'] as Map));
  return _solveNumber(level, args['budgetMs'] as int);
}

List<List<int>>? _solveOperationEntry(Map<String, dynamic> args) {
  final level = GameLevel.fromJson(Map<String, dynamic>.from(args['level'] as Map));
  return _solveOperation(level, args['budgetMs'] as int);
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

const List<List<int>> _dirs = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1],
];

class _Budget {
  final Stopwatch sw = Stopwatch()..start();
  final int millis;
  _Budget(this.millis);
  bool get expired => sw.elapsedMilliseconds > millis;
}

class _TimeoutSignal implements Exception {}

// ---------------------------------------------------------------------------
// numberPath solver (constrained Hamiltonian path through increasing clues)
// ---------------------------------------------------------------------------
List<List<int>>? _solveNumber(GameLevel level, int budgetMs) {
  final int rows = level.rows;
  final int cols = level.cols;
  final int total = rows * cols;
  int idx(int r, int c) => r * cols + c;
  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  final int startVal = level.startNode != null ? level.startValue : 1;

  final fixed = <int, int>{};
  final valueToCell = <int, int>{};
  level.fixedNumbers?.forEach((p, v) {
    final cell = idx(p.row, p.col);
    fixed[cell] = v;
    valueToCell[v] = cell;
  });

  int startCell;
  if (level.startNode != null) {
    startCell = idx(level.startNode!.row, level.startNode!.col);
  } else if (valueToCell.containsKey(startVal)) {
    startCell = valueToCell[startVal]!;
  } else {
    return null;
  }
  if (fixed.containsKey(startCell) && fixed[startCell] != startVal) {
    return null;
  }

  final visited = List<bool>.filled(total, false);
  final path = <int>[];
  final budget = _Budget(budgetMs);

  bool remainingConnected(int visitedCount) {
    if (visitedCount == total) return true;
    int firstUnvisited = -1;
    for (int i = 0; i < total; i++) {
      if (!visited[i]) {
        firstUnvisited = i;
        break;
      }
    }
    if (firstUnvisited == -1) return true;
    final seen = List<bool>.filled(total, false);
    final stack = <int>[firstUnvisited];
    seen[firstUnvisited] = true;
    int count = 1;
    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      final r = cur ~/ cols, c = cur % cols;
      for (final d in _dirs) {
        final nr = r + d[0], nc = c + d[1];
        if (!inBounds(nr, nc)) continue;
        final n = idx(nr, nc);
        if (seen[n] || visited[n]) continue;
        seen[n] = true;
        count++;
        stack.add(n);
      }
    }
    return count == (total - visitedCount);
  }

  int unvisitedDegree(int cell) {
    int deg = 0;
    final r = cell ~/ cols, c = cell % cols;
    for (final d in _dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (!inBounds(nr, nc)) continue;
      if (!visited[idx(nr, nc)]) deg++;
    }
    return deg;
  }

  bool dfs(int step, int cur) {
    if (budget.expired) throw _TimeoutSignal();
    if (step == total) return true;
    final int nextValue = startVal + step;
    final r = cur ~/ cols, c = cur % cols;

    final cands = <int>[];
    if (valueToCell.containsKey(nextValue)) {
      final forced = valueToCell[nextValue]!;
      final fr = forced ~/ cols, fc = forced % cols;
      if ((fr - r).abs() + (fc - c).abs() == 1 && !visited[forced]) {
        cands.add(forced);
      }
    } else {
      for (final d in _dirs) {
        final nr = r + d[0], nc = c + d[1];
        if (!inBounds(nr, nc)) continue;
        final n = idx(nr, nc);
        if (visited[n]) continue;
        if (fixed.containsKey(n)) continue;
        cands.add(n);
      }
      cands.sort((a, b) => unvisitedDegree(a).compareTo(unvisitedDegree(b)));
    }

    for (final n in cands) {
      visited[n] = true;
      path.add(n);
      if (remainingConnected(step + 1) && dfs(step + 1, n)) {
        return true;
      }
      path.removeLast();
      visited[n] = false;
    }
    return false;
  }

  visited[startCell] = true;
  path.add(startCell);
  try {
    if (dfs(1, startCell)) {
      return path.map((cell) => [cell ~/ cols, cell % cols]).toList();
    }
    return null;
  } on _TimeoutSignal {
    return null;
  }
}

// ---------------------------------------------------------------------------
// operationPath solver (Hamiltonian path start->target reaching targetValue)
// ---------------------------------------------------------------------------
List<List<int>>? _solveOperation(GameLevel level, int budgetMs) {
  final int rows = level.rows;
  final int cols = level.cols;
  final int total = rows * cols;
  int idx(int r, int c) => r * cols + c;
  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  if (level.startNode == null ||
      level.targetNode == null ||
      level.targetValue == null ||
      level.operations == null) {
    return null;
  }

  final start = idx(level.startNode!.row, level.startNode!.col);
  final target = idx(level.targetNode!.row, level.targetNode!.col);
  final ops = <int, OperationCell>{};
  level.operations!.forEach((p, op) => ops[idx(p.row, p.col)] = op);

  final visited = List<bool>.filled(total, false);
  final path = <int>[];
  final budget = _Budget(budgetMs);

  bool remainingConnected(int visitedCount) {
    if (visitedCount == total) return true;
    int firstUnvisited = -1;
    for (int i = 0; i < total; i++) {
      if (!visited[i]) {
        firstUnvisited = i;
        break;
      }
    }
    if (firstUnvisited == -1) return true;
    final seen = List<bool>.filled(total, false);
    final stack = <int>[firstUnvisited];
    seen[firstUnvisited] = true;
    int count = 1;
    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      final r = cur ~/ cols, c = cur % cols;
      for (final d in _dirs) {
        final nr = r + d[0], nc = c + d[1];
        if (!inBounds(nr, nc)) continue;
        final n = idx(nr, nc);
        if (seen[n] || visited[n]) continue;
        seen[n] = true;
        count++;
        stack.add(n);
      }
    }
    return count == (total - visitedCount);
  }

  bool dfs(int cur, int value, int count) {
    if (budget.expired) throw _TimeoutSignal();
    if (count == total) {
      return cur == target && value == level.targetValue;
    }
    final r = cur ~/ cols, c = cur % cols;
    for (final d in _dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (!inBounds(nr, nc)) continue;
      final n = idx(nr, nc);
      if (visited[n]) continue;
      if (n == target && count != total - 1) continue;
      final op = ops[n];
      if (op == null) continue;
      int newValue = value;
      switch (op.type) {
        case OperationType.add:
          newValue += op.operand;
          break;
        case OperationType.subtract:
          newValue -= op.operand;
          break;
        case OperationType.multiply:
          newValue *= op.operand;
          break;
        case OperationType.divide:
          if (op.operand == 0 || value % op.operand != 0) continue;
          newValue = value ~/ op.operand;
          break;
      }
      visited[n] = true;
      path.add(n);
      if (remainingConnected(count + 1) && dfs(n, newValue, count + 1)) {
        return true;
      }
      path.removeLast();
      visited[n] = false;
    }
    return false;
  }

  visited[start] = true;
  path.add(start);
  try {
    if (dfs(start, level.startValue, 1)) {
      return path.map((cell) => [cell ~/ cols, cell % cols]).toList();
    }
    return null;
  } on _TimeoutSignal {
    return null;
  }
}

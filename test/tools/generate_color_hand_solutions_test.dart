// One-off generator, NOT a real test. It computes a full-board solution for
// every hand-authored Color Realm level (1-50, see
// LevelGenerator.generateColorLevel in lib/services/level_generator.dart) and
// writes the per-color cell paths to assets/levels/color_hand_solutions.json.
//
// Why this exists: the in-game hint used to pathfind live with a greedy BFS
// that could wall off other colors and make the level unsolvable (see
// game_screen.dart _revealHint). The fix reveals a real, baked solution
// instead. Levels 51-100 already get their solution for free at generation
// time (tool/generate_levels.dart, the Hamiltonian path they're cut from).
// Levels 1-50 have no such generation-time solution, so it's computed once
// here, offline, with a generous time budget — this never runs on a device.
//
// Run with:
//   flutter test test/tools/generate_color_hand_solutions_test.dart
//
// Re-run whenever a hand-authored level's dotPositions change.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dot_weaver_app/models/game_level_model.dart';
import 'package:dot_weaver_app/services/level_generator.dart';

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

/// Same backtracking solver as test/level_validation_test.dart's solveColor,
/// but returns the actual per-color cell paths instead of just pass/fail.
Map<DotColor, List<GridPoint>>? solveColorWithPaths(GameLevel level, int budgetMs) {
  final int rows = level.rows;
  final int cols = level.cols;
  final int total = rows * cols;
  int idx(int r, int c) => r * cols + c;
  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  final owner = List<int>.filled(total, -1);
  final endA = <int>[];
  final endB = <int>[];
  final paths = <List<int>>[];

  final colors = level.dotPositions.keys.toList();
  for (int i = 0; i < colors.length; i++) {
    final pts = level.dotPositions[colors[i]]!;
    if (pts.length != 2) return null;
    final a = idx(pts[0].row, pts[0].col);
    final b = idx(pts[1].row, pts[1].col);
    if (a == b) return null;
    if (owner[a] != -1 || owner[b] != -1) return null;
    owner[a] = i;
    owner[b] = i;
    endA.add(a);
    endB.add(b);
    paths.add([a]);
  }

  final budget = _Budget(budgetMs);
  final label = List<int>.filled(total, -1);
  final growable = List<bool>.filled(total, false);
  final floodStack = List<int>.filled(total, 0);
  final bufA = List<int>.filled(4, -1);
  final bufB = List<int>.filled(4, -1);

  bool adjacentCells(int x, int y) {
    final xr = x ~/ cols, xc = x % cols;
    final yr = y ~/ cols, yc = y % cols;
    return (xr - yr).abs() + (xc - yc).abs() == 1;
  }

  int adjLabels(int cell, List<int> buf) {
    int n = 0;
    final r = cell ~/ cols, c = cell % cols;
    for (final d in _dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (!inBounds(nr, nc)) continue;
      final m = idx(nr, nc);
      if (owner[m] == -1 && label[m] >= 0) {
        final lab = label[m];
        bool dup = false;
        for (int k = 0; k < n; k++) {
          if (buf[k] == lab) {
            dup = true;
            break;
          }
        }
        if (!dup) buf[n++] = lab;
      }
    }
    return n;
  }

  bool shareComponent(int x, int y) {
    if (adjacentCells(x, y)) return true;
    final na = adjLabels(x, bufA);
    if (na == 0) return false;
    final nb = adjLabels(y, bufB);
    for (int i = 0; i < nb; i++) {
      for (int j = 0; j < na; j++) {
        if (bufB[i] == bufA[j]) return true;
      }
    }
    return false;
  }

  bool prune(int curColor, int head, int target) {
    for (int i = 0; i < total; i++) {
      label[i] = -1;
    }
    int comps = 0;
    for (int i = 0; i < total; i++) {
      if (owner[i] != -1 || label[i] != -1) continue;
      label[i] = comps;
      int sp = 0;
      floodStack[sp++] = i;
      while (sp > 0) {
        final cur = floodStack[--sp];
        final r = cur ~/ cols, c = cur % cols;
        for (final d in _dirs) {
          final nr = r + d[0], nc = c + d[1];
          if (!inBounds(nr, nc)) continue;
          final m = idx(nr, nc);
          if (owner[m] == -1 && label[m] == -1) {
            label[m] = comps;
            floodStack[sp++] = m;
          }
        }
      }
      comps++;
    }

    if (!shareComponent(head, target)) return false;

    for (int i = 0; i < total; i++) {
      growable[i] = false;
    }
    growable[head] = true;
    for (int j = curColor + 1; j < colors.length; j++) {
      final a = endA[j], b = endB[j];
      if (!shareComponent(a, b)) return false;
      growable[a] = true;
      growable[b] = true;
    }

    for (int cell = 0; cell < total; cell++) {
      if (owner[cell] != -1) continue;
      final r = cell ~/ cols, c = cell % cols;
      bool ok = false;
      for (final d in _dirs) {
        final nr = r + d[0], nc = c + d[1];
        if (!inBounds(nr, nc)) continue;
        final n = idx(nr, nc);
        if (owner[n] == -1 || growable[n]) {
          ok = true;
          break;
        }
      }
      if (!ok) return false;
    }
    return true;
  }

  bool allFilled() => !owner.contains(-1);

  late final bool Function(int colorIdx) solveFrom;

  int emptyDegree(int cell) {
    int deg = 0;
    final r = cell ~/ cols, c = cell % cols;
    for (final d in _dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (!inBounds(nr, nc)) continue;
      if (owner[idx(nr, nc)] == -1) deg++;
    }
    return deg;
  }

  bool extend(int colorIdx, int cur, int target) {
    if (budget.expired) throw _TimeoutSignal();
    if (cur == target) {
      return solveFrom(colorIdx + 1);
    }
    final r = cur ~/ cols, c = cur % cols;

    final cand = <int>[];
    bool targetAdjacent = false;
    for (final d in _dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (!inBounds(nr, nc)) continue;
      final n = idx(nr, nc);
      if (n == target) {
        targetAdjacent = true;
      } else if (owner[n] == -1) {
        cand.add(n);
      }
    }
    cand.sort((a, b) => emptyDegree(a).compareTo(emptyDegree(b)));

    for (final n in cand) {
      owner[n] = colorIdx;
      paths[colorIdx].add(n);
      if (prune(colorIdx, n, target) && extend(colorIdx, n, target)) {
        return true;
      }
      paths[colorIdx].removeLast();
      owner[n] = -1;
    }
    if (targetAdjacent) {
      // owner[target] is already colorIdx from the initial endpoint setup
      // and must stay that way unconditionally — it must NOT be cleared on
      // backtrack here, or a later candidate (for this or another color)
      // could walk straight through another color's claimed endpoint cell.
      paths[colorIdx].add(target);
      if (extend(colorIdx, target, target)) return true;
      paths[colorIdx].removeLast();
    }
    return false;
  }

  solveFrom = (int colorIdx) {
    if (budget.expired) throw _TimeoutSignal();
    if (colorIdx == colors.length) return allFilled();
    return extend(colorIdx, endA[colorIdx], endB[colorIdx]);
  };

  try {
    if (!solveFrom(0)) return null;
  } on _TimeoutSignal {
    return null;
  }

  final result = <DotColor, List<GridPoint>>{};
  for (int i = 0; i < colors.length; i++) {
    result[colors[i]] = paths[i].map((cell) => GridPoint(cell ~/ cols, cell % cols)).toList();
  }
  return result;
}

void main() {
  test('generate color_hand_solutions.json for levels 1-50', () {
    final out = <String, dynamic>{};
    final failures = <int>[];

    for (int levelId = 1; levelId <= 50; levelId++) {
      final level = LevelGenerator.generateColorLevel(levelId);
      final sw = Stopwatch()..start();
      final solution = solveColorWithPaths(level, 90000);
      // ignore: avoid_print
      print('Level $levelId (${level.rows}x${level.cols}): '
          '${solution == null ? 'FAILED' : 'solved'} in ${sw.elapsedMilliseconds}ms');
      if (solution == null) {
        failures.add(levelId);
        continue;
      }
      out[levelId.toString()] = solution.map((color, pts) => MapEntry(
            color.name,
            pts.map((p) => [p.row, p.col]).toList(),
          ));
    }

    final file = File('assets/levels/color_hand_solutions.json');
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(out));
    // ignore: avoid_print
    print('Wrote ${out.length} solutions -> ${file.path}');

    expect(failures, isEmpty,
        reason: 'Could not compute a solution for levels: $failures');
  }, timeout: const Timeout(Duration(minutes: 20)));
}

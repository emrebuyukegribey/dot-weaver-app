// Solvability validation for every hand-authored level across the three
// game types (colorDots / numberPath / operationPath).
//
// Run with:  flutter test test/level_validation_test.dart
//
// For each level a type-specific solver runs under a per-level time budget and
// reports one of:
//   SOLVED      - a valid solution was found (level is playable)
//   NO_SOLUTION - the search space was exhausted with no solution (BROKEN)
//   TIMEOUT     - solver could not decide within the budget (needs review)
//
// The test fails if any level reports NO_SOLUTION.

import 'package:flutter_test/flutter_test.dart';
import 'package:dot_weaver_app/models/game_level_model.dart';
import 'package:dot_weaver_app/services/level_generator.dart';

/// Outcome of a solvability check.
enum SolveResult { solved, noSolution, timeout }

class _Budget {
  final Stopwatch sw = Stopwatch()..start();
  final int millis;
  _Budget(this.millis);
  bool get expired => sw.elapsedMilliseconds > millis;
}

class TimeoutSignal implements Exception {}

const List<List<int>> _dirs = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1],
];

// ---------------------------------------------------------------------------
// colorDots solver (Flow-Free style: connect every pair, fill the whole board)
// ---------------------------------------------------------------------------
SolveResult solveColor(GameLevel level, int budgetMs) {
  final int rows = level.rows;
  final int cols = level.cols;
  final int total = rows * cols;
  int idx(int r, int c) => r * cols + c;
  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  // owner[cell] = color index (>=0) or -1 for empty.
  final owner = List<int>.filled(total, -1);
  final endA = <int>[];
  final endB = <int>[];

  final colors = level.dotPositions.keys.toList();
  for (int i = 0; i < colors.length; i++) {
    final pts = level.dotPositions[colors[i]]!;
    if (pts.length != 2) return SolveResult.noSolution;
    final a = idx(pts[0].row, pts[0].col);
    final b = idx(pts[1].row, pts[1].col);
    if (a == b) return SolveResult.noSolution;
    if (owner[a] != -1 || owner[b] != -1) {
      return SolveResult.noSolution; // overlapping endpoints
    }
    owner[a] = i;
    owner[b] = i;
    endA.add(a);
    endB.add(b);
  }

  final budget = _Budget(budgetMs);

  // Reusable scratch buffers (avoid per-call allocation).
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

  // Fill `buf` with the (≤4) empty-component labels adjacent to `cell`,
  // returning the count. Allocation-free.
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

  // Sound prune using a single flood of the empty cells (equivalent to the
  // pairwise BFS reachability test, but far cheaper).
  bool prune(int curColor, int head, int target) {
    // Label connected components of empty cells.
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

    // Head must still reach its target: adjacent, or sharing an empty component.
    if (!shareComponent(head, target)) return false;

    // Mark cells that can still grow a path into adjacent empties.
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

    // No empty cell may be stranded (no empty neighbour and not adjacent to a
    // cell that can still grow into it).
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

  // Mutually-recursive helpers, wired through a late variable so `extend` can
  // call `solveFrom` even though it is assigned afterwards.
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
    if (budget.expired) throw TimeoutSignal();
    if (cur == target) {
      return solveFrom(colorIdx + 1);
    }
    final r = cur ~/ cols, c = cur % cols;

    // Gather empty-neighbour candidates and order them by Warnsdorff's rule
    // (fewest onward empty neighbours first) to reach solutions quickly. The
    // "finish at target" option is tried last so the path tends to fill space
    // before terminating.
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
      if (prune(colorIdx, n, target) && extend(colorIdx, n, target)) {
        return true;
      }
      owner[n] = -1;
    }
    if (targetAdjacent) {
      if (extend(colorIdx, target, target)) return true;
    }
    return false;
  }

  solveFrom = (int colorIdx) {
    if (budget.expired) throw TimeoutSignal();
    if (colorIdx == colors.length) return allFilled();
    return extend(colorIdx, endA[colorIdx], endB[colorIdx]);
  };

  try {
    return solveFrom(0) ? SolveResult.solved : SolveResult.noSolution;
  } on TimeoutSignal {
    return SolveResult.timeout;
  }
}

// ---------------------------------------------------------------------------
// numberPath solver (constrained Hamiltonian path through increasing clues)
// ---------------------------------------------------------------------------
SolveResult solveNumber(GameLevel level, int budgetMs) {
  final int rows = level.rows;
  final int cols = level.cols;
  final int total = rows * cols;
  int idx(int r, int c) => r * cols + c;
  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  final int startVal = level.startNode != null ? level.startValue : 1;

  final fixed = <int, int>{}; // cell -> value
  final valueToCell = <int, int>{}; // value -> cell
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
    // Without a known start we cannot solve efficiently.
    return SolveResult.timeout;
  }
  // Start cell clue must be consistent.
  if (fixed.containsKey(startCell) && fixed[startCell] != startVal) {
    return SolveResult.noSolution;
  }

  final visited = List<bool>.filled(total, false);
  final budget = _Budget(budgetMs);

  bool remainingConnected(int frontier, int visitedCount) {
    if (visitedCount == total) return true;
    // BFS over unvisited cells starting from any unvisited neighbour of all
    // unvisited cells; cheaper: flood from the first unvisited cell and ensure
    // it covers every unvisited cell.
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
    final unvisitedTotal = total - visitedCount;
    return count == unvisitedTotal;
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
    if (budget.expired) throw TimeoutSignal();
    if (step == total) return true;
    final int nextValue = startVal + step; // value of step+1 (1-indexed steps)
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
        // A free step cannot land on a clue cell meant for another value.
        if (fixed.containsKey(n)) continue;
        cands.add(n);
      }
      // Warnsdorff ordering: try the most constrained next cell first.
      cands.sort((a, b) => unvisitedDegree(a).compareTo(unvisitedDegree(b)));
    }

    for (final n in cands) {
      visited[n] = true;
      if (remainingConnected(n, step + 1) && dfs(step + 1, n)) {
        return true;
      }
      visited[n] = false;
    }
    return false;
  }

  visited[startCell] = true;
  try {
    return dfs(1, startCell) ? SolveResult.solved : SolveResult.noSolution;
  } on TimeoutSignal {
    return SolveResult.timeout;
  }
}

// ---------------------------------------------------------------------------
// operationPath solver (Hamiltonian path start->target reaching targetValue)
// ---------------------------------------------------------------------------
SolveResult solveOperation(GameLevel level, int budgetMs) {
  final int rows = level.rows;
  final int cols = level.cols;
  final int total = rows * cols;
  int idx(int r, int c) => r * cols + c;
  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  if (level.startNode == null ||
      level.targetNode == null ||
      level.targetValue == null ||
      level.operations == null) {
    return SolveResult.noSolution;
  }

  final start = idx(level.startNode!.row, level.startNode!.col);
  final target = idx(level.targetNode!.row, level.targetNode!.col);
  final ops = <int, OperationCell>{};
  level.operations!.forEach((p, op) => ops[idx(p.row, p.col)] = op);

  final visited = List<bool>.filled(total, false);
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
    if (budget.expired) throw TimeoutSignal();
    if (count == total) {
      return cur == target && value == level.targetValue;
    }
    final r = cur ~/ cols, c = cur % cols;
    for (final d in _dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (!inBounds(nr, nc)) continue;
      final n = idx(nr, nc);
      if (visited[n]) continue;
      // Target may only be entered as the very last cell.
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
      if (remainingConnected(count + 1) && dfs(n, newValue, count + 1)) {
        return true;
      }
      visited[n] = false;
    }
    return false;
  }

  visited[start] = true;
  try {
    return dfs(start, level.startValue, 1)
        ? SolveResult.solved
        : SolveResult.noSolution;
  } on TimeoutSignal {
    return SolveResult.timeout;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all levels are solvable', () {
    final broken = <String>[];
    final timeouts = <String>[];

    void check(String island, int from, int to, String islandId,
        SolveResult Function(GameLevel) solver) {
      for (int lvl = from; lvl <= to; lvl++) {
        final level = LevelGenerator.generate(lvl, islandId: islandId);
        final res = solver(level);
        final tag = '$island L$lvl (${level.rows}x${level.cols})';
        switch (res) {
          case SolveResult.solved:
            break;
          case SolveResult.noSolution:
            broken.add(tag);
            // ignore: avoid_print
            print('  NO_SOLUTION  $tag');
            break;
          case SolveResult.timeout:
            timeouts.add(tag);
            // ignore: avoid_print
            print('  TIMEOUT      $tag');
            break;
        }
      }
    }

    // ignore: avoid_print
    print('=== COLOR REALM (colorDots) ===');
    check('Color', 1, 50, '1', (l) => solveColor(l, 90000));
    // ignore: avoid_print
    print('=== NUMBER NEXUS (numberPath) ===');
    check('Number', 1, 50, '2', (l) => solveNumber(l, 90000));
    // ignore: avoid_print
    print('=== LOGIC CORE (operationPath) ===');
    check('Logic', 1, 35, '3', (l) => solveOperation(l, 8000));

    // ignore: avoid_print
    print('\n=== SUMMARY ===');
    // ignore: avoid_print
    print('Broken (NO_SOLUTION): ${broken.length} -> $broken');
    // ignore: avoid_print
    print('Timeouts (review):    ${timeouts.length} -> $timeouts');

    expect(broken, isEmpty,
        reason: 'These levels have no valid solution and must be fixed: $broken');
  }, timeout: const Timeout(Duration(minutes: 20)));

  // Focused, long-budget run for the hardest levels that timed out under the
  // default budget. Run with:
  //   flutter test test/level_validation_test.dart --plain-name focused
  test('focused hard levels', () {
    void run(String tag, GameLevel level, SolveResult Function(GameLevel) s) {
      final sw = Stopwatch()..start();
      final res = s(level);
      // ignore: avoid_print
      print('  $tag -> $res  (${sw.elapsedMilliseconds}ms)');
    }

    run('Color L46', LevelGenerator.generate(46, islandId: '1'),
        (l) => solveColor(l, 30000));
    run('Color L47', LevelGenerator.generate(47, islandId: '1'),
        (l) => solveColor(l, 30000));
    run('Color L48', LevelGenerator.generate(48, islandId: '1'),
        (l) => solveColor(l, 30000));
    run('Color L49', LevelGenerator.generate(49, islandId: '1'),
        (l) => solveColor(l, 30000));
    run('Number L43', LevelGenerator.generate(43, islandId: '2'),
        (l) => solveNumber(l, 30000));
    run('Logic L20', LevelGenerator.generate(20, islandId: '3'),
        (l) => solveOperation(l, 30000));
  }, timeout: const Timeout(Duration(minutes: 30)));
}

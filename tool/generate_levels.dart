// Offline level generator (design-time tool, NOT part of the app runtime).
//
// Usage:
//   dart run tool/generate_levels.dart
//
// Generates procedurally-built, guaranteed-solvable levels and writes them to
// assets/levels/*.json. The app loads these at startup via LevelGenerator.init.
//
// This is pure Dart (no Flutter imports) so it runs with `dart run`. The JSON
// shape it emits must match GameLevel.fromJson in lib/models/game_level_model.dart.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main(List<String> args) {
  final outDir = Directory('assets/levels');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  _generateNumberPack(
    islandId: '2',
    fromLevel: 51,
    toLevel: 100,
    outPath: 'assets/levels/number.json',
  );

  _generateOperationPack(
    islandId: '3',
    fromLevel: 36,
    toLevel: 100,
    outPath: 'assets/levels/operation.json',
  );

  _generateColorPack(
    islandId: '1',
    fromLevel: 51,
    toLevel: 100,
    outPath: 'assets/levels/color.json',
  );

  stdout.writeln('Done.');
}

// ---------------------------------------------------------------------------
// Number Nexus (numberPath) pack
// ---------------------------------------------------------------------------

void _generateNumberPack({
  required String islandId,
  required int fromLevel,
  required int toLevel,
  required String outPath,
}) {
  final levels = <Map<String, dynamic>>[];

  for (int levelId = fromLevel; levelId <= toLevel; levelId++) {
    // Deterministic per (island, level) so re-runs reproduce the same packs.
    final rng = Random(_seed(islandId, levelId));
    final size = _numberGridSize(levelId);
    final level = _buildNumberLevel(levelId, size, rng);
    levels.add(level);
    stdout.writeln(
        'number L$levelId  ${size}x$size  clues=${(level['fixedNumbers'] as List).length}  time=${level['timeLimit']}s');
  }

  final payload = {
    'island': islandId,
    'type': 'numberPath',
    'generatedAt': DateTime.now().toIso8601String(),
    'levels': levels,
  };
  File(outPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  stdout.writeln('Wrote ${levels.length} levels -> $outPath');
}

/// Grid size for Number levels 51-100. Continues the expert tier from the
/// hand-made levels (46-50 are already 10x10) without dropping difficulty.
int _numberGridSize(int levelId) {
  if (levelId <= 75) return 9;
  return 10;
}

/// Fraction of cells that get a clue.
double _clueRatio(int levelId) {
  final t = ((levelId - 51) / (100 - 51)).clamp(0.0, 1.0);
  return 0.30 - (0.12 * t); // 51 -> ~0.30, 100 -> ~0.18
}

/// Time budget per cell in seconds (generous; shrinks slightly as levels rise).
double _numberSecPerCell(int levelId) {
  final t = ((levelId - 51) / (100 - 51)).clamp(0.0, 1.0);
  return 5.5 - (1.0 * t); // 51 -> 5.5s/cell, 100 -> 4.5s/cell
}

Map<String, dynamic> _buildNumberLevel(int levelId, int size, Random rng) {
  final total = size * size;

  // Try until we get a Hamiltonian path that the solver can confirm.
  for (int attempt = 0; attempt < 200; attempt++) {
    final path = _randomHamiltonian(size, size, rng);
    if (path == null) continue;

    // Clue indices along the path (values are index+1). Always anchor the
    // start (index 0) and the last cell, then spread the rest evenly.
    final clueCount = max(3, (total * _clueRatio(levelId)).round());
    final clueIdx = _spreadIndices(total, clueCount);

    final fixedNumbers = <Map<String, int>>[];
    for (final i in clueIdx) {
      final cell = path[i];
      fixedNumbers.add({'r': cell ~/ size, 'c': cell % size, 'v': i + 1});
    }

    final startCell = path[0];
    final level = {
      'id': levelId,
      'rows': size,
      'cols': size,
      'timeLimit': (total * _numberSecPerCell(levelId)).round(),
      'gameType': 'numberPath',
      'dotPositions': <String, dynamic>{},
      'fixedNumbers': fixedNumbers,
      'startNode': [startCell ~/ size, startCell % size],
      'startValue': 1,
    };

    // Validate solvability (defensive; should always pass since clues come
    // straight from a real path).
    if (_solveNumber(level, size, budgetMs: 8000) != null) {
      return level;
    }
  }

  throw StateError('Failed to generate solvable number level $levelId (${size}x$size)');
}

/// Picks [count] indices in [0, total) including 0 and total-1, spread evenly.
List<int> _spreadIndices(int total, int count) {
  if (count >= total) return List.generate(total, (i) => i);
  final set = <int>{0, total - 1};
  for (int k = 1; k < count - 1; k++) {
    set.add((k * (total - 1) / (count - 1)).round());
  }
  final list = set.toList()..sort();
  return list;
}

// ---------------------------------------------------------------------------
// Random Hamiltonian path (randomized DFS with Warnsdorff heuristic)
// ---------------------------------------------------------------------------

const List<List<int>> _dirs = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1],
];

List<int>? _randomHamiltonian(int rows, int cols, Random rng) {
  final total = rows * cols;
  bool inB(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;
  int idx(int r, int c) => r * cols + c;

  final visited = List<bool>.filled(total, false);
  final path = <int>[];
  final start = rng.nextInt(total);

  int degree(int cell) {
    final r = cell ~/ cols, c = cell % cols;
    int d = 0;
    for (final dir in _dirs) {
      final nr = r + dir[0], nc = c + dir[1];
      if (inB(nr, nc) && !visited[idx(nr, nc)]) d++;
    }
    return d;
  }

  final sw = Stopwatch()..start();
  bool dfs(int cell) {
    if (sw.elapsedMilliseconds > 2000) return false; // per-attempt budget
    visited[cell] = true;
    path.add(cell);
    if (path.length == total) return true;

    final r = cell ~/ cols, c = cell % cols;
    final neighbors = <int>[];
    for (final dir in _dirs) {
      final nr = r + dir[0], nc = c + dir[1];
      if (inB(nr, nc) && !visited[idx(nr, nc)]) neighbors.add(idx(nr, nc));
    }
    // Warnsdorff: prefer the most-constrained neighbor, with random tie-break.
    neighbors.shuffle(rng);
    neighbors.sort((a, b) => degree(a).compareTo(degree(b)));

    for (final n in neighbors) {
      if (dfs(n)) return true;
    }

    visited[cell] = false;
    path.removeLast();
    return false;
  }

  if (dfs(start)) return path;
  return null;
}

// ---------------------------------------------------------------------------
// Number solver (mirror of lib/services/puzzle_solver.dart, plain-data form)
// ---------------------------------------------------------------------------

List<int>? _solveNumber(Map<String, dynamic> level, int size, {int budgetMs = 8000}) {
  final rows = level['rows'] as int;
  final cols = level['cols'] as int;
  final total = rows * cols;
  int idx(int r, int c) => r * cols + c;
  bool inB(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  final startVal = level['startValue'] as int;
  final fixed = <int, int>{};
  final valueToCell = <int, int>{};
  for (final e in (level['fixedNumbers'] as List)) {
    final cell = idx(e['r'] as int, e['c'] as int);
    fixed[cell] = e['v'] as int;
    valueToCell[e['v'] as int] = cell;
  }

  final startNode = level['startNode'] as List;
  final startCell = idx(startNode[0] as int, startNode[1] as int);

  final visited = List<bool>.filled(total, false);
  final path = <int>[];
  final sw = Stopwatch()..start();

  bool remainingConnected(int visitedCount) {
    if (visitedCount == total) return true;
    int first = -1;
    for (int i = 0; i < total; i++) {
      if (!visited[i]) {
        first = i;
        break;
      }
    }
    if (first == -1) return true;
    final seen = List<bool>.filled(total, false);
    final stack = <int>[first];
    seen[first] = true;
    int count = 1;
    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      final r = cur ~/ cols, c = cur % cols;
      for (final d in _dirs) {
        final nr = r + d[0], nc = c + d[1];
        if (!inB(nr, nc)) continue;
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
    final r = cell ~/ cols, c = cell % cols;
    int d = 0;
    for (final dir in _dirs) {
      final nr = r + dir[0], nc = c + dir[1];
      if (inB(nr, nc) && !visited[idx(nr, nc)]) d++;
    }
    return d;
  }

  bool timedOut = false;
  bool dfs(int step, int cur) {
    if (sw.elapsedMilliseconds > budgetMs) {
      timedOut = true;
      return false;
    }
    if (step == total) return true;
    final nextValue = startVal + step;
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
        if (!inB(nr, nc)) continue;
        final n = idx(nr, nc);
        if (visited[n] || fixed.containsKey(n)) continue;
        cands.add(n);
      }
      cands.sort((a, b) => unvisitedDegree(a).compareTo(unvisitedDegree(b)));
    }

    for (final n in cands) {
      visited[n] = true;
      path.add(n);
      if (remainingConnected(step + 1) && dfs(step + 1, n)) return true;
      path.removeLast();
      visited[n] = false;
      if (timedOut) return false;
    }
    return false;
  }

  visited[startCell] = true;
  path.add(startCell);
  if (dfs(1, startCell)) return List<int>.from(path);
  return null;
}

// ---------------------------------------------------------------------------
// Logic Core (operationPath) pack
// ---------------------------------------------------------------------------

void _generateOperationPack({
  required String islandId,
  required int fromLevel,
  required int toLevel,
  required String outPath,
}) {
  final levels = <Map<String, dynamic>>[];
  for (int levelId = fromLevel; levelId <= toLevel; levelId++) {
    final rng = Random(_seed(islandId, levelId));
    final size = _operationGridSize(levelId);
    final level = _buildOperationLevel(levelId, size, rng);
    levels.add(level);
    stdout.writeln(
        'operation L$levelId  ${size}x$size  start=${level['startValue']} -> target=${level['targetValue']}  time=${level['timeLimit']}s');
  }
  final payload = {
    'island': islandId,
    'type': 'operationPath',
    'generatedAt': DateTime.now().toIso8601String(),
    'levels': levels,
  };
  File(outPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  stdout.writeln('Wrote ${levels.length} levels -> $outPath');
}

/// Operation grids stay at 5x5 (the hand-made tier already reached 5x5 by level
/// 35) so the exponential hint solver always finds a solution within its in-app
/// time budget. Difficulty rises via operation complexity instead of grid size.
int _operationGridSize(int levelId) => 5;

Map<String, dynamic> _buildOperationLevel(int levelId, int size, Random rng) {
  final total = size * size;
  // Higher levels lean more on multiply/divide and larger operands.
  final t = ((levelId - 36) / (100 - 36)).clamp(0.0, 1.0);
  final hardOpChance = 0.20 + 0.30 * t; // 0.20 -> 0.50
  final maxAddSub = 8 + (10 * t).round(); // 8 -> 18

  for (int attempt = 0; attempt < 400; attempt++) {
    final path = _randomHamiltonian(size, size, rng);
    if (path == null) continue;

    final startValue = 6 + rng.nextInt(25); // 6..30
    int value = startValue;
    final ops = <Map<String, dynamic>>[];
    bool ok = true;

    for (int i = 1; i < path.length; i++) {
      final cell = path[i];
      final r = cell ~/ size, c = cell % size;
      final choice = _pickOperation(value, rng, hardOpChance, maxAddSub);
      if (choice == null) {
        ok = false;
        break;
      }
      value = choice.resultValue;
      ops.add({'r': r, 'c': c, 'type': choice.type, 'operand': choice.operand});
    }
    if (!ok) continue;

    final startCell = path.first;
    final targetCell = path.last;
    final level = {
      'id': levelId,
      'rows': size,
      'cols': size,
      'timeLimit': (total * (13 - 3 * t)).round(), // ~ generous, shrinks a bit
      'gameType': 'operationPath',
      'dotPositions': {
        'green': [
          [startCell ~/ size, startCell % size],
          [targetCell ~/ size, targetCell % size],
        ],
      },
      'startNode': [startCell ~/ size, startCell % size],
      'startValue': startValue,
      'targetNode': [targetCell ~/ size, targetCell % size],
      'targetValue': value,
      'operations': ops,
    };

    // Must be solvable within a margin under the in-app hint budget (5000ms)
    // so the hint is guaranteed to work for the player.
    if (_solveOperation(level, budgetMs: 3500) != null) {
      return level;
    }
  }
  throw StateError('Failed to generate solvable operation level $levelId (${size}x$size)');
}

class _OpChoice {
  final String type;
  final int operand;
  final int resultValue;
  _OpChoice(this.type, this.operand, this.resultValue);
}

/// Picks an operation for the current running [value], keeping the value within
/// a sane positive band so puzzles read cleanly and never overflow.
_OpChoice? _pickOperation(int value, Random rng, double hardChance, int maxAddSub) {
  final hard = rng.nextDouble() < hardChance;

  if (hard) {
    // Prefer multiply/divide when it keeps the value reasonable.
    final wantDivide = rng.nextBool();
    if (wantDivide) {
      final divisors = <int>[];
      for (final d in [2, 3, 4, 5]) {
        if (value % d == 0 && value ~/ d >= 1) divisors.add(d);
      }
      if (divisors.isNotEmpty) {
        final d = divisors[rng.nextInt(divisors.length)];
        return _OpChoice('divide', d, value ~/ d);
      }
    }
    if (value <= 40) {
      final m = 2 + rng.nextInt(2); // 2..3
      if (value * m <= 180) return _OpChoice('multiply', m, value * m);
    }
  }

  // Fall back to add / subtract keeping value in [1, 199].
  final addFirst = rng.nextBool();
  for (final addMode in addFirst ? [true, false] : [false, true]) {
    if (addMode) {
      final op = 1 + rng.nextInt(maxAddSub);
      if (value + op <= 199) return _OpChoice('add', op, value + op);
    } else {
      final op = 1 + rng.nextInt(maxAddSub);
      if (value - op >= 1) return _OpChoice('subtract', op, value - op);
    }
  }
  return null;
}

List<int>? _solveOperation(Map<String, dynamic> level, {int budgetMs = 3500}) {
  final rows = level['rows'] as int;
  final cols = level['cols'] as int;
  final total = rows * cols;
  int idx(int r, int c) => r * cols + c;
  bool inB(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  final startNode = level['startNode'] as List;
  final targetNode = level['targetNode'] as List;
  final start = idx(startNode[0] as int, startNode[1] as int);
  final target = idx(targetNode[0] as int, targetNode[1] as int);
  final targetValue = level['targetValue'] as int;
  final startValue = level['startValue'] as int;

  final ops = <int, List<dynamic>>{}; // cell -> [type, operand]
  for (final e in (level['operations'] as List)) {
    ops[idx(e['r'] as int, e['c'] as int)] = [e['type'], e['operand']];
  }

  final visited = List<bool>.filled(total, false);
  final sw = Stopwatch()..start();
  bool timedOut = false;

  bool remainingConnected(int visitedCount) {
    if (visitedCount == total) return true;
    int first = -1;
    for (int i = 0; i < total; i++) {
      if (!visited[i]) {
        first = i;
        break;
      }
    }
    if (first == -1) return true;
    final seen = List<bool>.filled(total, false);
    final stack = <int>[first];
    seen[first] = true;
    int count = 1;
    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      final r = cur ~/ cols, c = cur % cols;
      for (final d in _dirs) {
        final nr = r + d[0], nc = c + d[1];
        if (!inB(nr, nc)) continue;
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
    if (sw.elapsedMilliseconds > budgetMs) {
      timedOut = true;
      return false;
    }
    if (count == total) return cur == target && value == targetValue;
    final r = cur ~/ cols, c = cur % cols;
    for (final d in _dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (!inB(nr, nc)) continue;
      final n = idx(nr, nc);
      if (visited[n]) continue;
      if (n == target && count != total - 1) continue;
      final op = ops[n];
      if (op == null) continue;
      int newValue = value;
      switch (op[0] as String) {
        case 'add':
          newValue += op[1] as int;
          break;
        case 'subtract':
          newValue -= op[1] as int;
          break;
        case 'multiply':
          newValue *= op[1] as int;
          break;
        case 'divide':
          final d2 = op[1] as int;
          if (d2 == 0 || value % d2 != 0) continue;
          newValue = value ~/ d2;
          break;
      }
      visited[n] = true;
      if (remainingConnected(count + 1) && dfs(n, newValue, count + 1)) return true;
      visited[n] = false;
      if (timedOut) return false;
    }
    return false;
  }

  visited[start] = true;
  if (dfs(start, startValue, 1)) return [start];
  return null;
}

// ---------------------------------------------------------------------------
// Color Realm (colorDots / flow) pack
// ---------------------------------------------------------------------------

const List<String> _palette = [
  'red', 'blue', 'green', 'yellow', 'purple', 'orange',
  'pink', 'teal', 'amber', 'indigo', 'cyan', 'white',
];

void _generateColorPack({
  required String islandId,
  required int fromLevel,
  required int toLevel,
  required String outPath,
}) {
  final levels = <Map<String, dynamic>>[];
  for (int levelId = fromLevel; levelId <= toLevel; levelId++) {
    final rng = Random(_seed(islandId, levelId));
    final size = _colorGridSize(levelId);
    final level = _buildColorLevel(levelId, size, rng);
    levels.add(level);
    stdout.writeln(
        'color L$levelId  ${size}x$size  colors=${(level['dotPositions'] as Map).length}  time=${level['timeLimit']}s');
  }
  final payload = {
    'island': islandId,
    'type': 'colorDots',
    'generatedAt': DateTime.now().toIso8601String(),
    'levels': levels,
  };
  File(outPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  stdout.writeln('Wrote ${levels.length} levels -> $outPath');
}

/// Color grids continue the expert tier (hand-made 46-50 are already 9x9).
int _colorGridSize(int levelId) {
  if (levelId <= 75) return 9;
  return 10;
}

/// Number of colors (flow pairs). More colors -> shorter paths.
int _colorCount(int levelId, int size) {
  final t = ((levelId - 51) / (100 - 51)).clamp(0.0, 1.0);
  // Fewer colors at higher levels => longer, harder paths. Keep >= 4.
  final k = (size + 1) - (t * 2).round();
  return k.clamp(4, _palette.length);
}

Map<String, dynamic> _buildColorLevel(int levelId, int size, Random rng) {
  final total = size * size;
  final k = min(_colorCount(levelId, size), total ~/ 2);

  for (int attempt = 0; attempt < 200; attempt++) {
    final path = _randomHamiltonian(size, size, rng);
    if (path == null) continue;

    // Cut the Hamiltonian path into k contiguous segments, each >= 2 cells.
    // The endpoints of every segment become a color's two dots. This is a full,
    // non-overlapping tiling => guaranteed solvable.
    final cuts = _segmentLengths(total, k, rng);
    if (cuts == null) continue;

    final dotPositions = <String, dynamic>{};
    // Every color's full cell-by-cell path, in order from one endpoint to the
    // other. Together these are exactly the Hamiltonian `path` cut into
    // pieces, so they tile the whole grid by construction. Stored as the
    // level's baked solution so the in-game hint can reveal a real segment
    // instead of pathfinding live (see GameLevel.solutionPaths).
    final solutionPaths = <String, dynamic>{};
    int start = 0;
    bool ok = true;
    for (int s = 0; s < cuts.length; s++) {
      final len = cuts[s];
      final a = path[start];
      final b = path[start + len - 1];
      if (a == b) {
        ok = false;
        break;
      }
      dotPositions[_palette[s]] = [
        [a ~/ size, a % size],
        [b ~/ size, b % size],
      ];
      solutionPaths[_palette[s]] = [
        for (int i = start; i < start + len; i++) [path[i] ~/ size, path[i] % size],
      ];
      start += len;
    }
    if (!ok) continue;

    final t = ((levelId - 51) / (100 - 51)).clamp(0.0, 1.0);
    return {
      'id': levelId,
      'rows': size,
      'cols': size,
      'timeLimit': (total * (2.6 - 0.8 * t)).round(),
      'gameType': 'colorDots',
      'dotPositions': dotPositions,
      'solutionPaths': solutionPaths,
      'startValue': 1,
    };
  }
  throw StateError('Failed to generate color level $levelId (${size}x$size)');
}

/// Splits [total] into [k] segment lengths, each >= 2, summing to total.
List<int>? _segmentLengths(int total, int k, Random rng) {
  if (k * 2 > total) return null;
  final lengths = List<int>.filled(k, 2);
  int remaining = total - 2 * k;
  while (remaining > 0) {
    lengths[rng.nextInt(k)]++;
    remaining--;
  }
  return lengths;
}

// ---------------------------------------------------------------------------
// Misc
// ---------------------------------------------------------------------------

int _seed(String islandId, int levelId) {
  // Stable seed derived from island + level.
  return islandId.codeUnits.fold(0, (a, b) => a * 31 + b) * 1000 + levelId;
}

// Patches assets/levels/color.json by adding the `solutionPaths` field to
// levels that are missing it, using the exact same deterministic seed +
// Hamiltonian-path algorithm that was used to generate them originally.
//
// This only inserts solutionPaths — it never touches dotPositions, timeLimit,
// or any other field already in the file. As a safety guard, if a level's
// regenerated dotPositions differ from what's committed (code drift since
// original generation), it logs an error and skips that level rather than
// corrupting it.
//
// Usage:
//   dart run tool/patch_color_solutions.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';

const List<List<int>> _dirs = [
  [-1, 0], [1, 0], [0, -1], [0, 1],
];

const List<String> _palette = [
  'red', 'blue', 'green', 'yellow', 'purple', 'orange',
  'pink', 'teal', 'amber', 'indigo', 'cyan', 'white',
];

int _seed(String islandId, int levelId) =>
    islandId.codeUnits.fold(0, (a, b) => a * 31 + b) * 1000 + levelId;

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
    if (sw.elapsedMilliseconds > 2000) return false;
    visited[cell] = true;
    path.add(cell);
    if (path.length == total) return true;
    final r = cell ~/ cols, c = cell % cols;
    final neighbors = <int>[];
    for (final dir in _dirs) {
      final nr = r + dir[0], nc = c + dir[1];
      if (inB(nr, nc) && !visited[idx(nr, nc)]) neighbors.add(idx(nr, nc));
    }
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

List<int>? _segmentLengths(int total, int k, Random rng) {
  if (k * 2 > total) return null;
  final lengths = List<int>.filled(k, 2);
  int remaining = total - 2 * k;
  while (remaining > 0) {
    lengths[rng.nextInt(k)]++; remaining--;
  }
  return lengths;
}

int _colorGridSize(int levelId) => levelId <= 75 ? 9 : 10;

int _colorCount(int levelId, int size) {
  final t = ((levelId - 51) / (100 - 51)).clamp(0.0, 1.0);
  return ((size + 1) - (t * 2).round()).clamp(4, _palette.length);
}

/// Re-derives the original level using the same seed, returning both
/// dotPositions and solutionPaths (or null if the Hamiltonian search fails
/// within its attempt budget).
Map<String, dynamic>? _rederiveLevel(int levelId) {
  final size = _colorGridSize(levelId);
  final total = size * size;
  final k = min(_colorCount(levelId, size), total ~/ 2);
  final rng = Random(_seed('1', levelId));

  for (int attempt = 0; attempt < 200; attempt++) {
    final path = _randomHamiltonian(size, size, rng);
    if (path == null) continue;
    final cuts = _segmentLengths(total, k, rng);
    if (cuts == null) continue;

    final dotPositions = <String, dynamic>{};
    final solutionPaths = <String, dynamic>{};
    int start = 0;
    bool ok = true;
    for (int s = 0; s < cuts.length; s++) {
      final len = cuts[s];
      final a = path[start], b = path[start + len - 1];
      if (a == b) { ok = false; break; }
      dotPositions[_palette[s]] = [[a ~/ size, a % size], [b ~/ size, b % size]];
      solutionPaths[_palette[s]] = [
        for (int i = start; i < start + len; i++) [path[i] ~/ size, path[i] % size],
      ];
      start += len;
    }
    if (!ok) continue;
    return {'dotPositions': dotPositions, 'solutionPaths': solutionPaths};
  }
  return null;
}

bool _dotPositionsMatch(dynamic committed, dynamic rederived) {
  if (committed is! Map || rederived is! Map) return false;
  if (committed.length != rederived.length) return false;
  for (final color in (committed as Map).keys) {
    final c = committed[color] as List?;
    final r = (rederived as Map)[color] as List?;
    if (c == null || r == null || c.length != r.length) return false;
    for (int i = 0; i < c.length; i++) {
      if ((c[i] as List)[0] != (r[i] as List)[0] ||
          (c[i] as List)[1] != (r[i] as List)[1]) return false;
    }
  }
  return true;
}

void main() {
  final file = File('assets/levels/color.json');
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final levels = decoded['levels'] as List;

  int patched = 0, skipped = 0, drifted = 0;

  for (final item in levels) {
    final map = item as Map<String, dynamic>;
    if (map.containsKey('solutionPaths')) continue; // already have it

    final levelId = map['id'] as int;
    stdout.writeln('Patching L$levelId ...');

    final derived = _rederiveLevel(levelId);
    if (derived == null) {
      stderr.writeln('  ERROR: Hamiltonian search failed for L$levelId — skipping');
      skipped++;
      continue;
    }

    if (!_dotPositionsMatch(map['dotPositions'], derived['dotPositions'])) {
      stderr.writeln('  DRIFT: dotPositions mismatch for L$levelId — skipping '
          '(generator code has changed since this level was committed)');
      drifted++;
      continue;
    }

    map['solutionPaths'] = derived['solutionPaths'];
    stdout.writeln('  OK (${(derived['solutionPaths'] as Map).length} colors)');
    patched++;
  }

  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(decoded));
  stdout.writeln('\nDone. patched=$patched  skipped=$skipped  drifted=$drifted');

  if (skipped + drifted > 0) {
    stderr.writeln('Some levels were not patched — see above for details.');
    exit(1);
  }
}

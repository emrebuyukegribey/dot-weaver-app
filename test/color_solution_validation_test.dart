// Guards the baked color-level hint solutions (GameLevel.solutionPaths).
//
// The in-game hint for colorDots levels reveals a segment of this baked
// solution instead of pathfinding live (see _revealHint in
// lib/screens/game_screen.dart) so it can never wall off another color and
// lock the player out of finishing the level. This test makes sure every
// solution actually does what it claims: connects the right endpoints for
// each color, never overlaps another color's path, and the paths together
// tile the entire board.
//
// Run with: flutter test test/color_solution_validation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:dot_weaver_app/models/game_level_model.dart';
import 'package:dot_weaver_app/services/level_generator.dart';

bool _adjacent(GridPoint a, GridPoint b) =>
    (a.row - b.row).abs() + (a.col - b.col).abs() == 1;

/// Returns a human-readable problem description, or null if [level]'s
/// solutionPaths is valid and complete.
String? _validate(GameLevel level) {
  final solution = level.solutionPaths;
  if (solution == null) return 'no solutionPaths baked for this level';

  final seen = <GridPoint>{};
  for (final color in level.dotPositions.keys) {
    final nodes = level.dotPositions[color]!;
    final path = solution[color];
    if (path == null || path.isEmpty) {
      return '$color has no solution path';
    }
    final endsMatch = (path.first == nodes[0] && path.last == nodes[1]) ||
        (path.first == nodes[1] && path.last == nodes[0]);
    if (!endsMatch) {
      return '$color solution path endpoints ${path.first}/${path.last} '
          "don't match dotPositions ${nodes[0]}/${nodes[1]}";
    }
    for (int i = 1; i < path.length; i++) {
      if (!_adjacent(path[i - 1], path[i])) {
        return '$color solution path is not contiguous at step $i '
            '(${path[i - 1]} -> ${path[i]})';
      }
    }
    for (final p in path) {
      if (p.row < 0 || p.row >= level.rows || p.col < 0 || p.col >= level.cols) {
        return '$color solution path leaves the board at $p';
      }
      if (!seen.add(p)) {
        return '$color solution path overlaps another color at $p';
      }
    }
  }

  if (seen.length != level.rows * level.cols) {
    return 'solution paths only cover ${seen.length}/${level.rows * level.cols} cells';
  }
  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every color level has a valid, complete baked solution', () async {
    await LevelGenerator.init();
    final problems = <String>[];
    for (int levelId = 1; levelId <= 100; levelId++) {
      final level = LevelGenerator.generate(levelId, islandId: '1');
      final problem = _validate(level);
      if (problem != null) {
        problems.add('L$levelId (${level.rows}x${level.cols}): $problem');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}

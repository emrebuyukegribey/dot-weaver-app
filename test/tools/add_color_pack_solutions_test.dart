// One-off generator, NOT a real test. Computes a full-board solution for the
// existing, already-shipped procedurally-generated Color Realm levels
// (51-100, assets/levels/color.json) and merges a `solutionPaths` field into
// that JSON — without touching anything else in it (dotPositions, timeLimit,
// etc. stay exactly as shipped).
//
// Why not just re-run tool/generate_levels.dart? Because the committed
// color.json (and number.json) had drifted from what the current generator
// code would produce — re-running it would silently reshuffle dotPositions
// for levels that players may already have progress on. This script only
// adds the missing solution data on top of the existing, unchanged layouts.
//
// Run with:
//   flutter test test/tools/add_color_pack_solutions_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dot_weaver_app/models/game_level_model.dart';

import 'generate_color_hand_solutions_test.dart';

void main() {
  test('add solutionPaths to assets/levels/color.json (51-100)', () {
    final file = File('assets/levels/color.json');
    final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final levels = decoded['levels'] as List;

    final failures = <int>[];
    for (final item in levels) {
      final map = Map<String, dynamic>.from(item as Map);
      final level = GameLevel.fromJson(map);
      final sw = Stopwatch()..start();
      final solution = solveColorWithPaths(level, 90000);
      // ignore: avoid_print
      print('Level ${level.id} (${level.rows}x${level.cols}): '
          '${solution == null ? 'FAILED' : 'solved'} in ${sw.elapsedMilliseconds}ms');
      if (solution == null) {
        failures.add(level.id);
        continue;
      }
      (item as Map<String, dynamic>)['solutionPaths'] = solution.map((color, pts) => MapEntry(
            color.name,
            pts.map((p) => [p.row, p.col]).toList(),
          ));
    }

    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(decoded));
    // ignore: avoid_print
    print('Updated -> ${file.path}');

    expect(failures, isEmpty,
        reason: 'Could not compute a solution for levels: $failures');
  }, timeout: const Timeout(Duration(minutes: 20)));
}

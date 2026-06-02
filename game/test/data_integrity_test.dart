import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const dataFiles = <String, String>{
    'materials': 'assets/data/materials.json',
    'recipes': 'assets/data/recipes.json',
    'cat': 'assets/data/cat_data.json',
    'npcs': 'assets/data/npcs.json',
  };

  test('game data json assets are valid and contain top-level data', () {
    for (final entry in dataFiles.entries) {
      final source = File(entry.value).readAsStringSync();
      final decoded = jsonDecode(source) as Map<String, dynamic>;

      expect(decoded, contains(entry.key), reason: entry.value);
      expect(decoded[entry.key], isNotNull, reason: entry.value);
    }
  });
}

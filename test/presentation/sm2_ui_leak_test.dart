import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('presentation não vaza fórmula SM-2 (T073, constitution §5)', () {
    final root = Directory('lib/presentation');
    expect(root.existsSync(), isTrue);

    final leaks = <String>[];
    final forbidden = [
      'easeFactor',
      'intervalDays',
      'Sm2Policy',
      '0.1 - (5',
      '0.08 + 0.02',
      '1 min',
      '1 day',
      '4 days',
    ];

    for (final file in root.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) {
        continue;
      }
      final source = file.readAsStringSync();
      for (final needle in forbidden) {
        if (source.contains(needle)) {
          leaks.add('${file.path}: $needle');
        }
      }
    }

    expect(leaks, isEmpty, reason: leaks.join('\n'));
  });
}

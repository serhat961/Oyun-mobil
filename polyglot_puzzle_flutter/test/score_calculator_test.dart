import 'package:flutter_test/flutter_test.dart';
import 'package:polyglot_puzzle_flutter/domain/score_calculator.dart';

void main() {
  group('ScoreCalculator', () {
    test('single clear adds 10 points', () {
      final calc = ScoreCalculator();
      calc.addClears(lines: 1, chain: 1);
      expect(calc.score, 10);
    });

    test('chain multiplier applies', () {
      final calc = ScoreCalculator();
      calc.addClears(lines: 2, chain: 1); // +20
      calc.addClears(lines: 1, chain: 2); // +10*2 = 20
      expect(calc.score, 40);
    });
  });
}
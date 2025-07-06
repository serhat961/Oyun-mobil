import 'package:flutter_test/flutter_test.dart';
import 'package:polyglot_puzzle_flutter/domain/game_board.dart';
import 'package:polyglot_puzzle_flutter/domain/piece.dart';
import 'package:polyglot_puzzle_flutter/domain/position.dart';

void main() {
  group('Valid move detection', () {
    final singleBlock = Piece(TetrominoType.I, [Position(0, 0)]);

    test('empty board accepts placement', () {
      final board = GameBoard.empty();
      expect(board.canPlace(PiecePlacement(singleBlock, Position(0, 0))), isTrue);
    });

    test('rejects placement outside bounds', () {
      final board = GameBoard.empty();
      expect(board.canPlace(PiecePlacement(singleBlock, Position(8, 8))), isFalse);
    });

    test('rejects overlapping placement', () {
      var board = GameBoard.empty();
      board = board.place(PiecePlacement(singleBlock, Position(0, 0)));
      expect(board.canPlace(PiecePlacement(singleBlock, Position(0, 0))), isFalse);
    });
  });
}
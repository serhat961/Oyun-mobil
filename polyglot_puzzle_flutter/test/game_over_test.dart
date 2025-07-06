import 'package:flutter_test/flutter_test.dart';
import 'package:polyglot_puzzle_flutter/domain/game_board.dart';
import 'package:polyglot_puzzle_flutter/domain/piece.dart';
import 'package:polyglot_puzzle_flutter/domain/position.dart';

void main() {
  group('Game over detection', () {
    final singleBlock = Piece(TetrominoType.I, [Position(0, 0)]);

    test('empty board is not game over', () {
      final board = GameBoard.empty();
      expect(board.isGameOver([singleBlock]), isFalse);
    });

    test('full board is game over', () {
      var board = GameBoard.empty();
      for (int r = 0; r < GameBoard.size; r++) {
        for (int c = 0; c < GameBoard.size; c++) {
          board = board.place(PiecePlacement(singleBlock, Position(r, c)));
        }
      }
      expect(board.isGameOver([singleBlock]), isTrue);
    });
  });
}
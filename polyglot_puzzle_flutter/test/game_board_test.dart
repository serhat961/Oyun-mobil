import 'package:flutter_test/flutter_test.dart';
import 'package:polyglot_puzzle_flutter/domain/game_board.dart';
import 'package:polyglot_puzzle_flutter/domain/piece.dart';
import 'package:polyglot_puzzle_flutter/domain/position.dart';

void main() {
  group('GameBoard', () {
    test('detects full row', () {
      var board = GameBoard.empty();
      final piece = Piece(TetrominoType.I, [
        Position(0, 0),
      ]);
      // Fill first row
      for (int col = 0; col < GameBoard.size; col++) {
        board = board.place(PiecePlacement(piece, Position(0, col)));
      }
      final cleared = board.detectClears();
      expect(cleared.rows.contains(0), isTrue);
    });
  });
}
import 'package:flutter/material.dart';
import '../../domain/game_board.dart';
import '../../domain/score_calculator.dart';

class GameViewModel extends ChangeNotifier {
  GameBoard _board = GameBoard.empty();
  final ScoreCalculator _scoreCalculator = ScoreCalculator();

  GameBoard get board => _board;
  int get score => _scoreCalculator.score;

  void placePiece(PiecePlacement placement) {
    if (_board.canPlace(placement)) {
      _board = _board.place(placement);
      final clearedLines = _board.detectClears();
      _scoreCalculator.updateScore(clearedLines);
      notifyListeners();
    }
  }

  void reset() {
    _board = GameBoard.empty();
    _scoreCalculator.reset();
    notifyListeners();
  }
}
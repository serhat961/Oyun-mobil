import 'package:flutter/material.dart';
import 'dart:async';

import '../../domain/game_board.dart';
import '../../domain/piece.dart';
import '../../domain/piece_generator.dart';
import '../../domain/score_calculator.dart';
import '../../domain/position.dart';

class GameViewModel extends ChangeNotifier {
  GameBoard _board = GameBoard.empty();
  final ScoreCalculator _scoreCalculator = ScoreCalculator();

  final PieceGenerator _generator = PieceGenerator();

  late Piece _currentPiece;
  final List<Piece> _nextPieces = [];

  GameViewModel() {
    _initQueue();
  }

  void _initQueue() {
    _currentPiece = _generator.next();
    _nextPieces
      ..clear()
      ..addAll([_generator.next(), _generator.next(), _generator.next()]);
  }

  GameBoard get board => _board;
  int get score => _scoreCalculator.score;
  Piece get currentPiece => _currentPiece;
  List<Piece> get nextPieces => List.unmodifiable(_nextPieces);

  bool canPlaceCurrentPiece(Position origin) {
    return _board.canPlace(PiecePlacement(_currentPiece, origin));
  }

  Future<void> placeCurrentPiece(Position origin) async {
    final placement = PiecePlacement(_currentPiece, origin);
    if (!_board.canPlace(placement)) return;

    // Place piece on board
    _board = _board.place(placement);
    notifyListeners();

    // Cascade clear loop
    int chain = 1;
    while (true) {
      final clears = _board.detectClears();
      if (clears.isEmpty) break;

      // Wait briefly to allow UI to show filled lines before clearing
      await Future.delayed(const Duration(milliseconds: 200));

      _board = _board.clearLines(clears);
      _scoreCalculator.addClears(lines: clears.lineCount, chain: chain);
      chain++;
      notifyListeners();
    }

    // Advance piece queue
    _currentPiece = _nextPieces.removeAt(0);
    _nextPieces.add(_generator.next());
    notifyListeners();
  }

  void reset() {
    _board = GameBoard.empty();
    _scoreCalculator.reset();
    _initQueue();
    notifyListeners();
  }
}
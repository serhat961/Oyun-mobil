import 'package:flutter/material.dart';
import 'dart:async';

import '../../domain/game_board.dart';
import '../../domain/piece.dart';
import '../../domain/piece_generator.dart';
import '../../domain/game_piece.dart';
import '../../domain/vocab_word.dart';
import '../../data/word_repository.dart';
import '../../domain/score_calculator.dart';
import '../../domain/position.dart';
import '../../monetization/ad_manager.dart';

class GameViewModel extends ChangeNotifier {
  GameBoard _board = GameBoard.empty();
  final ScoreCalculator _scoreCalculator = ScoreCalculator();

  final PieceGenerator _generator = PieceGenerator();
  final WordRepository _wordRepo = WordRepository.instance;

  bool _initialized = false;
  bool get isReady => _initialized;

  late GamePiece _currentPiece;
  final List<GamePiece> _nextPieces = [];

  int _placementCount = 0;

  GameViewModel() {
    _initQueue();
  }

  Future<void> _initQueue() async {
    final pieces = await _generateGamePieces(4);
    _currentPiece = pieces.first;
    _nextPieces
      ..clear()
      ..addAll(pieces.sublist(1));
    _initialized = true;
    notifyListeners();
  }

  Future<List<GamePiece>> _generateGamePieces(int count) async {
    final shapes = List.generate(count, (_) => _generator.next());
    final words = await _wordRepo.getWordsForPieces(count);
    final List<GamePiece> gamePieces = [];
    for (var i = 0; i < count; i++) {
      final piece = GamePiece(shape: shapes[i], word: words[i]);
      await _wordRepo.markExposure(words[i]);
      gamePieces.add(piece);
    }
    return gamePieces;
  }

  GameBoard get board => _board;
  int get score => _scoreCalculator.score;
  GamePiece get currentPiece => _currentPiece;
  List<GamePiece> get nextPieces => List.unmodifiable(_nextPieces);

  // For animations
  Set<Position> _clearingPositions = {};
  Set<Position> get clearingPositions => _clearingPositions;

  void rotateCurrentPieceCW() {
    _currentPiece = GamePiece(
      shape: _currentPiece.shape.rotatedCW(),
      word: _currentPiece.word,
    );
    notifyListeners();
  }

  void rotateCurrentPieceCCW() {
    _currentPiece = GamePiece(
      shape: _currentPiece.shape.rotatedCCW(),
      word: _currentPiece.word,
    );
    notifyListeners();
  }

  bool canPlaceCurrentPiece(Position origin) {
    return _board.canPlace(PiecePlacement(_currentPiece.shape, origin));
  }

  Future<void> placeCurrentPiece(Position origin) async {
    final placement = PiecePlacement(_currentPiece.shape, origin);
    if (!_board.canPlace(placement)) return;

    // Place piece on board
    _board = _board.place(placement);
    // Consider correct recall success (quality 4)
    await _wordRepo.review(_currentPiece.word, 4);
    notifyListeners();

    _placementCount++;
    if (_placementCount % 10 == 0) {
      AdManager.instance.showInterstitial(onShown: () {}, onFailed: () {});
    }

    // Cascade clear loop
    int chain = 1;
    while (true) {
      final clears = _board.detectClears();
      if (clears.isEmpty) break;

      // Mark positions for highlight animation
      _clearingPositions = {
        ...clears.rows.expand((r) => List.generate(GameBoard.size, (c) => Position(r, c))),
        ...clears.cols.expand((c) => List.generate(GameBoard.size, (r) => Position(r, c))),
      };
      notifyListeners();

      // Wait briefly to allow UI to show highlight
      await Future.delayed(const Duration(milliseconds: 180));

      _board = _board.clearLines(clears);
      _clearingPositions = {};
      _scoreCalculator.addClears(lines: clears.lineCount, chain: chain);
      chain++;
      notifyListeners();
    }

    // Advance piece queue
    if (_nextPieces.isNotEmpty) {
      _currentPiece = _nextPieces.removeAt(0);
    }
    final newPieces = await _generateGamePieces(1);
    _nextPieces.addAll(newPieces);
    notifyListeners();
  }

  Future<bool> useHint() async {
    // Try to find first valid placement
    for (int r = 0; r < GameBoard.size; r++) {
      for (int c = 0; c < GameBoard.size; c++) {
        final pos = Position(r, c);
        if (canPlaceCurrentPiece(pos)) {
          await placeCurrentPiece(pos);
          return true;
        }
      }
    }
    return false;
  }

  Future<void> reset() async {
    _initialized = false;
    _board = GameBoard.empty();
    _scoreCalculator.reset();
    await _initQueue();
    _placementCount = 0;
    _clearingPositions = {};
  }
}
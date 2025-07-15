import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'piece.dart';

class GameBoard extends Equatable {
  static const int boardSize = 8;
  
  final List<List<BoardCell?>> grid;
  final int score;
  final int level;
  final int linesCleared;
  final List<Piece> nextPieces;
  final DateTime lastMoveTime;
  final int combo;
  final bool isGameOver;

  const GameBoard({
    required this.grid,
    this.score = 0,
    this.level = 1,
    this.linesCleared = 0,
    this.nextPieces = const [],
    required this.lastMoveTime,
    this.combo = 0,
    this.isGameOver = false,
  });

  factory GameBoard.initial() {
    return GameBoard(
      grid: List.generate(
        boardSize,
        (_) => List.generate(boardSize, (_) => null),
      ),
      lastMoveTime: DateTime.now(),
    );
  }

  bool canPlacePiece(Piece piece, int row, int col) {
    for (int r = 0; r < piece.height; r++) {
      for (int c = 0; c < piece.width; c++) {
        if (piece.shape[r][c]) {
          final boardRow = row + r;
          final boardCol = col + c;
          
          if (boardRow < 0 || 
              boardRow >= boardSize || 
              boardCol < 0 || 
              boardCol >= boardSize ||
              grid[boardRow][boardCol] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  GameBoard placePiece(Piece piece, int row, int col) {
    if (!canPlacePiece(piece, row, col)) {
      return this;
    }

    final newGrid = List<List<BoardCell?>>.from(
      grid.map((row) => List<BoardCell?>.from(row)),
    );

    for (int r = 0; r < piece.height; r++) {
      for (int c = 0; c < piece.width; c++) {
        if (piece.shape[r][c]) {
          newGrid[row + r][col + c] = BoardCell(
            pieceId: piece.id,
            color: piece.color,
            wordId: piece.wordId,
          );
        }
      }
    }

    return copyWith(
      grid: newGrid,
      lastMoveTime: DateTime.now(),
    );
  }

  ({GameBoard board, int linesCleared, List<int> clearedRows, List<int> clearedCols}) checkAndClearLines() {
    final List<int> rowsToClear = [];
    final List<int> colsToClear = [];
    
    // Check rows
    for (int row = 0; row < boardSize; row++) {
      if (grid[row].every((cell) => cell != null)) {
        rowsToClear.add(row);
      }
    }
    
    // Check columns
    for (int col = 0; col < boardSize; col++) {
      bool columnFull = true;
      for (int row = 0; row < boardSize; row++) {
        if (grid[row][col] == null) {
          columnFull = false;
          break;
        }
      }
      if (columnFull) {
        colsToClear.add(col);
      }
    }

    if (rowsToClear.isEmpty && colsToClear.isEmpty) {
      return (board: this, linesCleared: 0, clearedRows: [], clearedCols: []);
    }

    final newGrid = List<List<BoardCell?>>.from(
      grid.map((row) => List<BoardCell?>.from(row)),
    );

    // Clear rows
    for (final row in rowsToClear) {
      for (int col = 0; col < boardSize; col++) {
        newGrid[row][col] = null;
      }
    }

    // Clear columns
    for (final col in colsToClear) {
      for (int row = 0; row < boardSize; row++) {
        newGrid[row][col] = null;
      }
    }

    final totalCleared = rowsToClear.length + colsToClear.length;
    final newScore = score + calculateScore(totalCleared, combo);
    final newCombo = totalCleared > 0 ? combo + 1 : 0;
    final newLinesCleared = linesCleared + totalCleared;
    final newLevel = (newLinesCleared ~/ 10) + 1;

    return (
      board: copyWith(
        grid: newGrid,
        score: newScore,
        combo: newCombo,
        linesCleared: newLinesCleared,
        level: newLevel,
      ),
      linesCleared: totalCleared,
      clearedRows: rowsToClear,
      clearedCols: colsToClear,
    );
  }

  int calculateScore(int linesCleared, int combo) {
    const baseScore = 100;
    final lineBonus = {
      1: 1,
      2: 3,
      3: 5,
      4: 8,
    };
    
    final bonus = lineBonus[linesCleared] ?? linesCleared * 2;
    final comboMultiplier = 1.0 + (combo * 0.5);
    
    return (baseScore * bonus * level * comboMultiplier).round();
  }

  bool checkGameOver() {
    // Check if any of the next pieces can be placed anywhere
    if (nextPieces.isEmpty) return false;
    
    final nextPiece = nextPieces.first;
    
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (canPlacePiece(nextPiece, row, col)) {
          return false;
        }
      }
    }
    
    return true;
  }

  GameBoard copyWith({
    List<List<BoardCell?>>? grid,
    int? score,
    int? level,
    int? linesCleared,
    List<Piece>? nextPieces,
    DateTime? lastMoveTime,
    int? combo,
    bool? isGameOver,
  }) {
    return GameBoard(
      grid: grid ?? this.grid,
      score: score ?? this.score,
      level: level ?? this.level,
      linesCleared: linesCleared ?? this.linesCleared,
      nextPieces: nextPieces ?? this.nextPieces,
      lastMoveTime: lastMoveTime ?? this.lastMoveTime,
      combo: combo ?? this.combo,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }

  @override
  List<Object?> get props => [
        grid,
        score,
        level,
        linesCleared,
        nextPieces,
        lastMoveTime,
        combo,
        isGameOver,
      ];
}

class BoardCell extends Equatable {
  final String pieceId;
  final Color color;
  final String? wordId;

  const BoardCell({
    required this.pieceId,
    required this.color,
    this.wordId,
  });

  @override
  List<Object?> get props => [pieceId, color, wordId];
}
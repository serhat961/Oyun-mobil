part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class StartGame extends GameEvent {
  final List<VocabularyWord> vocabularyWords;

  const StartGame({required this.vocabularyWords});

  @override
  List<Object?> get props => [vocabularyWords];
}

class PieceDragStarted extends GameEvent {
  final Piece piece;
  final Offset position;

  const PieceDragStarted({
    required this.piece,
    required this.position,
  });

  @override
  List<Object?> get props => [piece, position];
}

class PieceDragUpdated extends GameEvent {
  final Offset position;

  const PieceDragUpdated({required this.position});

  @override
  List<Object?> get props => [position];
}

class PieceDragEnded extends GameEvent {
  final Offset position;
  final int? gridRow;
  final int? gridCol;

  const PieceDragEnded({
    required this.position,
    this.gridRow,
    this.gridCol,
  });

  @override
  List<Object?> get props => [position, gridRow, gridCol];
}

class PiecePlaced extends GameEvent {
  final Piece piece;
  final int row;
  final int col;

  const PiecePlaced({
    required this.piece,
    required this.row,
    required this.col,
  });

  @override
  List<Object?> get props => [piece, row, col];
}

class PieceRotated extends GameEvent {
  const PieceRotated();
}

class GameTimerTicked extends GameEvent {
  const GameTimerTicked();
}

class PauseGame extends GameEvent {
  const PauseGame();
}

class ResumeGame extends GameEvent {
  const ResumeGame();
}

class GameOver extends GameEvent {
  const GameOver();
}

class ClearAnimationCompleted extends GameEvent {
  final GameBoard clearedBoard;

  const ClearAnimationCompleted({required this.clearedBoard});

  @override
  List<Object?> get props => [clearedBoard];
}
part of 'game_bloc.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GamePlaying extends GameState {
  final GameBoard board;
  final Piece? currentPiece;
  final Offset? dragPosition;
  final Duration elapsedTime;
  final List<VocabularyWord> vocabularyWords;
  final bool isAnimatingClear;
  final List<int> clearedRows;
  final List<int> clearedCols;

  const GamePlaying({
    required this.board,
    required this.currentPiece,
    required this.dragPosition,
    required this.elapsedTime,
    required this.vocabularyWords,
    required this.isAnimatingClear,
    this.clearedRows = const [],
    this.clearedCols = const [],
  });

  GamePlaying copyWith({
    GameBoard? board,
    Piece? currentPiece,
    Offset? dragPosition,
    Duration? elapsedTime,
    List<VocabularyWord>? vocabularyWords,
    bool? isAnimatingClear,
    List<int>? clearedRows,
    List<int>? clearedCols,
  }) {
    return GamePlaying(
      board: board ?? this.board,
      currentPiece: currentPiece ?? this.currentPiece,
      dragPosition: dragPosition ?? this.dragPosition,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      vocabularyWords: vocabularyWords ?? this.vocabularyWords,
      isAnimatingClear: isAnimatingClear ?? this.isAnimatingClear,
      clearedRows: clearedRows ?? this.clearedRows,
      clearedCols: clearedCols ?? this.clearedCols,
    );
  }

  @override
  List<Object?> get props => [
        board,
        currentPiece,
        dragPosition,
        elapsedTime,
        vocabularyWords,
        isAnimatingClear,
        clearedRows,
        clearedCols,
      ];
}

class GamePaused extends GameState {
  final GamePlaying previousState;

  const GamePaused({required this.previousState});

  @override
  List<Object?> get props => [previousState];
}

class GameOverState extends GameState {
  final int finalScore;
  final int level;
  final int linesCleared;
  final Duration elapsedTime;
  final int? gainedXp;
  final bool? leveledUp;
  final int? newLevel;

  const GameOverState({
    required this.finalScore,
    required this.level,
    required this.linesCleared,
    required this.elapsedTime,
    this.gainedXp,
    this.leveledUp,
    this.newLevel,
  });

  @override
  List<Object?> get props => [finalScore, level, linesCleared, elapsedTime, gainedXp, leveledUp, newLevel];
}
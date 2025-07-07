import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:polyglot_puzzle/features/game/domain/entities/game_board.dart';
import 'package:polyglot_puzzle/features/game/domain/entities/piece.dart';
import 'package:polyglot_puzzle/features/language_learning/domain/entities/vocabulary_word.dart';
import 'package:polyglot_puzzle/features/game/data/repositories/game_repository.dart';
import 'package:polyglot_puzzle/features/achievements/domain/entities/achievement.dart';
import 'package:polyglot_puzzle/core/services/audio_service.dart';
import 'package:uuid/uuid.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final _uuid = const Uuid();
  final Random _random = Random();
  final GameRepository _gameRepository;
  final AudioService _audioService;
  Timer? _gameTimer;
  DateTime? _gameStartTime;
  
  GameBloc({
    GameRepository? gameRepository,
    AudioService? audioService,
  }) : _gameRepository = gameRepository ?? GameRepository(),
       _audioService = audioService ?? AudioService(),
       super(GameInitial()) {
    on<StartGame>(_onStartGame);
    on<PieceDragStarted>(_onPieceDragStarted);
    on<PieceDragUpdated>(_onPieceDragUpdated);
    on<PieceDragEnded>(_onPieceDragEnded);
    on<PiecePlaced>(_onPiecePlaced);
    on<PieceRotated>(_onPieceRotated);
    on<GameTimerTicked>(_onGameTimerTicked);
    on<PauseGame>(_onPauseGame);
    on<ResumeGame>(_onResumeGame);
    on<GameOver>(_onGameOver);
    on<ClearAnimationCompleted>(_onClearAnimationCompleted);
  }

  void _onStartGame(StartGame event, Emitter<GameState> emit) {
    _gameTimer?.cancel();
    _gameStartTime = DateTime.now();
    
    final board = GameBoard.initial();
    final nextPieces = _generateNextPieces(3, event.vocabularyWords);
    
    emit(GamePlaying(
      board: board.copyWith(nextPieces: nextPieces),
      currentPiece: null,
      dragPosition: null,
      elapsedTime: Duration.zero,
      vocabularyWords: event.vocabularyWords,
      isAnimatingClear: false,
    ));
    
    _startGameTimer();
  }

  void _onPieceDragStarted(PieceDragStarted event, Emitter<GameState> emit) {
    if (state is! GamePlaying) return;
    
    final currentState = state as GamePlaying;
    if (currentState.board.isGameOver) return;
    
    emit(currentState.copyWith(
      currentPiece: event.piece,
      dragPosition: event.position,
    ));
  }

  void _onPieceDragUpdated(PieceDragUpdated event, Emitter<GameState> emit) {
    if (state is! GamePlaying) return;
    
    final currentState = state as GamePlaying;
    if (currentState.currentPiece == null) return;
    
    emit(currentState.copyWith(
      dragPosition: event.position,
    ));
  }

  void _onPieceDragEnded(PieceDragEnded event, Emitter<GameState> emit) {
    if (state is! GamePlaying) return;
    
    final currentState = state as GamePlaying;
    if (currentState.currentPiece == null) return;
    
    // Calculate grid position from drag position
    final gridRow = event.gridRow;
    final gridCol = event.gridCol;
    
    if (gridRow != null && gridCol != null) {
      add(PiecePlaced(
        piece: currentState.currentPiece!,
        row: gridRow,
        col: gridCol,
      ));
    } else {
      // Return piece to preview area
      emit(currentState.copyWith(
        currentPiece: null,
        dragPosition: null,
      ));
    }
  }

  void _onPiecePlaced(PiecePlaced event, Emitter<GameState> emit) async {
    if (state is! GamePlaying) return;
    
    final currentState = state as GamePlaying;
    var board = currentState.board;
    
    // Try to place the piece
    if (!board.canPlacePiece(event.piece, event.row, event.col)) {
      // Invalid placement - return piece
      emit(currentState.copyWith(
        currentPiece: null,
        dragPosition: null,
      ));
      return;
    }
    
    // Place the piece
    board = board.placePiece(event.piece, event.row, event.col);
    
    // Play piece placed sound
    _audioService.playPiecePlaced();
    
    // Remove placed piece from next pieces
    final nextPieces = List<Piece>.from(board.nextPieces);
    nextPieces.removeWhere((p) => p.id == event.piece.id);
    
    // Generate new piece if needed
    if (nextPieces.length < 3) {
      nextPieces.addAll(_generateNextPieces(3 - nextPieces.length, currentState.vocabularyWords));
    }
    
    board = board.copyWith(nextPieces: nextPieces);
    
    // Check for line clears
    final clearResult = board.checkAndClearLines();
    
    if (clearResult.linesCleared > 0) {
      // Play line clear sound (combo if multiple lines)
      if (clearResult.linesCleared > 1) {
        _audioService.playCombo();
      } else {
        _audioService.playLineClear();
      }
      
      // Start clear animation
      emit(currentState.copyWith(
        board: board,
        currentPiece: null,
        dragPosition: null,
        isAnimatingClear: true,
        clearedRows: clearResult.clearedRows,
        clearedCols: clearResult.clearedCols,
      ));
      
      // Wait for animation then apply cleared board
      await Future.delayed(const Duration(milliseconds: 500));
      add(ClearAnimationCompleted(clearedBoard: clearResult.board));
    } else {
      // Check for game over
      if (clearResult.board.checkGameOver()) {
        add(GameOver());
      } else {
        emit(currentState.copyWith(
          board: board,
          currentPiece: null,
          dragPosition: null,
        ));
      }
    }
  }

  void _onClearAnimationCompleted(ClearAnimationCompleted event, Emitter<GameState> emit) {
    if (state is! GamePlaying) return;
    
    final currentState = state as GamePlaying;
    
    // Check for game over
    if (event.clearedBoard.checkGameOver()) {
      add(GameOver());
    } else {
      emit(currentState.copyWith(
        board: event.clearedBoard,
        isAnimatingClear: false,
        clearedRows: [],
        clearedCols: [],
      ));
    }
  }

  void _onPieceRotated(PieceRotated event, Emitter<GameState> emit) {
    if (state is! GamePlaying) return;
    
    final currentState = state as GamePlaying;
    if (currentState.currentPiece == null) return;
    
    final rotatedPiece = currentState.currentPiece!.rotate();
    
    // Play rotation sound
    _audioService.playPieceRotate();
    
    emit(currentState.copyWith(
      currentPiece: rotatedPiece,
    ));
  }

  void _onGameTimerTicked(GameTimerTicked event, Emitter<GameState> emit) {
    if (state is! GamePlaying) return;
    
    final currentState = state as GamePlaying;
    emit(currentState.copyWith(
      elapsedTime: currentState.elapsedTime + const Duration(seconds: 1),
    ));
  }

  void _onPauseGame(PauseGame event, Emitter<GameState> emit) {
    if (state is! GamePlaying) return;
    
    _gameTimer?.cancel();
    emit(GamePaused(previousState: state as GamePlaying));
  }

  void _onResumeGame(ResumeGame event, Emitter<GameState> emit) {
    if (state is! GamePaused) return;
    
    final pausedState = state as GamePaused;
    emit(pausedState.previousState);
    _startGameTimer();
  }

  void _onGameOver(GameOver event, Emitter<GameState> emit) async {
    if (state is! GamePlaying) return;
    
    _gameTimer?.cancel();
    final currentState = state as GamePlaying;
    
    // Calculate play time
    final playTimeInSeconds = _gameStartTime != null 
        ? DateTime.now().difference(_gameStartTime!).inSeconds
        : currentState.elapsedTime.inSeconds;
    
    // Save game session
    try {
      final session = GameSession(
        score: currentState.board.score,
        linesCleared: currentState.board.linesCleared,
        levelReached: currentState.board.level,
        playTimeInSeconds: playTimeInSeconds,
      );
      
      final progress = await _gameRepository.saveGameSession(session);
      final gainedXp = _gameRepository.calculateXpGain(session);
      
      // Play appropriate sound
      if (progress.leveledUp) {
        _audioService.playLevelUp();
      } else {
        _audioService.playGameOver();
      }
      
      emit(GameOverState(
        finalScore: currentState.board.score,
        level: currentState.board.level,
        linesCleared: currentState.board.linesCleared,
        elapsedTime: currentState.elapsedTime,
        gainedXp: gainedXp,
        leveledUp: progress.leveledUp,
        newLevel: progress.level,
        newlyUnlockedAchievements: progress.newlyUnlockedAchievements,
      ));
    } catch (e) {
      // Fallback without progress tracking
      emit(GameOverState(
        finalScore: currentState.board.score,
        level: currentState.board.level,
        linesCleared: currentState.board.linesCleared,
        elapsedTime: currentState.elapsedTime,
      ));
    }
  }

  List<Piece> _generateNextPieces(int count, List<VocabularyWord> vocabularyWords) {
    final pieces = <Piece>[];
    
    for (int i = 0; i < count; i++) {
      final type = PieceType.values[_random.nextInt(PieceType.values.length)];
      final shapes = Piece.pieceShapes[type]!;
      
      // Assign vocabulary word based on algorithm
      String? wordId;
      if (vocabularyWords.isNotEmpty) {
        wordId = _selectVocabularyWord(vocabularyWords).id;
      }
      
      pieces.add(Piece(
        id: _uuid.v4(),
        type: type,
        shape: shapes[0],
        color: Piece.pieceColors[type]!,
        wordId: wordId,
        createdAt: DateTime.now(),
      ));
    }
    
    return pieces;
  }

  VocabularyWord _selectVocabularyWord(List<VocabularyWord> words) {
    // Word selection algorithm:
    // 70% previously seen words (based on SM2 intervals)
    // 20% new words (frequency-based introduction)
    // 10% challenge words (above current level)
    
    final dueForReview = words.where((w) => w.isDueForReview).toList();
    final newWords = words.where((w) => w.repetitions == 0).toList();
    final challengeWords = words.where((w) => w.difficulty > 3).toList();
    
    final chance = _random.nextDouble();
    
    if (chance < 0.7 && dueForReview.isNotEmpty) {
      return dueForReview[_random.nextInt(dueForReview.length)];
    } else if (chance < 0.9 && newWords.isNotEmpty) {
      return newWords[_random.nextInt(newWords.length)];
    } else if (challengeWords.isNotEmpty) {
      return challengeWords[_random.nextInt(challengeWords.length)];
    }
    
    // Fallback to any word
    return words[_random.nextInt(words.length)];
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(GameTimerTicked());
    });
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    return super.close();
  }
}
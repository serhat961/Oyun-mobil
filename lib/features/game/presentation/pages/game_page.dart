import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polyglot_puzzle/features/game/presentation/bloc/game_bloc.dart';
import 'package:polyglot_puzzle/features/game/presentation/widgets/game_board_widget.dart';
import 'package:polyglot_puzzle/features/game/presentation/widgets/piece_preview_widget.dart';
import 'package:polyglot_puzzle/features/game/presentation/widgets/player_profile_widget.dart';
import 'package:polyglot_puzzle/features/settings/presentation/pages/settings_page.dart';
import 'package:polyglot_puzzle/features/language_learning/domain/entities/vocabulary_word.dart';
import 'package:google_fonts/google_fonts.dart';

class GamePage extends StatelessWidget {
  final List<VocabularyWord> vocabularyWords;

  const GamePage({
    Key? key,
    required this.vocabularyWords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(StartGame(vocabularyWords: vocabularyWords)),
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: SafeArea(
          child: BlocConsumer<GameBloc, GameState>(
            listener: (context, state) {
              if (state is GameOverState && state.leveledUp == true) {
                // Show level up dialog after a short delay
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    LevelUpDialog.show(
                      context, 
                      state.newLevel ?? 1, 
                      state.gainedXp ?? 0,
                    );
                  }
                });
              }
            },
            builder: (context, state) {
              if (state is GamePlaying) {
                return _buildGameContent(context, state);
              } else if (state is GamePaused) {
                return _buildPausedContent(context, state);
              } else if (state is GameOverState) {
                return _buildGameOverContent(context, state);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent(BuildContext context, GamePlaying state) {
    return Column(
      children: [
        // Header with score and stats
        _buildHeader(context, state),
        
        const SizedBox(height: 16),
        
        // Game board
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GameBoardWidget(
            board: state.board,
            currentPiece: state.currentPiece,
            dragPosition: state.dragPosition,
            isAnimatingClear: state.isAnimatingClear,
            clearedRows: state.clearedRows,
            clearedCols: state.clearedCols,
            onCellTap: (row, col) {
              // Handle cell tap if needed
            },
            onDragUpdate: (details) {
              context.read<GameBloc>().add(
                    PieceDragUpdated(position: details.globalPosition),
                  );
            },
            onDragEnd: (details) {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final localPosition = renderBox.globalToLocal(details.globalPosition);
              
              // Calculate grid position
              final boardSize = MediaQuery.of(context).size.width - 32;
              final cellSize = boardSize / 8;
              
              final gridCol = (localPosition.dx / cellSize).floor();
              final gridRow = ((localPosition.dy - 200) / cellSize).floor(); // Adjust for header
              
              context.read<GameBloc>().add(
                    PieceDragEnded(
                      position: details.globalPosition,
                      gridRow: gridRow,
                      gridCol: gridCol,
                    ),
                  );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Piece preview
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PiecePreviewWidget(
            nextPieces: state.board.nextPieces,
            vocabularyWords: state.vocabularyWords,
            onPieceDragStarted: (piece, position) {
              context.read<GameBloc>().add(
                    PieceDragStarted(piece: piece, position: position),
                  );
            },
            onRotatePiece: () {
              context.read<GameBloc>().add(const PieceRotated());
            },
          ),
        ),
        
        const Spacer(),
        
        // Control buttons
        _buildControlButtons(context),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, GamePlaying state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCORE',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                state.board.score.toString().padLeft(6, '0'),
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Level
          Column(
            children: [
              Text(
                'LEVEL',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                state.board.level.toString(),
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TIME',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(state.elapsedTime),
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pause button
        IconButton(
          onPressed: () {
            context.read<GameBloc>().add(const PauseGame());
          },
          icon: const Icon(Icons.pause),
          color: Colors.white,
          iconSize: 32,
        ),
        
        // Rotate button
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              context.read<GameBloc>().add(const PieceRotated());
            },
            icon: const Icon(Icons.rotate_right),
            color: Colors.white,
            iconSize: 32,
          ),
        ),
        
        // Settings button
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            );
          },
          icon: const Icon(Icons.settings),
          color: Colors.white,
          iconSize: 32,
        ),
      ],
    );
  }

  Widget _buildPausedContent(BuildContext context, GamePaused state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: GoogleFonts.orbitron(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<GameBloc>().add(const ResumeGame());
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('RESUME'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('QUIT GAME'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverContent(BuildContext context, GameOverState state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME OVER',
              style: GoogleFonts.orbitron(
                fontSize: 32,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatRow('Final Score', state.finalScore.toString()),
            _buildStatRow('Level Reached', state.level.toString()),
            _buildStatRow('Lines Cleared', state.linesCleared.toString()),
            _buildStatRow('Time', _formatDuration(state.elapsedTime)),
            if (state.gainedXp != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[900]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'Experience Gained',
                      style: TextStyle(
                        color: Colors.green[300],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${state.gainedXp} XP',
                      style: GoogleFonts.orbitron(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.leveledUp == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        '🎉 Level Up! 🎉',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<GameBloc>().add(
                      StartGame(vocabularyWords: vocabularyWords),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('PLAY AGAIN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('BACK TO MENU'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 32),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
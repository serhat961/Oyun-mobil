import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:polyglot_puzzle/features/game/domain/entities/game_board.dart';
import 'package:polyglot_puzzle/features/game/domain/entities/piece.dart';
import 'package:polyglot_puzzle/features/language_learning/domain/entities/vocabulary_word.dart';
import 'package:polyglot_puzzle/core/services/audio_service.dart';
import 'package:vibration/vibration.dart';

class GameBoardWidget extends StatelessWidget {
  final GameBoard board;
  final Piece? currentPiece;
  final Offset? dragPosition;
  final List<VocabularyWord> vocabularyWords;
  final Function(int row, int col) onCellTap;
  final Function(DragUpdateDetails details) onDragUpdate;
  final Function(DragEndDetails details) onDragEnd;
  final bool isAnimatingClear;
  final List<int> clearedRows;
  final List<int> clearedCols;

  const GameBoardWidget({
    Key? key,
    required this.board,
    this.currentPiece,
    this.dragPosition,
    required this.vocabularyWords,
    required this.onCellTap,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.isAnimatingClear = false,
    this.clearedRows = const [],
    this.clearedCols = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = constraints.maxWidth / GameBoard.boardSize;
              
              return Stack(
                children: [
                  // Grid background
                  _buildGridBackground(cellSize),
                  
                  // Placed pieces
                  _buildPlacedPieces(cellSize),
                  
                  // Drag target overlay
                  if (currentPiece != null && dragPosition != null)
                    _buildDragPreview(cellSize),
                  
                  // Touch detection overlay
                  _buildTouchOverlay(cellSize),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGridBackground(double cellSize) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: GameBoard.boardSize,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: GameBoard.boardSize * GameBoard.boardSize,
      itemBuilder: (context, index) {
        final row = index ~/ GameBoard.boardSize;
        final col = index % GameBoard.boardSize;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildPlacedPieces(double cellSize) {
    return Stack(
      children: [
        for (int row = 0; row < GameBoard.boardSize; row++)
          for (int col = 0; col < GameBoard.boardSize; col++)
                          if (board.grid[row][col] != null)
                Positioned(
                  left: col * cellSize + col * 1,
                  top: row * cellSize + row * 1,
                  width: cellSize,
                  height: cellSize,
                  child: _buildCell(
                    board.grid[row][col]!,
                    isClearing: clearedRows.contains(row) || clearedCols.contains(col),
                    cellSize: cellSize,
                    row: row,
                    col: col,
                  ),
                ),
      ],
    );
  }

  Widget _buildCell(BoardCell cell, {bool isClearing = false, required double cellSize, required int row, required int col}) {
    // Find the vocabulary word for this cell
    VocabularyWord? word;
    if (cell.wordId != null) {
      try {
        word = vocabularyWords.firstWhere((w) => w.id == cell.wordId);
      } catch (e) {
        // Word not found, continue without word display
      }
    }

    Widget cellWidget = GestureDetector(
      onLongPress: word != null ? () async {
        // Haptic feedback
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 50);
        }
        
        // Play word reveal sound
        AudioService().playWordReveal();
        
        // Show word details
        _showWordDetails(context, word);
      } : null,
      child: Container(
        decoration: BoxDecoration(
          color: cell.color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: cell.color.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: word != null ? _buildCellContent(word, cellSize) : null,
      ),
    );

    if (isClearing && isAnimatingClear) {
      cellWidget = cellWidget
          .animate()
          .scale(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
          )
          .fadeOut(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
    } else {
      cellWidget = cellWidget
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 200))
          .scale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.elasticOut,
          );
    }

    return cellWidget;
  }

  Widget _buildCellContent(VocabularyWord word, double cellSize) {
    // Determine font size based on cell size and word length
    double fontSize = cellSize * 0.15;
    if (word.word.length > 8) {
      fontSize = cellSize * 0.1;
    } else if (word.word.length > 5) {
      fontSize = cellSize * 0.12;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          word.word,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDragPreview(double cellSize) {
    if (currentPiece == null || dragPosition == null) return const SizedBox();

    // Simplified drag preview without render box
    final gridCol = (dragPosition!.dx / (cellSize + 1)).floor();
    final gridRow = (dragPosition!.dy / (cellSize + 1)).floor();

    final canPlace = board.canPlacePiece(currentPiece!, gridRow, gridCol);

    return Positioned(
      left: gridCol * (cellSize + 1),
      top: gridRow * (cellSize + 1),
      child: IgnorePointer(
        child: _buildPiecePreview(
          currentPiece!,
          cellSize,
          canPlace,
        ),
      ),
    );
  }

  Widget _buildPiecePreview(Piece piece, double cellSize, bool canPlace) {
    return Opacity(
      opacity: canPlace ? 0.8 : 0.4,
      child: SizedBox(
        width: piece.width * (cellSize + 1),
        height: piece.height * (cellSize + 1),
        child: Stack(
          children: [
            for (int row = 0; row < piece.height; row++)
              for (int col = 0; col < piece.width; col++)
                if (piece.shape[row][col])
                  Positioned(
                    left: col * (cellSize + 1),
                    top: row * (cellSize + 1),
                    width: cellSize,
                    height: cellSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: canPlace ? piece.color : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: canPlace ? Colors.white24 : Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTouchOverlay(double cellSize) {
    return GestureDetector(
      onPanUpdate: onDragUpdate,
      onPanEnd: onDragEnd,
      child: Container(
        color: Colors.transparent,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: GameBoard.boardSize,
          ),
          itemCount: GameBoard.boardSize * GameBoard.boardSize,
          itemBuilder: (context, index) {
            final row = index ~/ GameBoard.boardSize;
            final col = index % GameBoard.boardSize;
            
            return GestureDetector(
              onTap: () => onCellTap(row, col),
              child: Container(
                color: Colors.transparent,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showWordDetails(BuildContext context, VocabularyWord word) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word.word,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (word.masteryLevel > 0)
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 16,
                        color: index < word.masteryLevel
                            ? Colors.amber
                            : Colors.grey[700],
                      ),
                    ),
                  ),
              ],
            ),
            if (word.pronunciation != null) ...[
              const SizedBox(height: 4),
              Text(
                word.pronunciation!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Translation',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              word.translation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            if (word.example != null) ...[
              const SizedBox(height: 16),
              Text(
                'Example',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                word.example!,
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 16,
                ),
              ),
              if (word.exampleTranslation != null) ...[
                const SizedBox(height: 4),
                Text(
                  word.exampleTranslation!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text('Level ${word.difficulty}'),
                  backgroundColor: Colors.grey[800],
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 8),
                if (word.successRate > 0)
                  Chip(
                    label: Text('${(word.successRate * 100).toInt()}% Success'),
                    backgroundColor: Colors.green[800],
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
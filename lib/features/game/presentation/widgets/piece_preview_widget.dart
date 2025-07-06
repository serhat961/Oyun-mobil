import 'package:flutter/material.dart';
import 'package:polyglot_puzzle/features/game/domain/entities/piece.dart';
import 'package:polyglot_puzzle/features/language_learning/domain/entities/vocabulary_word.dart';
import 'package:vibration/vibration.dart';

class PiecePreviewWidget extends StatelessWidget {
  final List<Piece> nextPieces;
  final List<VocabularyWord> vocabularyWords;
  final Function(Piece piece, Offset position) onPieceDragStarted;
  final Function() onRotatePiece;

  const PiecePreviewWidget({
    Key? key,
    required this.nextPieces,
    required this.vocabularyWords,
    required this.onPieceDragStarted,
    required this.onRotatePiece,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Pieces',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: nextPieces
                .take(3)
                .map((piece) => _buildPiecePreview(context, piece))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPiecePreview(BuildContext context, Piece piece) {
    final word = piece.wordId != null
        ? vocabularyWords.firstWhere(
            (w) => w.id == piece.wordId,
            orElse: () => vocabularyWords.first,
          )
        : null;

    return GestureDetector(
      onLongPress: () async {
        // Haptic feedback
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 50);
        }
        
        // Show word details
        if (word != null) {
          _showWordDetails(context, word);
        }
      },
      child: Draggable<Piece>(
        data: piece,
        onDragStarted: () async {
          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(duration: 20);
          }
        },
        onDraggableCanceled: (velocity, offset) {
          onPieceDragStarted(piece, offset);
        },
        feedback: Material(
          color: Colors.transparent,
          child: _buildPieceFeedback(piece),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildPieceItem(piece, word),
        ),
        child: _buildPieceItem(piece, word),
      ),
    );
  }

  Widget _buildPieceItem(Piece piece, VocabularyWord? word) {
    const cellSize = 20.0;
    final pieceWidth = piece.width * cellSize;
    final pieceHeight = piece.height * cellSize;

    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: pieceWidth,
            height: pieceHeight,
            child: Stack(
              children: [
                for (int row = 0; row < piece.height; row++)
                  for (int col = 0; col < piece.width; col++)
                    if (piece.shape[row][col])
                      Positioned(
                        left: col * cellSize,
                        top: row * cellSize,
                        child: Container(
                          width: cellSize - 1,
                          height: cellSize - 1,
                          decoration: BoxDecoration(
                            color: piece.color,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: piece.color.withOpacity(0.5),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          if (word != null) ...[
            const SizedBox(height: 8),
            Text(
              word.word,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPieceFeedback(Piece piece) {
    const cellSize = 30.0;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: piece.color.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SizedBox(
        width: piece.width * cellSize,
        height: piece.height * cellSize,
        child: Stack(
          children: [
            for (int row = 0; row < piece.height; row++)
              for (int col = 0; col < piece.width; col++)
                if (piece.shape[row][col])
                  Positioned(
                    left: col * cellSize,
                    top: row * cellSize,
                    child: Container(
                      width: cellSize - 1,
                      height: cellSize - 1,
                      decoration: BoxDecoration(
                        color: piece.color,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white24,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
          ],
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
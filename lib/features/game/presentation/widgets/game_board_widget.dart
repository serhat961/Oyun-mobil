import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:polyglot_puzzle/features/game/domain/entities/game_board.dart';
import 'package:polyglot_puzzle/features/game/domain/entities/piece.dart';

class GameBoardWidget extends StatelessWidget {
  final GameBoard board;
  final Piece? currentPiece;
  final Offset? dragPosition;
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
                ),
              ),
      ],
    );
  }

  Widget _buildCell(BoardCell cell, {bool isClearing = false}) {
    Widget cellWidget = Container(
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

  Widget _buildDragPreview(double cellSize) {
    if (currentPiece == null || dragPosition == null) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return const SizedBox();

    final localPosition = renderBox.globalToLocal(dragPosition!);
    final gridCol = (localPosition.dx / (cellSize + 1)).floor();
    final gridRow = (localPosition.dy / (cellSize + 1)).floor();

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
      },
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
}
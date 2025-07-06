import 'package:flutter/material.dart';

import '../../domain/piece.dart';
import '../../domain/position.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final double cellSize;
  final Color color;

  const PieceWidget({super.key, required this.piece, this.cellSize = 24, this.color = Colors.deepPurple});

  @override
  Widget build(BuildContext context) {
    final maxRow = piece.blocks.map((b) => b.row).reduce((a, b) => a > b ? a : b);
    final maxCol = piece.blocks.map((b) => b.col).reduce((a, b) => a > b ? a : b);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRow + 1, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxCol + 1, (col) {
            final filled = piece.blocks.contains(Position(row, col));
            return Container(
              width: cellSize,
              height: cellSize,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: filled ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        );
      }),
    );
  }
}
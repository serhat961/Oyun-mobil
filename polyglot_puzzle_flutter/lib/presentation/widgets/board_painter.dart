import 'package:flutter/material.dart';

import '../../domain/position.dart';
import '../../domain/game_board.dart';

class BoardPainter extends CustomPainter {
  final GameBoard board;
  final Set<Position> clearing;
  final double cellSize;

  BoardPainter({required this.board, required this.clearing, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int r = 0; r < GameBoard.size; r++) {
      for (int c = 0; c < GameBoard.size; c++) {
        final rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
        final pos = Position(r, c);
        Color color;
        if (clearing.contains(pos)) {
          color = Colors.orange;
        } else if (board.isFilled(pos)) {
          color = Colors.deepPurple;
        } else {
          color = Colors.grey.shade800;
        }
        paint.color = color;
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.board != board || oldDelegate.clearing != clearing;
  }
}
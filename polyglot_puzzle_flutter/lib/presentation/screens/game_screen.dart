import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/game_view_model.dart';
import '../../domain/game_board.dart';
import '../../domain/position.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Score: ${viewModel.score}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.reset,
          ),
        ],
      ),
      body: Center(
        child: _BoardView(board: viewModel.board),
      ),
    );
  }
}

class _BoardView extends StatelessWidget {
  final GameBoard board;
  const _BoardView({required this.board});

  @override
  Widget build(BuildContext context) {
    const double cellSize = 40.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(GameBoard.size, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(GameBoard.size, (col) {
            final filled = board.isFilled(Position(row, col));
            return Container(
              width: cellSize,
              height: cellSize,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: filled ? Colors.deepPurple : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      }),
    );
  }
}
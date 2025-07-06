import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../view_models/game_view_model.dart';
import '../../domain/game_board.dart';
import '../../domain/game_piece.dart';
import '../../domain/position.dart';
import '../widgets/piece_widget.dart';
import '../widgets/ad_banner.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    if (!viewModel.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double cellSize = 40.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BoardView(cellSize: cellSize),
              const SizedBox(height: 24),
              _PieceBar(cellSize: cellSize * 0.8),
              const SizedBox(height: 32),
              const AdBanner(),
            ],
          );
        },
      ),
    );
  }
}

class _BoardView extends StatelessWidget {
  final double cellSize;
  const _BoardView({required this.cellSize});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final board = viewModel.board;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(GameBoard.size, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(GameBoard.size, (col) {
            final origin = Position(row, col);
            final filled = board.isFilled(origin);
            return DragTarget<GamePiece>(
              onWillAccept: (piece) {
                if (piece == null) return false;
                return viewModel.canPlaceCurrentPiece(origin);
              },
              onAccept: (_) {
                viewModel.placeCurrentPiece(origin);
                HapticFeedback.mediumImpact();
              },
              builder: (context, candidate, rejected) {
                final isHovering = candidate.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: cellSize,
                  height: cellSize,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: filled
                        ? Colors.deepPurple
                        : isHovering
                            ? Colors.deepPurple.withOpacity(0.3)
                            : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            );
          }),
        );
      }),
    );
  }
}

class _PieceBar extends StatelessWidget {
  final double cellSize;
  const _PieceBar({required this.cellSize});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final current = viewModel.currentPiece;
    final next = viewModel.nextPieces;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LongPressDraggable<GamePiece>(
          data: current,
          feedback: Material(
            color: Colors.transparent,
            child: PieceWidget(piece: current.shape, cellSize: cellSize, color: Colors.deepPurpleAccent),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: PieceWidget(piece: current.shape, cellSize: cellSize),
          ),
          onDragEnd: (details) {
            if (!details.wasAccepted) {
              HapticFeedback.heavyImpact();
            }
          },
          child: Tooltip(
            message: '${current.word.term} = ${current.word.translation}',
            child: PieceWidget(piece: current.shape, cellSize: cellSize),
          ),
        ),
        const SizedBox(width: 32),
        // Preview next 3 pieces
        ...next.map((gp) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Tooltip(
                message: '${gp.word.term} = ${gp.word.translation}',
                child: PieceWidget(piece: gp.shape, cellSize: cellSize * 0.7, color: Colors.blueGrey),
              ),
            )),
      ],
    );
  }
}
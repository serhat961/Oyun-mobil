import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../view_models/game_view_model.dart';
import '../../domain/game_board.dart';
import '../../domain/game_piece.dart';
import '../../domain/position.dart';
import '../widgets/piece_widget.dart';
import '../widgets/ad_banner.dart';
import '../screens/store_screen.dart';
import '../../monetization/hint_manager.dart';
import '../../monetization/ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../domain/vocab_word.dart';
import '../../data/translation_service.dart';

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
          ValueListenableBuilder<int>(
            valueListenable: HintManager.instance.hints,
            builder: (context, hints, _) {
              return IconButton(
                icon: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    const Icon(Icons.lightbulb_outline),
                    if (hints > 0)
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.amber,
                        child: Text('$hints', style: const TextStyle(fontSize: 10, color: Colors.black)),
                      ),
                  ],
                ),
                onPressed: () async {
                  if (HintManager.instance.hints.value > 0) {
                    final consumed = await HintManager.instance.consumeHint();
                    if (consumed) {
                      await viewModel.useHint();
                    }
                  } else {
                    final rewarded = await AdManager.instance.loadRewardedAd();
                    if (rewarded != null) {
                      rewarded.fullScreenContentCallback = FullScreenContentCallback(
                        onAdDismissedFullScreenContent: (ad) => ad.dispose(),
                      );
                      rewarded.setImmersiveMode(true);
                      rewarded.show(onUserEarnedReward: (ad, reward) async {
                        await HintManager.instance.addHints(1);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad not available')));
                    }
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StoreScreen()));
            },
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

Future<void> _showWordDetails(BuildContext context, VocabWord word) async {
  showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return FutureBuilder<String?>(
          future: TranslationService.instance.explanation(text: word.term, targetLang: 'Turkish'),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
            }
            final explanation = snap.data ?? 'No explanation available.';
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${word.term} = ${word.translation}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(explanation),
                ],
              ),
            );
          },
        );
      });
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
            final clearing = viewModel.clearingPositions.contains(origin);
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
                    color: clearing
                        ? Colors.orange
                        : filled
                            ? Colors.deepPurple
                            : isHovering
                                ? Colors.deepPurple.withOpacity(0.3)
                                : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  // additional animation: scale
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
        // rotation buttons
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.rotate_left),
              onPressed: () => viewModel.rotateCurrentPieceCCW(),
            ),
            IconButton(
              icon: const Icon(Icons.rotate_right),
              onPressed: () => viewModel.rotateCurrentPieceCW(),
            ),
          ],
        ),
        const SizedBox(width: 8),
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
          child: GestureDetector(
            onDoubleTap: () => _showWordDetails(context, current.word),
            child: Tooltip(
              message: '${current.word.term} = ${current.word.translation}',
              child: PieceWidget(piece: current.shape, cellSize: cellSize),
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Preview next 3 pieces
        ...next.map((gp) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onDoubleTap: () => _showWordDetails(context, gp.word),
                child: Tooltip(
                  message: '${gp.word.term} = ${gp.word.translation}',
                  child: PieceWidget(piece: gp.shape, cellSize: cellSize * 0.7, color: Colors.blueGrey),
                ),
              ),
            )),
      ],
    );
  }
}
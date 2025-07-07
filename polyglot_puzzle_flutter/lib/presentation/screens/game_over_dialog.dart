import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int best;
  final VoidCallback onRestart;
  const GameOverDialog({super.key, required this.score, required this.best, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).score),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Score: $score'),
          Text('Best: $best'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRestart,
          child: const Text('Restart'),
        ),
      ],
    );
  }
}
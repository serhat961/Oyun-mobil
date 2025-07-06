import 'dart:math';

import 'piece.dart';

class PieceGenerator {
  final Random _rand;

  PieceGenerator({int? seed}) : _rand = Random(seed);

  Piece next() {
    final templates = Piece.allTemplates;
    return templates[_rand.nextInt(templates.length)];
  }
}
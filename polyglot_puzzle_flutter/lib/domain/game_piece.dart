import 'piece.dart';
import 'vocab_word.dart';

class GamePiece {
  final Piece shape;
  final VocabWord word;

  const GamePiece({required this.shape, required this.word});
}
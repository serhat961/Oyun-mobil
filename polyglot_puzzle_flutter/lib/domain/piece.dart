import 'position.dart';

enum TetrominoType { I, O, T, S, Z, J, L }

class Piece {
  final TetrominoType type;
  final List<Position> blocks; // relative positions

  const Piece(this.type, this.blocks);

  static List<Piece> get allTemplates => [
        Piece(TetrominoType.I, [
          Position(0, 0),
          Position(0, 1),
          Position(0, 2),
          Position(0, 3),
        ]),
        Piece(TetrominoType.O, [
          Position(0, 0),
          Position(0, 1),
          Position(1, 0),
          Position(1, 1),
        ]),
        Piece(TetrominoType.T, [
          Position(0, 0),
          Position(0, 1),
          Position(0, 2),
          Position(1, 1),
        ]),
        Piece(TetrominoType.S, [
          Position(0, 1),
          Position(0, 2),
          Position(1, 0),
          Position(1, 1),
        ]),
        Piece(TetrominoType.Z, [
          Position(0, 0),
          Position(0, 1),
          Position(1, 1),
          Position(1, 2),
        ]),
        Piece(TetrominoType.J, [
          Position(0, 0),
          Position(1, 0),
          Position(1, 1),
          Position(1, 2),
        ]),
        Piece(TetrominoType.L, [
          Position(0, 2),
          Position(1, 0),
          Position(1, 1),
          Position(1, 2),
        ]),
      ];
}

class PiecePlacement {
  final Piece piece;
  final Position origin;

  PiecePlacement(this.piece, this.origin);

  Iterable<Position> absoluteBlocks() =>
      piece.blocks.map((relative) => origin + relative);
}
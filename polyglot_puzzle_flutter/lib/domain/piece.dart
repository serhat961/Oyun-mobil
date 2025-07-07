import 'position.dart';

enum TetrominoType { I, O, T, S, Z, J, L }

class Piece {
  final TetrominoType type;
  final List<Position> blocks; // relative positions

  const Piece(this.type, this.blocks);

  Piece rotatedCW() {
    // (row, col) -> (col, maxRow - row)
    final maxRow = blocks.map((b) => b.row).reduce((a, b) => a > b ? a : b);
    final rotated = blocks
        .map((b) => Position(b.col, maxRow - b.row))
        .toList(growable: false);
    // normalize to top-left origin
    final minRow = rotated.map((b) => b.row).reduce((a, b) => a < b ? a : b);
    final minCol = rotated.map((b) => b.col).reduce((a, b) => a < b ? a : b);
    return Piece(type,
        rotated.map((p) => Position(p.row - minRow, p.col - minCol)).toList());
  }

  Piece rotatedCCW() {
    // (row, col) -> (maxCol - col, row)
    final maxCol = blocks.map((b) => b.col).reduce((a, b) => a > b ? a : b);
    final rotated = blocks
        .map((b) => Position(maxCol - b.col, b.row))
        .toList(growable: false);
    final minRow = rotated.map((b) => b.row).reduce((a, b) => a < b ? a : b);
    final minCol = rotated.map((b) => b.col).reduce((a, b) => a < b ? a : b);
    return Piece(type,
        rotated.map((p) => Position(p.row - minRow, p.col - minCol)).toList());
  }

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
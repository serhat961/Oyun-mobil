import 'package:collection/collection.dart';

import 'piece.dart';
import 'position.dart';

class GameBoard {
  static const int size = 8;
  final List<List<bool>> _cells; // true if filled

  const GameBoard._(this._cells);

  factory GameBoard.empty() => GameBoard._(
        List.generate(size, (_) => List.filled(size, false, growable: false),
            growable: false),
      );

  bool isFilled(Position pos) => _cells[pos.row][pos.col];

  bool _inBounds(Position pos) =>
      pos.row >= 0 && pos.row < size && pos.col >= 0 && pos.col < size;

  bool canPlace(PiecePlacement placement) {
    for (final block in placement.absoluteBlocks()) {
      if (!_inBounds(block) || isFilled(block)) return false;
    }
    return true;
  }

  GameBoard place(PiecePlacement placement) {
    final newCells = _deepCopy();
    for (final block in placement.absoluteBlocks()) {
      newCells[block.row][block.col] = true;
    }
    return GameBoard._(newCells);
  }

  List<int> detectClears() {
    final clearedRows = <int>[];
    final clearedCols = <int>[];

    for (var i = 0; i < size; i++) {
      if (_cells[i].every((cell) => cell)) clearedRows.add(i);
      if (_cells.every((row) => row[i])) clearedCols.add(i);
    }

    return [...clearedRows, ...clearedCols];
  }

  GameBoard clearLines(List<int> lines) {
    var newCells = _deepCopy();
    for (final row in lines.where((l) => l < size)) {
      newCells[row] = List.filled(size, false);
    }
    for (final col in lines.where((l) => l >= size)) {
      final c = col - size;
      for (var r = 0; r < size; r++) {
        newCells[r][c] = false;
      }
    }
    return GameBoard._(newCells);
  }

  List<List<bool>> _deepCopy() =>
      _cells.map((row) => row.toList(growable: false)).toList(growable: false);

  @override
  String toString() => _cells
      .map((row) => row.map((c) => c ? '■' : '·').join())
      .join('\n');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameBoard && const DeepCollectionEquality().equals(_cells, other._cells);

  @override
  int get hashCode => const DeepCollectionEquality().hash(_cells);
}
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  Position operator +(Position other) => Position(row + other.row, col + other.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);
}
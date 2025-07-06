import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PieceType { I, O, T, S, Z, J, L }

class Piece extends Equatable {
  final String id;
  final PieceType type;
  final List<List<bool>> shape;
  final Color color;
  final int rotation;
  final String? wordId;
  final DateTime createdAt;

  const Piece({
    required this.id,
    required this.type,
    required this.shape,
    required this.color,
    this.rotation = 0,
    this.wordId,
    required this.createdAt,
  });

  static final Map<PieceType, List<List<List<bool>>>> pieceShapes = {
    PieceType.I: [
      // 0 degrees
      [
        [true, true, true, true],
      ],
      // 90 degrees
      [
        [true],
        [true],
        [true],
        [true],
      ],
    ],
    PieceType.O: [
      // All rotations same
      [
        [true, true],
        [true, true],
      ],
    ],
    PieceType.T: [
      // 0 degrees
      [
        [false, true, false],
        [true, true, true],
      ],
      // 90 degrees
      [
        [true, false],
        [true, true],
        [true, false],
      ],
      // 180 degrees
      [
        [true, true, true],
        [false, true, false],
      ],
      // 270 degrees
      [
        [false, true],
        [true, true],
        [false, true],
      ],
    ],
    PieceType.S: [
      // 0 degrees
      [
        [false, true, true],
        [true, true, false],
      ],
      // 90 degrees
      [
        [true, false],
        [true, true],
        [false, true],
      ],
    ],
    PieceType.Z: [
      // 0 degrees
      [
        [true, true, false],
        [false, true, true],
      ],
      // 90 degrees
      [
        [false, true],
        [true, true],
        [true, false],
      ],
    ],
    PieceType.J: [
      // 0 degrees
      [
        [true, false, false],
        [true, true, true],
      ],
      // 90 degrees
      [
        [true, true],
        [true, false],
        [true, false],
      ],
      // 180 degrees
      [
        [true, true, true],
        [false, false, true],
      ],
      // 270 degrees
      [
        [false, true],
        [false, true],
        [true, true],
      ],
    ],
    PieceType.L: [
      // 0 degrees
      [
        [false, false, true],
        [true, true, true],
      ],
      // 90 degrees
      [
        [true, false],
        [true, false],
        [true, true],
      ],
      // 180 degrees
      [
        [true, true, true],
        [true, false, false],
      ],
      // 270 degrees
      [
        [true, true],
        [false, true],
        [false, true],
      ],
    ],
  };

  static final Map<PieceType, Color> pieceColors = {
    PieceType.I: Colors.cyan,
    PieceType.O: Colors.yellow,
    PieceType.T: Colors.purple,
    PieceType.S: Colors.green,
    PieceType.Z: Colors.red,
    PieceType.J: Colors.blue,
    PieceType.L: Colors.orange,
  };

  int get width => shape[0].length;
  int get height => shape.length;

  Piece rotate() {
    final shapes = pieceShapes[type]!;
    final nextRotation = (rotation + 1) % shapes.length;
    
    return copyWith(
      rotation: nextRotation,
      shape: shapes[nextRotation],
    );
  }

  Piece copyWith({
    String? id,
    PieceType? type,
    List<List<bool>>? shape,
    Color? color,
    int? rotation,
    String? wordId,
    DateTime? createdAt,
  }) {
    return Piece(
      id: id ?? this.id,
      type: type ?? this.type,
      shape: shape ?? this.shape,
      color: color ?? this.color,
      rotation: rotation ?? this.rotation,
      wordId: wordId ?? this.wordId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, type, shape, color, rotation, wordId, createdAt];
}
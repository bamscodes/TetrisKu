import 'dart:math';
import 'package:flutter/material.dart';

enum PieceType { I, O, T, S, Z, J, L }

class Tetromino {
  final PieceType type;
  List<Offset> blocks;
  int rotation;

  Tetromino(this.type, {this.rotation = 0, List<Offset>? blocks})
      : blocks = blocks ?? _initialShape(type);

  Tetromino copyWith({List<Offset>? blocks, int? rotation}) {
    return Tetromino(
      type,
      rotation: rotation ?? this.rotation,
      blocks: blocks ?? this.blocks,
    );
  }

  static List<Offset> _initialShape(PieceType t) {
    switch (t) {
      case PieceType.I:
        return [
          Offset(-1.0, 0.0),
          Offset(0.0, 0.0),
          Offset(1.0, 0.0),
          Offset(2.0, 0.0),
        ];
      case PieceType.O:
        return [
          Offset(0.0, 0.0),
          Offset(1.0, 0.0),
          Offset(0.0, 1.0),
          Offset(1.0, 1.0),
        ];
      case PieceType.T:
        return [
          Offset(-1.0, 0.0),
          Offset(0.0, 0.0),
          Offset(1.0, 0.0),
          Offset(0.0, 1.0),
        ];
      case PieceType.S:
        return [
          Offset(0.0, 0.0),
          Offset(1.0, 0.0),
          Offset(-1.0, 1.0),
          Offset(0.0, 1.0),
        ];
      case PieceType.Z:
        return [
          Offset(-1.0, 0.0),
          Offset(0.0, 0.0),
          Offset(0.0, 1.0),
          Offset(1.0, 1.0),
        ];
      case PieceType.J:
        return [
          Offset(-1.0, 0.0),
          Offset(-1.0, 1.0),
          Offset(0.0, 0.0),
          Offset(1.0, 0.0),
        ];
      case PieceType.L:
        return [
          Offset(-1.0, 0.0),
          Offset(0.0, 0.0),
          Offset(1.0, 0.0),
          Offset(1.0, 1.0),
        ];
    }
  }

  static Color colorOf(PieceType t) {
    switch (t) {
      case PieceType.I:
        return const Color(0xFF00E5FF); // Cyan neon
      case PieceType.O:
        return const Color(0xFFFFEA00); // Kuning neon
      case PieceType.T:
        return const Color(0xFFD500F9); // Ungu neon
      case PieceType.S:
        return const Color(0xFF76FF03); // Hijau neon
      case PieceType.Z:
        return const Color(0xFFFF1744); // Merah neon
      case PieceType.J:
        return const Color(0xFF2979FF); // Biru neon
      case PieceType.L:
        return const Color(0xFFFF9100); // Oranye neon
    }
  }

  Tetromino rotatedCW() {
    final rotated = blocks.map((b) => Offset(b.dy, -b.dx)).toList();
    return copyWith(blocks: rotated, rotation: (rotation + 1) % 4);
  }

  static final List<Offset> kicks = [
    Offset(0.0, 0.0),
    Offset(1.0, 0.0),
    Offset(-1.0, 0.0),
    Offset(0.0, 1.0),
    Offset(0.0, -1.0),
  ];
}
/// 7-bag randomizer (standar Tetris modern).
/// Menjamin setiap 7 piece, pemain mendapat semua jenis tepat sekali.
class PieceBag {
  final Random _rng;
  final List<PieceType> _bag = [];

  PieceBag(this._rng);

  PieceType next() {
    if (_bag.isEmpty) {
      _bag.addAll(PieceType.values);
      _bag.shuffle(_rng);
    }
    return _bag.removeLast();
  }
}

/// Legacy helper — tetap ada agar kode lama tidak error,
/// tapi sekarang TetrisGame menggunakan PieceBag.
PieceType randomPiece(Random rng) {
  final values = PieceType.values;
  return values[rng.nextInt(values.length)];
}

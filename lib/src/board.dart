import 'package:flutter/material.dart';
import 'tetromino.dart';

class Board {
  final int width;
  final int height;
  late List<List<Color?>> cells;

  Board({this.width = 10, this.height = 20}) {
    cells = List.generate(height, (_) => List<Color?>.filled(width, null));
  }

  bool inBounds(int x, int y) => x >= 0 && x < width && y >= 0 && y < height;

  bool isCellEmpty(int x, int y) => inBounds(x, y) && cells[y][x] == null;

  bool canPlace(Tetromino piece, Offset origin) {
    for (final b in piece.blocks) {
      final x = origin.dx + b.dx;
      final y = origin.dy + b.dy;
      if (!inBounds(x.toInt(), y.toInt()) || cells[y.toInt()][x.toInt()] != null) {
        return false;
      }
    }
    return true;
  }

  void lockPiece(Tetromino piece, Offset origin) {
    for (final b in piece.blocks) {
      final x = origin.dx + b.dx;
      final y = origin.dy + b.dy;
      if (inBounds(x.toInt(), y.toInt())) {
        cells[y.toInt()][x.toInt()] = Tetromino.colorOf(piece.type);
      }
    }
  }

  int clearLines() {
    int cleared = 0;
    int y = height - 1;
    while (y >= 0) {
      if (cells[y].every((c) => c != null)) {
        cleared++;
        cells.removeAt(y);
        cells.insert(0, List<Color?>.filled(width, null));
      } else {
        y--;
      }
    }
    return cleared;
  }

  // ✅ New: returns indices of fully filled rows (for flash animation)
  List<int> getFilledRows() {
    final filled = <int>[];
    for (int y = 0; y < height; y++) {
      if (cells[y].every((c) => c != null)) {
        filled.add(y);
      }
    }
    return filled;
  }

  // Optional helpers (useful later)
  void reset() {
    cells = List.generate(height, (_) => List<Color?>.filled(width, null));
  }

  bool isTopOccupied() {
    return cells.first.any((c) => c != null);
  }
}
import 'package:flutter/material.dart';
import '../tetromino.dart';

/// Widget yang menampilkan preview blok Tetromino berikutnya.
/// Menggambar blok dalam grid kecil 4x4 tanpa efek berat.
class NextPiecePreview extends StatelessWidget {
  final Tetromino piece;
  const NextPiecePreview({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Tetromino.colorOf(piece.type).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CustomPaint(
          painter: _NextPiecePainter(piece),
        ),
      ),
    );
  }
}

class _NextPiecePainter extends CustomPainter {
  final Tetromino piece;
  _NextPiecePainter(this.piece);

  @override
  void paint(Canvas canvas, Size size) {
    final blocks = piece.blocks;
    final color = Tetromino.colorOf(piece.type);

    // Hitung bounding box dari blok
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final b in blocks) {
      if (b.dx < minX) minX = b.dx;
      if (b.dx > maxX) maxX = b.dx;
      if (b.dy < minY) minY = b.dy;
      if (b.dy > maxY) maxY = b.dy;
    }

    final cols = (maxX - minX + 1).toInt();
    final rows = (maxY - minY + 1).toInt();

    final cellSize = (size.shortestSide / 4.0);
    final totalW = cols * cellSize;
    final totalH = rows * cellSize;

    final offsetX = (size.width - totalW) / 2;
    final offsetY = (size.height - totalH) / 2;

    final fillPaint = Paint()..color = color;
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);

    for (final b in blocks) {
      final x = (b.dx - minX) * cellSize + offsetX;
      final y = (b.dy - minY) * cellSize + offsetY;
      final rect = Rect.fromLTWH(x, y, cellSize, cellSize);
      final rrect = RRect.fromRectAndRadius(
        rect.deflate(cellSize * 0.08),
        Radius.circular(cellSize * 0.18),
      );

      // Fill
      canvas.drawRRect(rrect, fillPaint);

      // Simple highlight
      final hRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + cellSize * 0.12, y + cellSize * 0.12, cellSize * 0.3, cellSize * 0.2),
        Radius.circular(cellSize * 0.1),
      );
      canvas.drawRRect(hRect, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NextPiecePainter oldDelegate) {
    return oldDelegate.piece.type != piece.type;
  }
}

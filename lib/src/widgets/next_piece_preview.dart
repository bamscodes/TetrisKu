import 'package:flutter/material.dart';
import '../tetromino.dart';

/// Widget yang menampilkan preview blok Tetromino berikutnya.
/// Menggambar blok dalam grid kecil 4x4 dengan efek neon glow.
class NextPiecePreview extends StatelessWidget {
  final Tetromino piece;
  const NextPiecePreview({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Tetromino.colorOf(piece.type).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Tetromino.colorOf(piece.type).withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
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

    // Ukuran sel berdasarkan area yang tersedia
    final cellSize = (size.shortestSide / 4.0); // max 4 grid
    final totalW = cols * cellSize;
    final totalH = rows * cellSize;

    // Posisi center
    final offsetX = (size.width - totalW) / 2;
    final offsetY = (size.height - totalH) / 2;

    for (final b in blocks) {
      final x = (b.dx - minX) * cellSize + offsetX;
      final y = (b.dy - minY) * cellSize + offsetY;
      final rect = Rect.fromLTWH(x, y, cellSize, cellSize);
      final rrect = RRect.fromRectAndRadius(
        rect.deflate(cellSize * 0.08),
        Radius.circular(cellSize * 0.18),
      );

      // Glow
      final glow = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);
      canvas.drawRRect(rrect, glow);

      // Shadow
      final shadow = Paint()..color = Colors.black.withValues(alpha: 0.3);
      canvas.drawRRect(rrect.shift(const Offset(1.5, 1.5)), shadow);

      // Fill gradient
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.75)],
      );
      final fill = Paint()..shader = gradient.createShader(rect);
      canvas.drawRRect(rrect, fill);

      // Highlight
      final highlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawRRect(rrect.shift(const Offset(-1.0, -1.0)), highlight);
    }
  }

  @override
  bool shouldRepaint(covariant _NextPiecePainter oldDelegate) {
    return oldDelegate.piece.type != piece.type;
  }
}

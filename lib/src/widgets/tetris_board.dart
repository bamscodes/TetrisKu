import 'dart:math';
import 'package:flutter/material.dart';
import '../tetris_game.dart';
import '../tetromino.dart';

class TetrisBoard extends StatefulWidget {
  final TetrisGame game;
  const TetrisBoard({super.key, required this.game});

  @override
  State<TetrisBoard> createState() => _TetrisBoardState();
}

class _TetrisBoardState extends State<TetrisBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Only rebuild during flash animation, not constantly
    _flashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {}); // Final rebuild when flash ends
      }
    });

    widget.game.addListener(_onGameUpdate);
  }

  int _lastFlashCount = 0;

  void _onGameUpdate() {
    final flashCount = widget.game.flashingRows.length;
    if (flashCount > 0 && flashCount != _lastFlashCount) {
      _flashController.forward(from: 0);
    }
    _lastFlashCount = flashCount;
    if (mounted) setState(() {}); // Single rebuild per throttled notification
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BoardPainter(
          widget.game,
          flashPhase: _flashController.value,
        ),
        willChange: true,
      ),
    );
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameUpdate);
    _flashController.dispose();
    super.dispose();
  }
}

class _BoardPainter extends CustomPainter {
  final TetrisGame game;
  final double flashPhase;

  // ── STATIC CACHED PAINTS ── (created once, reused forever)
  static final Paint _bgPaint = Paint()..color = const Color(0xFF080820);
  static final Paint _gridPaint = Paint()
    ..color = const Color(0x0FFFFFFF)
    ..strokeWidth = 0.5;
  static final Paint _shadowPaint = Paint()..color = const Color(0x40000000);
  static final Paint _highlightPaint = Paint()..color = const Color(0x33FFFFFF);
  static final Paint _cellPaint = Paint();
  static final Paint _ghostPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Paint _flashPaint = Paint();

  _BoardPainter(this.game, {this.flashPhase = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = game.board.width;
    final h = game.board.height;
    final cellW = size.width / w;
    final cellH = size.height / h;

    // Background
    canvas.drawRect(Offset.zero & size, _bgPaint);

    // Grid
    for (int x = 1; x < w; x++) {
      final dx = x * cellW;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), _gridPaint);
    }
    for (int y = 1; y < h; y++) {
      final dy = y * cellH;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), _gridPaint);
    }

    // Flash blink
    final blinkAlpha = game.flashingRows.isNotEmpty
        ? (sin(flashPhase * 3 * pi).abs())
        : 0.0;

    // Locked cells
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final color = game.board.cells[y][x];
        if (color == null) continue;

        final rect = Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH);
        _drawCell(canvas, rect, color);

        if (game.flashingRows.contains(y)) {
          final rrect = RRect.fromRectAndRadius(
            rect.deflate(rect.width * 0.08),
            Radius.circular(rect.width * 0.18),
          );
          _flashPaint.color = Color.fromRGBO(255, 255, 255, blinkAlpha * 0.85);
          canvas.drawRRect(rrect, _flashPaint);
        }
      }
    }

    // Ghost piece
    if (game.ghost != null) {
      _ghostPaint.color = Tetromino.colorOf(game.current.type).withValues(alpha: 0.3);
      for (final b in game.ghost!.blocks) {
        final gx = game.ghostOrigin.dx + b.dx;
        final gy = game.ghostOrigin.dy + b.dy;
        final rect = Rect.fromLTWH(gx * cellW, gy * cellH, cellW, cellH);
        final rrect = RRect.fromRectAndRadius(
          rect.deflate(rect.width * 0.1),
          Radius.circular(rect.width * 0.2),
        );
        canvas.drawRRect(rrect, _ghostPaint);
      }
    }

    // Current piece
    for (final b in game.current.blocks) {
      final x = game.origin.dx + b.dx;
      final y = game.origin.dy + b.dy;
      final rect = Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH);
      _drawCell(canvas, rect, Tetromino.colorOf(game.current.type));
    }
  }

  void _drawCell(Canvas canvas, Rect rect, Color color) {
    final shrinkWidth = rect.width * 0.08;
    final deflatedRect = rect.deflate(shrinkWidth);
    final radius = Radius.circular(rect.width * 0.18);
    final rrect = RRect.fromRectAndRadius(deflatedRect, radius);

    // Draw Shadow (using fast translate on rect instead of rrect.shift with new Offset)
    final shadowRRect = RRect.fromRectAndRadius(
      deflatedRect.translate(1.0, 1.0),
      radius,
    );
    canvas.drawRRect(shadowRRect, _shadowPaint);

    // Draw Main Fill
    _cellPaint.color = color;
    canvas.drawRRect(rrect, _cellPaint);

    // Draw Highlight (using fast translate on rect instead of rrect.shift with new Offset)
    final highlightRRect = RRect.fromRectAndRadius(
      deflatedRect.translate(-0.5, -0.5),
      radius,
    );
    canvas.drawRRect(highlightRRect, _highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}

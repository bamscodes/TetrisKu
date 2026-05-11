import 'dart:math';
import 'package:flutter/material.dart';
import '../tetris_game.dart';
import '../tetromino.dart';

class Particle {
  Offset position;
  Offset velocity;
  double life; // 1.0 → 0.0
  final Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    this.life = 1.0,
  });
}

class TetrisBoard extends StatefulWidget {
  final TetrisGame game;
  const TetrisBoard({super.key, required this.game});

  @override
  State<TetrisBoard> createState() => _TetrisBoardState();
}

class _TetrisBoardState extends State<TetrisBoard>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _flashController;
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();

    _particleController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addListener(() {
          setState(() {
            _updateParticles();
          });
        });

    // Blink animation: 0→1→0→1→0 (3x blink dalam 500ms)
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
      setState(() {});
    });

    widget.game.addListener(_onGameUpdate);
  }

  void _onGameUpdate() {
    if (widget.game.flashingRows.isNotEmpty) {
      _spawnParticles(widget.game.flashingRows);
      _particleController.forward(from: 0);
      _flashController.forward(from: 0);
    }
    setState(() {});
  }

  void _spawnParticles(List<int> rows) {
    final w = widget.game.board.width;
    final h = widget.game.board.height;

    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(200, 400);
    final cellW = size.width / w;
    final cellH = size.height / h;

    particles.clear();
    final rng = Random();

    for (final y in rows) {
      for (int x = 0; x < w; x++) {
        final color = widget.game.board.cells[y][x];
        if (color != null) {
          // Lebih banyak partikel per sel untuk efek lebih dramatis
          for (int i = 0; i < 10; i++) {
            particles.add(
              Particle(
                position: Offset(x * cellW + cellW / 2, y * cellH + cellH / 2),
                velocity: Offset(
                  (rng.nextDouble() - 0.5) * 8,
                  (rng.nextDouble() - 0.5) * 8,
                ),
                color: color,
              ),
            );
          }
        }
      }
    }
  }

  void _updateParticles() {
    for (final p in particles) {
      p.position += p.velocity;
      p.life -= 0.025;
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BoardPainter(
        widget.game,
        particles: particles,
        flashPhase: _flashController.value,
      ),
      willChange: true,
    );
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameUpdate);
    _particleController.dispose();
    _flashController.dispose();
    super.dispose();
  }
}

class _BoardPainter extends CustomPainter {
  final TetrisGame game;
  final List<Particle> particles;
  final double flashPhase;

  _BoardPainter(this.game, {required this.particles, this.flashPhase = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = game.board.width;
    final h = game.board.height;
    final cellW = size.width / w;
    final cellH = size.height / h;

    // Background gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF1A237E),
          const Color(0xFF0D47A1),
          const Color(0xFF000000),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      bgPaint,
    );

    // Grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (int x = 1; x < w; x++) {
      final dx = x * cellW;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }
    for (int y = 1; y < h; y++) {
      final dy = y * cellH;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    // Hitung intensitas blink (sin wave: 3x blink dalam 500ms)
    // sin(phase * 3π) → 0→1→0→1→0→1→0
    final blinkAlpha = game.flashingRows.isNotEmpty
        ? (sin(flashPhase * 3 * pi).abs())
        : 0.0;

    // Locked cells
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final color = game.board.cells[y][x];
        if (color == null) continue;

        final rect = Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH);

        if (game.flashingRows.contains(y)) {
          // Baris yang sedang flash: gambar sel normal lalu overlay putih berkedip
          _drawCell(canvas, rect, color);
          final flashRect = RRect.fromRectAndRadius(
            rect.deflate(rect.width * 0.08),
            Radius.circular(rect.width * 0.18),
          );
          final flashPaint = Paint()
            ..color = Colors.white.withValues(alpha: blinkAlpha * 0.85)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
          canvas.drawRRect(flashRect, flashPaint);
        } else {
          _drawCell(canvas, rect, color);
        }
      }
    }

    // Partikel efek clear — ukuran lebih besar
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0));
      canvas.drawCircle(p.position, 3.0, paint);

      // Glow di sekitar partikel
      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: (p.life * 0.4).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(p.position, 4.0, glowPaint);
    }

    // Ghost piece
    if (game.ghost != null) {
      for (final b in game.ghost!.blocks) {
        final gx = game.ghostOrigin.dx + b.dx;
        final gy = game.ghostOrigin.dy + b.dy;
        final rect = Rect.fromLTWH(gx * cellW, gy * cellH, cellW, cellH);
        final rrect = RRect.fromRectAndRadius(
          rect.deflate(rect.width * 0.1),
          Radius.circular(rect.width * 0.2),
        );
        final ghostPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Tetromino.colorOf(game.current.type).withValues(alpha: 0.4);
        canvas.drawRRect(rrect, ghostPaint);
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
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(rect.width * 0.08),
      Radius.circular(rect.width * 0.18),
    );

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.75)],
    );
    final fill = Paint()..shader = gradient.createShader(rect);

    final glow = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);

    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.3);

    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawRRect(rrect, glow);
    canvas.drawRRect(rrect.shift(const Offset(1.5, 1.5)), shadow);
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect.shift(const Offset(-1.0, -1.0)), highlight);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}

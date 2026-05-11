import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../music_manager.dart';
import '../game/tetris_home.dart';
import '../services/high_score_service.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rng = Random();
  final List<_FallingBlock> _blocks = [];

  @override
  void initState() {
    super.initState();
    MusicManager.reset();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..addListener(() {
            setState(() {
              for (var b in _blocks) {
                b.y += b.speed;
                if (b.y > MediaQuery.of(context).size.height) {
                  b.reset(_rng, MediaQuery.of(context).size);
                }
              }
            });
          })
          ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      for (int i = 0; i < 25; i++) {
        _blocks.add(_FallingBlock.random(_rng, screenSize));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari provider — otomatis rebuild saat berubah
    final hs = HighScoreProvider.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient + balok jatuh
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          CustomPaint(
            size: Size.infinite,
            painter: _BackgroundPainter(_blocks),
          ),

          // Konten menu
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Judul dengan efek neon glow
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "TETRISKU",
                    style: GoogleFonts.orbitron(
                      fontSize: Theme.of(context).textTheme.displaySmall?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                      shadows: const [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.cyanAccent,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // High score tampil di bawah judul
                Text(
                  "High Score: ${hs.highScore}",
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.orangeAccent),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.lightGreenAccent,
                      size: 22,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.greenAccent,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Highest Level: ${hs.highLevel}",
                      style: const TextStyle(
                        color: Colors.lightGreenAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.greenAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                _NeonButton(
                  icon: Icons.play_arrow,
                  label: "PLAY GAME",
                  color: Colors.deepOrangeAccent,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TetrisHome()),
                    );
                    // Tidak perlu .then() — HighScoreProvider otomatis
                    // meng-update semua widget saat data berubah.
                  },
                ),
                const SizedBox(height: 24),

                _NeonButton(
                  icon: Icons.help_outline,
                  label: "HOW TO PLAY",
                  color: Colors.amberAccent,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.black.withValues(alpha: 0.85),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.deepPurple, Colors.black],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sports_esports,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "How to Play",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "⬅️ ➡️  Geser balok",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      "⬆️  Putar balok",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      "⬇️  Soft Drop",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      "␣ / Double Tap  Hard Drop",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text("OK, Mengerti"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                _NeonButton(
                  icon: Icons.exit_to_app,
                  label: "EXIT",
                  color: Colors.redAccent,
                  onPressed: () => SystemNavigator.pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// WIDGETS
/// =======================

class _NeonButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _NeonButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  State<_NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<_NeonButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [widget.color.withValues(alpha: 0.8), widget.color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.7),
                blurRadius: 5, //efek neon
                spreadRadius: 1, //efek neon
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallingBlock {
  double x;
  double y;
  double size;
  double speed;
  Color color;

  _FallingBlock({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });

  factory _FallingBlock.random(Random rng, Size screen) {
    return _FallingBlock(
      x: rng.nextDouble() * screen.width,
      y: rng.nextDouble() * screen.height,
      size: 12 + rng.nextDouble() * 16,
      speed: 1 + rng.nextDouble() * 2,
      color: Colors.primaries[rng.nextInt(Colors.primaries.length)],
    );
  }

  void reset(Random rng, Size screen) {
    x = rng.nextDouble() * screen.width;
    y = -size;
    size = 12 + rng.nextDouble() * 16;
    speed = 1 + rng.nextDouble() * 2;
    color = Colors.primaries[rng.nextInt(Colors.primaries.length)];
  }
}

class _BackgroundPainter extends CustomPainter {
  final List<_FallingBlock> blocks;
  _BackgroundPainter(this.blocks);

  @override
  void paint(Canvas canvas, Size size) {
    for (var b in blocks) {
      final paint = Paint()
        ..color = b.color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(b.x, b.y, b.size, b.size),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}

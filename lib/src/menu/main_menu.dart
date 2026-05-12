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

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late AnimationController _fallController;
  late AnimationController _pulseController;
  final List<_FallingPiece> _pieces = [];

  @override
  void initState() {
    super.initState();
    MusicManager.reset();
    
    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Create initial falling pieces
    for (int i = 0; i < 15; i++) {
      _pieces.add(_FallingPiece.random());
    }
  }

  @override
  void dispose() {
    _fallController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hs = HighScoreProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF050515),
      body: Stack(
        children: [
          // 1. Gameplay Grid Background
          Positioned.fill(
            child: CustomPaint(painter: _FullGridPainter()),
          ),

          // 2. Falling Blocks Effect
          AnimatedBuilder(
            animation: _fallController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _FallingBlocksPainter(_pieces, _fallController.value),
              );
            },
          ),

          // 3. Background Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0A3A).withOpacity(0.8),
                  const Color(0xFF050515).withOpacity(1.0),
                ],
              ),
            ),
          ),

          // 4. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(flex: 2),
                
                // Score Box with Glow
                _HUDBox(
                  label: "RECORD",
                  color: Colors.amberAccent,
                  child: Column(
                    children: [
                      Text(
                        "${hs.highScore}",
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "MAX LEVEL: ${hs.highLevel}",
                        style: GoogleFonts.orbitron(
                          color: Colors.purpleAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),

                // Buttons Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _MenuPillButton(
                        label: "MULAI BERMAIN",
                        icon: Icons.play_arrow_rounded,
                        color: Colors.cyanAccent,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TetrisHome())),
                      ),
                      const SizedBox(height: 20),
                      _MenuPillButton(
                        label: "CARA MAIN",
                        icon: Icons.help_outline_rounded,
                        color: Colors.purpleAccent,
                        onPressed: () => _showTutorial(context),
                      ),
                      const SizedBox(height: 20),
                      _MenuPillButton(
                        label: "KELUAR",
                        icon: Icons.power_settings_new_rounded,
                        color: Colors.redAccent,
                        onPressed: () => SystemNavigator.pop(),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                Text(
                  "TETRISKU v3.3.0 // STABLE",
                  style: GoogleFonts.orbitron(color: Colors.white24, fontSize: 10, letterSpacing: 2),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.cyanAccent.withOpacity(0.5 + (_pulseController.value * 0.5)), 
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.2 * _pulseController.value),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.cyanAccent,
                  const Color(0xFFE040FB).withOpacity(0.7 + (0.3 * _pulseController.value)),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                "TETRISKU",
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0A0A1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("INSTRUKSI", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _tutItem("GESER", "TAP KIRI / KANAN"),
              _tutItem("PUTAR", "TOMBOL PUTAR"),
              _tutItem("JATUH", "TOMBOL DROP"),
              _tutItem("SIMPAN", "TOMBOL HOLD"),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(backgroundColor: Colors.cyanAccent.withOpacity(0.1)),
                child: Text("KONFIRMASI", style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tutItem(String l, String d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 11)),
          Text(d, style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── PARTICLE LOGIC ──

class _FallingPiece {
  late double x, y, speed, rotation, rotSpeed;
  late Color color;
  late List<Offset> blocks;

  _FallingPiece.random() {
    final rng = Random();
    x = rng.nextDouble();
    y = rng.nextDouble() * 2 - 1.0;
    speed = 0.05 + rng.nextDouble() * 0.1;
    rotation = rng.nextDouble() * pi * 2;
    rotSpeed = (rng.nextDouble() - 0.5) * 0.02;
    color = Colors.primaries[rng.nextInt(Colors.primaries.length)].withOpacity(0.3);
    
    final shapes = [
      [const Offset(0,0), const Offset(1,0), const Offset(2,0), const Offset(3,0)], // I
      [const Offset(0,0), const Offset(0,1), const Offset(1,1), const Offset(2,1)], // L
      [const Offset(2,0), const Offset(0,1), const Offset(1,1), const Offset(2,1)], // J
      [const Offset(0,0), const Offset(1,0), const Offset(0,1), const Offset(1,1)], // O
      [const Offset(1,0), const Offset(2,0), const Offset(0,1), const Offset(1,1)], // S
      [const Offset(0,0), const Offset(1,0), const Offset(1,1), const Offset(2,1)], // Z
      [const Offset(1,0), const Offset(0,1), const Offset(1,1), const Offset(2,1)], // T
    ];
    blocks = shapes[rng.nextInt(shapes.length)];
  }
}

class _FallingBlocksPainter extends CustomPainter {
  final List<_FallingPiece> pieces;
  final double progress;
  _FallingBlocksPainter(this.pieces, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in pieces) {
      final double yPos = ((p.y + (progress * p.speed * 10)) % 2.0 - 0.5) * size.height;
      final double xPos = p.x * size.width;
      canvas.save();
      canvas.translate(xPos, yPos);
      canvas.rotate(p.rotation + progress * p.rotSpeed * 10);
      const double blockSize = 15.0;
      for (var block in p.blocks) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(block.dx * blockSize, block.dy * blockSize, blockSize - 2, blockSize - 2),
            const Radius.circular(4),
          ),
          paint..color = p.color,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FallingBlocksPainter oldDelegate) => true;
}

// ── UI WIDGETS ──

class _HUDBox extends StatelessWidget {
  final String label;
  final Widget child;
  final Color color;
  const _HUDBox({required this.label, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 25, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.orbitron(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MenuPillButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuPillButton({required this.label, required this.icon, required this.color, required this.onPressed});

  @override
  State<_MenuPillButton> createState() => _MenuPillButtonState();
}

class _MenuPillButtonState extends State<_MenuPillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: _isPressed ? widget.color.withOpacity(0.2) : Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _isPressed ? widget.color : widget.color.withOpacity(0.5), width: 2),
          boxShadow: [
            if (_isPressed) 
              BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)
            else
              BoxShadow(color: widget.color.withOpacity(0.05), blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 24),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.2)
      ..strokeWidth = 1.0;
    for (double x = 0; x <= size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullGridPainter oldDelegate) => false;
}

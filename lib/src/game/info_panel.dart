import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tetris_game.dart';

class InfoPanel extends StatefulWidget {
  const InfoPanel({super.key, required this.game, required this.lives});
  final TetrisGame game;
  final int lives;

  @override
  State<InfoPanel> createState() => _InfoPanelState();
}

class _InfoPanelState extends State<InfoPanel> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      height: 40, // More compact
      child: Stack(
        children: [
          // ── Bottom Wireframe Line ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 10),
              painter: _WireframePainter(Colors.cyanAccent.withOpacity(0.3)),
            ),
          ),

          // ── Content Layer ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Floating Logo ──
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.cyanAccent, Colors.purpleAccent],
                    ).createShader(bounds),
                    child: Text(
                      "TETRISKU",
                      style: GoogleFonts.orbitron(
                        fontSize: 15, // Slightly smaller
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5, // Reduced
                      ),
                    ),
                  ),
                  Text(
                    "v3.3.0 // ACTIVE",
                    style: GoogleFonts.orbitron(
                      color: Colors.white24,
                      fontSize: 6,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8), // Reduced

              // ── Pulsing Status ──
              FadeTransition(
                opacity: _pulseController.drive(
                  CurveTween(curve: Curves.easeInOut),
                ).drive(Tween(begin: 0.5, end: 1.0)),
                child: Text(
                  _statusText,
                  style: GoogleFonts.orbitron(
                    fontSize: 9, // Slightly smaller
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                    letterSpacing: 1.5, // Reduced
                    shadows: [
                      Shadow(color: _statusColor.withOpacity(0.5), blurRadius: 10),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ── Stats (Score, Level, Lines) ──
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatBlock(
                    label: "SCORE",
                    value: "${widget.game.score}",
                    color: Colors.amberAccent,
                  ),
                  const SizedBox(width: 12),
                  _StatBlock(
                    label: "LVL",
                    value: "${widget.game.level}",
                    color: Colors.purpleAccent,
                  ),
                  const SizedBox(width: 12),
                  _StatBlock(
                    label: "LINES",
                    value: "${widget.game.linesCleared}",
                    color: Colors.cyanAccent,
                  ),
                ],
              ),

              const Spacer(),

              // ── Energy Cores (Floating) ──
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(3, (index) {
                    final bool isFilled = index < widget.lives;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.bolt_rounded,
                        color: isFilled 
                            ? Colors.cyanAccent 
                            : Colors.white.withOpacity(0.05),
                        size: 20,
                        shadows: isFilled ? [
                          Shadow(
                            blurRadius: 12,
                            color: Colors.cyanAccent.withOpacity(0.8),
                          ),
                        ] : null,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _statusText {
    if (widget.game.isRunning) return "BERMAIN";
    if (widget.game.isGameOver) return "SELESAI";
    return "SIAP";
  }

  Color get _statusColor {
    if (widget.game.isRunning) return Colors.lightGreenAccent;
    if (widget.game.isGameOver) return Colors.pinkAccent;
    return Colors.cyanAccent;
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 7,
            color: Colors.white38,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WireframePainter extends CustomPainter {
  final Color color;
  _WireframePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Main bottom line
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);

    // Side ticks
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - 5), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - 5), paint);

    // Dashed segment in middle
    final dashPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 0.5;
    
    double dashWidth = 5;
    double dashSpace = 3;
    double startX = size.width * 0.2;
    double endX = size.width * 0.8;
    
    while (startX < endX) {
      canvas.drawLine(Offset(startX, size.height - 2), Offset(startX + dashWidth, size.height - 2), dashPaint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HUDFramePainter extends CustomPainter {
  final Color color;
  _HUDFramePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double cornerSize = 10.0;

    // Top Left
    canvas.drawPath(Path()
      ..moveTo(0, cornerSize)
      ..lineTo(0, 0)
      ..lineTo(cornerSize, 0), paint);

    // Top Right
    canvas.drawPath(Path()
      ..moveTo(size.width - cornerSize, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, cornerSize), paint);

    // Bottom Left
    canvas.drawPath(Path()
      ..moveTo(0, size.height - cornerSize)
      ..lineTo(0, size.height)
      ..lineTo(cornerSize, size.height), paint);

    // Bottom Right
    canvas.drawPath(Path()
      ..moveTo(size.width - cornerSize, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - cornerSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

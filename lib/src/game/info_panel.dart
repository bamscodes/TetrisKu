import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tetris_game.dart';

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.game, required this.lives});
  final TetrisGame game;
  final int lives;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0D2B), Color(0xFF1A1A3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyanAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Logo & Status ──
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.cyanAccent, Colors.purpleAccent],
            ).createShader(bounds),
            child: Text(
              "TETRISKU",
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Status Pill ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _statusColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              _statusText,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: _statusColor,
                letterSpacing: 1,
              ),
            ),
          ),

          const Spacer(),

          // ── Lives (hati) ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hati yang terisi (sisa free plays)
              ...List.generate(lives, (_) => Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent,
                  size: 16,
                  shadows: const [
                    Shadow(blurRadius: 6, color: Colors.pinkAccent),
                  ],
                ),
              )),
              // Hati yang kosong (sudah dipakai)
              ...List.generate(2 - lives, (_) => Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.white24,
                  size: 16,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  String get _statusText {
    if (game.isRunning) return "BERMAIN";
    if (game.isGameOver) return "SELESAI";
    return "SIAP";
  }

  Color get _statusColor {
    if (game.isRunning) return Colors.lightGreenAccent;
    if (game.isGameOver) return Colors.pinkAccent;
    return Colors.cyanAccent;
  }
}

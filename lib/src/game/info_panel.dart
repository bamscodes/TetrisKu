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

class _InfoPanelState extends State<InfoPanel> {
  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final lives = widget.lives;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0D2B), Color(0xFF1A1A3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Tetrisku",
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
              shadows: [
                Shadow(
                  blurRadius: 12,
                  color: Colors.blueAccent,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: game.isRunning
                  ? Colors.lightBlueAccent
                  : game.isGameOver
                  ? Colors.pinkAccent
                  : Colors.purpleAccent,
            ),
            child: Text(
              game.isRunning
                  ? "Running"
                  : game.isGameOver
                  ? "Game Over"
                  : "Paused",
            ),
          ),
          const SizedBox(height: 12),

          // Indikator nyawa (ikon hati neon)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: List.generate(lives, (index) {
              return Icon(
                Icons.favorite,
                color: Colors.redAccent,
                size: 20,
                shadows: const [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.pinkAccent,
                    offset: Offset(0, 0),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tetris_game.dart';
import '../widgets/tetris_board.dart';
import '../widgets/next_piece_preview.dart';

class BoardCard extends StatelessWidget {
  const BoardCard({super.key, required this.game});
  final TetrisGame game;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AspectRatio(
          aspectRatio: game.boardAspectRatio,
          child: Stack(
            children: [
              // ── Game Board ──
              Positioned.fill(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    if (details.delta.dx > 6) game.moveRight();
                    if (details.delta.dx < -6) game.moveLeft();
                    if (details.delta.dy > 6) game.softDrop();
                  },
                  onDoubleTap: () => game.hardDrop(),
                  child: TetrisBoard(game: game),
                ),
              ),

              // ── Top Left Overlay: Score & Level ──
              Positioned(
                top: 12,
                left: 12,
                child: _HUDOverlay(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatText(label: "SCORE", value: "${game.score}", color: Colors.amberAccent),
                      const SizedBox(height: 4),
                      _StatText(label: "LEVEL", value: "${game.level}", color: Colors.purpleAccent),
                    ],
                  ),
                ),
              ),

              // ── Top Right Overlay: Next Piece ──
              Positioned(
                top: 12,
                right: 12,
                child: _HUDOverlay(
                  child: Column(
                    children: [
                      Text(
                        "NEXT",
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: NextPiecePreview(piece: game.nextPiece),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom Right Overlay: Lines ──
              Positioned(
                bottom: 12,
                right: 12,
                child: _HUDOverlay(
                  child: _StatText(
                    label: "LINES",
                    value: "${game.linesCleared}",
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HUDOverlay extends StatelessWidget {
  final Widget child;
  const _HUDOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}

class _StatText extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatText({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 8,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(blurRadius: 4, color: color.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ],
    );
  }
}
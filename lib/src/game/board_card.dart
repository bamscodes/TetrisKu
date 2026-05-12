import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tetris_game.dart';
import '../widgets/tetris_board.dart';
import '../widgets/next_piece_preview.dart';

class BoardCard extends StatefulWidget {
  const BoardCard({super.key, required this.game});
  final TetrisGame game;

  @override
  State<BoardCard> createState() => _BoardCardState();
}

class _BoardCardState extends State<BoardCard>
    with SingleTickerProviderStateMixin {
  // ── Swipe Debounce ──
  DateTime _lastSwipeTime = DateTime.now();
  static const _swipeCooldown = Duration(milliseconds: 80);

  // ── Combo Overlay ──
  String? _comboText;
  Color _comboColor = Colors.cyanAccent;
  late AnimationController _comboController;
  late Animation<double> _comboScale;
  late Animation<double> _comboFade;
  int _prevLinesCleared = 0;

  @override
  void initState() {
    super.initState();
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _comboScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _comboController, curve: Curves.easeOut));
    _comboFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _comboController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    widget.game.addListener(_onGameUpdate);
  }

  void _onGameUpdate() {
    final cleared = widget.game.lastClearedLines;
    // Pemicu harus berdasarkan perubahan status atau jika nilai cleared baru > 0
    // Kita reset lastClearedLines di game setelah diambil agar tidak trigger berulang
    if (cleared > 0) {
      _showCombo(cleared);
      // Opsional: kita bisa set di game agar lastClearedLines jadi 0 
      // tapi karena ini listener, lebih baik kita handle flag di sini
    }
  }

  void _showCombo(int lines) {
    switch (lines) {
      case 1:
        _comboText = "SINGLE";
        _comboColor = Colors.lightBlueAccent;
        break;
      case 2:
        _comboText = "DOUBLE!";
        _comboColor = Colors.greenAccent;
        break;
      case 3:
        _comboText = "TRIPLE!";
        _comboColor = Colors.purpleAccent;
        break;
      case 4:
        _comboText = "TETRIS!";
        _comboColor = Colors.amberAccent;
        break;
      default:
        return;
    }
    setState(() {});
    _comboController.forward(from: 0);
  }

  void _handleSwipe(DragUpdateDetails details) {
    final now = DateTime.now();
    if (now.difference(_lastSwipeTime) < _swipeCooldown) return;
    _lastSwipeTime = now;

    if (details.delta.dx > 10) widget.game.moveRight();
    if (details.delta.dx < -10) widget.game.moveLeft();
    if (details.delta.dy > 10) widget.game.softDrop();
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameUpdate);
    _comboController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Card(
      elevation: 0, // Hapus bayangan agar rata
      margin: EdgeInsets.zero, // << Hapus margin luar
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: isWide ? BorderRadius.circular(16.0) : BorderRadius.zero, // << Hilangkan radius di mobile agar full
        side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0), // << Hapus padding dalam
        child: AspectRatio(
          aspectRatio: game.boardAspectRatio,
          child: Stack(
            children: [
              // ── Game Board ──
              Positioned.fill(
                child: GestureDetector(
                  onPanUpdate: _handleSwipe,
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

              // ── Bottom Left Overlay: Held Piece ──
              Positioned(
                bottom: 12,
                left: 12,
                child: _HUDOverlay(
                  child: Column(
                    children: [
                      Text(
                        "HOLD",
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
                        child: game.heldPiece != null 
                            ? NextPiecePreview(piece: game.heldPiece!)
                            : const Center(
                                child: Icon(Icons.lock_outline, color: Colors.white24, size: 20),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Combo Overlay (Center) ──
              if (_comboText != null)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _comboController,
                    builder: (context, _) => IgnorePointer(
                      child: Center(
                        child: Opacity(
                          opacity: _comboFade.value,
                          child: Transform.scale(
                            scale: _comboScale.value,
                            child: Text(
                              _comboText!,
                              style: GoogleFonts.orbitron(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: _comboColor,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    blurRadius: 24,
                                    color: _comboColor.withValues(alpha: 0.8),
                                  ),
                                  Shadow(
                                    blurRadius: 8,
                                    color: _comboColor.withValues(alpha: 0.5),
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
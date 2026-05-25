import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tetris_game.dart';
import '../widgets/tetris_board.dart';

class BoardCard extends StatefulWidget {
  const BoardCard({super.key, required this.game, required this.lives});
  final TetrisGame game;
  final int lives;

  @override
  State<BoardCard> createState() => _BoardCardState();
}

class _BoardCardState extends State<BoardCard>
    with SingleTickerProviderStateMixin {
  // ── Gesture Logic ──
  double _hDragOffset = 0;
  double _vDragOffset = 0;
  static const double _hThreshold = 35.0;
  static const double _vThreshold = 40.0;

  // ── Combo Overlay ──
  String? _comboText;
  Color _comboColor = Colors.cyanAccent;
  int _lastTotalLinesCleared = 0;
  late AnimationController _comboController;
  late Animation<double> _comboScale;
  late Animation<double> _comboFade;

  // Cache combo text style
  static final _comboBaseStyle = GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: 4,
  );

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

    _lastTotalLinesCleared = widget.game.linesCleared;
    widget.game.addListener(_onGameUpdate);
  }

  void _onGameUpdate() {
    final currentTotal = widget.game.linesCleared;
    if (currentTotal > _lastTotalLinesCleared) {
      final cleared = widget.game.lastClearedLines;
      if (cleared > 0) {
        _showCombo(cleared);
      }
      _lastTotalLinesCleared = currentTotal;
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

  // ── GESTURE HANDLERS ──

  void _onPanStart(DragStartDetails d) {
    _hDragOffset = 0;
    _vDragOffset = 0;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _hDragOffset += d.delta.dx;
    _vDragOffset += d.delta.dy;

    if (_hDragOffset.abs() > _hThreshold) {
      if (_hDragOffset > 0) {
        widget.game.moveRight();
      } else {
        widget.game.moveLeft();
      }
      HapticHelper.vibrate(() => HapticFeedback.selectionClick());
      _hDragOffset = 0;
    }

    if (_vDragOffset > _vThreshold) {
      widget.game.softDrop();
      HapticHelper.vibrate(() => HapticFeedback.selectionClick());
      _vDragOffset = 0;
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (d.velocity.pixelsPerSecond.dy > 1200) {
      widget.game.hardDrop();
      HapticFeedback.heavyImpact();
    }
  }

  void _handleTap() {
    widget.game.rotate();
    HapticFeedback.lightImpact();
  }

  void _handleLongPress() {
    widget.game.hold();
    HapticFeedback.mediumImpact();
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

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: const Color(0xFF080820),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Colors.white12, width: 1.0),
      ),
      child: AspectRatio(
        aspectRatio: game.boardAspectRatio,
        child: Stack(
          children: [
            // Game Board
            Positioned.fill(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onTap: _handleTap,
                onLongPress: _handleLongPress,
                child: TetrisBoard(game: game),
              ),
            ),

            // Combo Overlay
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
                            style: _comboBaseStyle.copyWith(color: _comboColor),
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
    );
  }
}

class HapticHelper {
  static int _lastVibrateTime = 0;

  static void vibrate(VoidCallback action) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastVibrateTime > 120) { // Limit vibrations to max once per 120ms
      action();
      _lastVibrateTime = now;
    }
  }
}
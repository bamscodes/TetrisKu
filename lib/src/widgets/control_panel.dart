import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tetris_game.dart';

/// Control panel ergonomis untuk mobile.
/// Layout: D-pad (kiri/bawah/kanan) di kiri, Rotate dan Hard Drop di kanan.
class ControlPanel extends StatelessWidget {
  final TetrisGame game;
  const ControlPanel({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0D2B), Color(0xFF1A1A3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyanAccent.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ── D-Pad (kiri) ──
            _buildDPad(),
            const SizedBox(width: 12),
            // ── Action Buttons (kanan) ──
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// D-Pad layout: ← ↓ →
  Widget _buildDPad() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GameButton(
          icon: Icons.chevron_left_rounded,
          onPressed: game.moveLeft,
          color: Colors.cyanAccent,
          size: 46, // << Kecilkan dari 54
        ),
        const SizedBox(width: 4),
        _GameButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onPressed: game.softDrop,
          color: Colors.lightBlueAccent,
          size: 46,
        ),
        const SizedBox(width: 4),
        _GameButton(
          icon: Icons.chevron_right_rounded,
          onPressed: game.moveRight,
          color: Colors.cyanAccent,
          size: 46,
        ),
      ],
    );
  }

  /// Tombol aksi: Hold, Rotate, dan Hard Drop
  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GameButton(
          icon: Icons.inventory_2_rounded,
          onPressed: game.hold,
          color: Colors.amberAccent,
          size: 46,
          label: "HOLD",
        ),
        const SizedBox(width: 4),
        _GameButton(
          icon: Icons.rotate_right_rounded,
          onPressed: game.rotate,
          color: Colors.purpleAccent,
          size: 46,
          label: "PUTAR",
        ),
        const SizedBox(width: 4),
        _GameButton(
          icon: Icons.keyboard_double_arrow_down_rounded,
          onPressed: game.hardDrop,
          color: Colors.pinkAccent,
          size: 46,
          label: "DROP",
        ),
      ],
    );
  }
}

/// Tombol game dengan efek neon glow dan press animation.
class _GameButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  final String? label;

  const _GameButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.size = 54,
    this.label,
  });

  @override
  State<_GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<_GameButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: widget.size,
          height: widget.label != null ? widget.size + 14 : widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _isPressed
                ? widget.color.withValues(alpha: 0.2)
                : const Color(0xFF0A0A1E),
            border: Border.all(
              color: _isPressed
                  ? widget.color
                  : widget.color.withValues(alpha: 0.5),
              width: _isPressed ? 2.5 : 1.5,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.15),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: _isPressed ? widget.color : widget.color.withValues(alpha: 0.8),
                size: widget.size * 0.48,
              ),
              if (widget.label != null) ...[
                const SizedBox(height: 1),
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: widget.color.withValues(alpha: 0.7),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

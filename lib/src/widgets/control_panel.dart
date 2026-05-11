import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tetris_game.dart';

/// Control panel ergonomis untuk mobile.
/// Layout: D-pad (kiri/kanan/bawah) di kiri, Rotate dan Hard Drop di kanan.
class ControlPanel extends StatelessWidget {
  final TetrisGame game;
  const ControlPanel({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── D-Pad (kiri) ──
          _buildDPad(),

          // ── System Buttons (Tengah) ──
          _buildSystemButtons(),

          // ── Action Buttons (kanan) ──
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Tombol Pause & Reset kecil di tengah agar mudah dijangkau jempol
  Widget _buildSystemButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SystemButton(
          icon: game.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          onPressed: game.isRunning ? game.pause : game.start,
          color: game.isRunning ? Colors.purpleAccent : Colors.greenAccent,
        ),
        const SizedBox(height: 12),
        _SystemButton(
          icon: Icons.refresh_rounded,
          onPressed: game.reset,
          color: Colors.pinkAccent,
        ),
      ],
    );
  }

  /// D-Pad layout: ←  ↓  → di baris horizontal
  Widget _buildDPad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Baris atas: ← ↓ →
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DPadButton(
              icon: Icons.arrow_left_rounded,
              onPressed: game.moveLeft,
              color: Colors.cyanAccent,
            ),
            const SizedBox(width: 6),
            _DPadButton(
              icon: Icons.arrow_drop_down_rounded,
              onPressed: game.softDrop,
              color: Colors.lightBlueAccent,
              size: 58,
            ),
            const SizedBox(width: 6),
            _DPadButton(
              icon: Icons.arrow_right_rounded,
              onPressed: game.moveRight,
              color: Colors.cyanAccent,
            ),
          ],
        ),
      ],
    );
  }

  /// Tombol aksi: Rotate (atas) dan Hard Drop (bawah)
  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.rotate_right_rounded,
          label: "PUTAR",
          onPressed: game.rotate,
          color: Colors.purpleAccent,
        ),
        const SizedBox(height: 10),
        _ActionButton(
          icon: Icons.keyboard_double_arrow_down_rounded,
          label: "DROP",
          onPressed: game.hardDrop,
          color: Colors.pinkAccent,
        ),
      ],
    );
  }
}

/// Tombol D-Pad bulat besar untuk arah gerak.
class _DPadButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  const _DPadButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.size = 54,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0A0A1E),
          border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.6),
      ),
    );
  }
}

/// Tombol aksi dengan ikon dan label.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0A0A1E),
          border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol sistem kecil (Pause/Reset)
class _SystemButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _SystemButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

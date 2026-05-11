import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_manager.dart';

class GameOverDialog extends StatefulWidget {
  final int score;
  final int level;
  final int highScore;
  final bool isNewHighScore;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.level,
    required this.highScore,
    required this.isNewHighScore,
    required this.onRestart,
    required this.onExit,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Counter animations
  late AnimationController _counterController;
  late Animation<int> _scoreAnimation;
  late Animation<int> _levelAnimation;

  // Glitch effect for title
  late AnimationController _glitchController;

  // Celebration particles
  late AnimationController _celebrationController;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Fade in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    );
    _fadeController.forward();

    // Stat counting
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scoreAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutCirc),
    );
    _levelAnimation = IntTween(begin: 0, end: widget.level).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutCirc),
    );
    _counterController.forward();

    // Glitch effect
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat(reverse: true);

    // Celebration
    if (widget.isNewHighScore) {
      _celebrationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..addListener(() {
          setState(() {
            for (final p in _particles) {
              p.update();
            }
          });
        });
      
      _spawnParticles();
      _celebrationController.repeat();
      
      // Play high score sound if possible, or just re-play game over
      SoundManager.playSound('sounds/berakhir.mp3'); 
    }
  }

  void _spawnParticles() {
    final rng = Random();
    for (int i = 0; i < 80; i++) {
      _particles.add(_ConfettiParticle(rng));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _counterController.dispose();
    _glitchController.dispose();
    if (widget.isNewHighScore) {
      _celebrationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _fadeAnimation,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Celebration Particles
                if (widget.isNewHighScore)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConfettiPainter(_particles),
                    ),
                  ),

                // Main Content
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A1E).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: widget.isNewHighScore
                          ? Colors.amberAccent
                          : Colors.pinkAccent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isNewHighScore
                                ? Colors.amber
                                : Colors.pinkAccent)
                            .withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Icon
                      _PulseIcon(
                        icon: widget.isNewHighScore
                            ? Icons.emoji_events_rounded
                            : Icons.sentiment_very_dissatisfied,
                        color: widget.isNewHighScore
                            ? Colors.amberAccent
                            : Colors.white,
                      ),
                      const SizedBox(height: 20),

                      // Glitchy Title
                      AnimatedBuilder(
                        animation: _glitchController,
                        builder: (context, child) {
                          final offset = widget.isNewHighScore
                              ? Offset.zero
                              : Offset(
                                  (Random().nextDouble() - 0.5) * 2,
                                  (Random().nextDouble() - 0.5) * 2,
                                );
                          return Transform.translate(
                            offset: offset,
                            child: Text(
                              widget.isNewHighScore ? "NEW RECORD!" : "GAME OVER",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.orbitron(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    blurRadius: 20,
                                    color: widget.isNewHighScore
                                        ? Colors.orangeAccent
                                        : Colors.pinkAccent,
                                    offset: const Offset(0, 0),
                                  ),
                                  if (!widget.isNewHighScore)
                                    const Shadow(
                                      blurRadius: 2,
                                      color: Colors.cyanAccent,
                                      offset: Offset(-2, 0),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Stats Grid with Counter
                      AnimatedBuilder(
                        animation: _counterController,
                        builder: (context, child) {
                          return Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _StatCard(
                                label: "Score",
                                value: "${_scoreAnimation.value}",
                              ),
                              _StatCard(
                                label: "Level",
                                value: "${_levelAnimation.value}",
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // High Score Badge
                      _HighScoreBadge(score: widget.highScore),
                      
                      const SizedBox(height: 36),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _DialogButton(
                              label: "MAIN LAGI",
                              icon: Icons.replay_rounded,
                              onPressed: widget.onRestart,
                              primaryColor: Colors.cyanAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DialogButton(
                              label: "KELUAR",
                              icon: Icons.exit_to_app_rounded,
                              onPressed: widget.onExit,
                              primaryColor: Colors.white38,
                              isOutlined: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _PulseIcon({required this.icon, required this.color});

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(
        widget.icon,
        color: widget.color,
        size: 72,
        shadows: [
          Shadow(
            blurRadius: 20,
            color: widget.color.withValues(alpha: 0.6),
            offset: Offset.zero,
          ),
        ],
      ),
    );
  }
}

class _HighScoreBadge extends StatelessWidget {
  final int score;
  const _HighScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.amberAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            "BEST: $score",
            style: GoogleFonts.orbitron(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color primaryColor;
  final bool isOutlined;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.primaryColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        elevation: 12,
        shadowColor: primaryColor.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: GoogleFonts.orbitron(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  late Offset position;
  late Offset velocity;
  late Color color;
  late double size;
  late double rotation;
  late double rotationSpeed;

  _ConfettiParticle(Random rng) {
    position = Offset(rng.nextDouble() * 400 - 200, rng.nextDouble() * 600 - 300);
    velocity = Offset((rng.nextDouble() - 0.5) * 5, rng.nextDouble() * 6 + 3);
    color = [
      Colors.amber,
      Colors.orange,
      Colors.yellow,
      Colors.white,
      Colors.cyanAccent,
      Colors.pinkAccent,
    ][rng.nextInt(6)];
    size = rng.nextDouble() * 8 + 4;
    rotation = rng.nextDouble() * pi * 2;
    rotationSpeed = (rng.nextDouble() - 0.5) * 0.3;
  }

  void update() {
    position += velocity;
    rotation += rotationSpeed;
    if (position.dy > 450) {
      position = Offset(position.dx, -450);
    }
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.save();
      canvas.translate(size.width / 2 + p.position.dx, size.height / 2 + p.position.dy);
      canvas.rotate(p.rotation);
      canvas.drawRect(Rect.fromLTWH(-p.size / 2, -p.size / 2, p.size, p.size), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

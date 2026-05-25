import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  late AnimationController _floatController;
  late AnimationController _gridController;
  late AnimationController _scoreController;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  Widget? _cachedAdWidget;
  final List<_FallingPiece> _pieces = [];
  final List<_DustParticle> _dustParticles = [];
  bool _isGlitching = false;
  bool _isPaused = false;

  void _pauseAnimations() {
    _isPaused = true;
    _fallController.stop();
    _pulseController.stop();
    _floatController.stop();
    _gridController.stop();
  }

  void _resumeAnimations() {
    if (!_isPaused) return;
    _isPaused = false;
    _fallController.repeat();
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _gridController.repeat();
    _startGlitchTimer();
  }

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

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    // Create initial falling pieces
    for (int i = 0; i < 15; i++) {
      _pieces.add(_FallingPiece.random());
    }

    // Create digital dust particles
    for (int i = 0; i < 30; i++) {
      _dustParticles.add(_DustParticle.random());
    }

    // Periodic glitch trigger
    _startGlitchTimer();

    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // TEST ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _cachedAdWidget = AdWidget(ad: _bannerAd!);
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  void _startGlitchTimer() {
    if (_isPaused) return;
    Future.delayed(Duration(seconds: 5 + Random().nextInt(5)), () {
      if (!mounted || _isPaused) return;
      setState(() => _isGlitching = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted || _isPaused) return;
        setState(() => _isGlitching = false);
        _startGlitchTimer();
      });
    });
  }

  @override
  void dispose() {
    _fallController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _gridController.dispose();
    _scoreController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hs = HighScoreProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF050515),
      body: Stack(
        children: [
          // 1. Scrolling Grid Background
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(painter: _FullGridPainter(_gridController.value)),
              );
            },
          ),

          // 2. Digital Dust Particles
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _DigitalDustPainter(_dustParticles, _pulseController.value),
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

          // 4. Falling Blocks Effect
          AnimatedBuilder(
            animation: _fallController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _FallingBlocksPainter(_pieces, _fallController.value),
              );
            },
          ),

          // 5. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(flex: 2),
                
                // Score Box with Glow & Floating
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, sin(_floatController.value * 2 * pi) * 8),
                      child: AnimatedBuilder(
                        animation: _scoreController,
                        builder: (context, child) {
                          final currentScore = (_scoreController.value * hs.highScore).toInt();
                          return _HUDBox(
                            label: "RECORD",
                            color: Colors.amberAccent,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.emoji_events_rounded, color: Colors.amberAccent, size: 28),
                                    const SizedBox(width: 8),
                                    Text(
                                      "$currentScore",
                                      style: GoogleFonts.orbitron(
                                        color: Colors.white,
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "MAX LEVEL: ${hs.highLevel}",
                                    style: GoogleFonts.orbitron(
                                      color: Colors.purpleAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
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
                        onPressed: () async {
                          _pauseAnimations();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TetrisHome()),
                          );
                          _resumeAnimations();
                        },
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
                
                // Banner Ad
                _buildAdBanner(),
                const SizedBox(height: 12),

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

  Widget _buildAdBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withOpacity(0.05), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: _isAdLoaded && _cachedAdWidget != null
                ? _cachedAdWidget!
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent.withOpacity(0.5)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "LOADING SECURE DATA...",
                        style: GoogleFonts.orbitron(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          fontSize: 9,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _floatController]),
      builder: (context, child) {
        final glowColor = (_isGlitching ? Colors.redAccent : Colors.cyanAccent);
        return Transform.translate(
          offset: Offset(
            _isGlitching ? (Random().nextDouble() - 0.5) * 10 : 0,
            (sin(_floatController.value * 2 * pi) * 10) + (_isGlitching ? (Random().nextDouble() - 0.5) * 10 : 0),
          ),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              // Background Radial Glow
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.15 * _pulseController.value),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: glowColor.withOpacity(0.1 * _pulseController.value),
                  blurRadius: 80,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Bracket
                Text(
                  "[ ",
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: glowColor.withOpacity(0.3 + (0.7 * _pulseController.value)),
                  ),
                ),
                // Main Title
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: _isGlitching 
                      ? [Colors.redAccent, Colors.white, Colors.blueAccent]
                      : [
                          Colors.cyanAccent,
                          const Color(0xFFE040FB).withOpacity(0.7 + (0.3 * _pulseController.value)),
                        ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    "TETRISKU",
                    style: GoogleFonts.orbitron(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: _isGlitching ? 4 : 2,
                    ),
                  ),
                ),
                // Right Bracket
                Text(
                  " ]",
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: glowColor.withOpacity(0.3 + (0.7 * _pulseController.value)),
                  ),
                ),
              ],
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
              _tutItem("GESER", "SWIPE KIRI / KANAN", Icons.swipe_rounded),
              _tutItem("PUTAR", "TAP LAYAR", Icons.touch_app_rounded),
              _tutItem("TURUN", "SWIPE KE BAWAH", Icons.keyboard_arrow_down_rounded),
              _tutItem("JATUH", "SENTAK (FLICK) BAWAH", Icons.south_rounded),
              _tutItem("SIMPAN", "TEKAN LAMA (HOLD)", Icons.back_hand_rounded),
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

  Widget _tutItem(String l, String d, IconData i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(i, color: Colors.cyanAccent.withOpacity(0.5), size: 20),
          const SizedBox(width: 12),
          Text(l, style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 11)),
          const Spacer(),
          Text(d, style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── PARTICLE LOGIC ──

class _DustParticle {
  late double x, y, size, opacity;
  _DustParticle.random() {
    final rng = Random();
    x = rng.nextDouble();
    y = rng.nextDouble();
    size = rng.nextDouble() * 2 + 1;
    opacity = rng.nextDouble() * 0.5;
  }
}

class _DigitalDustPainter extends CustomPainter {
  final List<_DustParticle> particles;
  final double pulse;
  _DigitalDustPainter(this.particles, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      final double currentOpacity = p.opacity * (0.5 + 0.5 * sin(pulse * 2 * pi + p.x * 10));
      paint.color = Colors.cyanAccent.withOpacity(currentOpacity);
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DigitalDustPainter oldDelegate) => true;
}

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
    color = Colors.primaries[rng.nextInt(Colors.primaries.length)].withOpacity(0.6);
    
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
    for (var p in pieces) {
      final double yPos = ((p.y + (progress * p.speed * 10)) % 2.0 - 0.5) * size.height;
      final double xPos = p.x * size.width;
      
      canvas.save();
      canvas.translate(xPos, yPos);
      canvas.rotate(p.rotation + progress * p.rotSpeed * 10);
      
      const double blockSize = 15.0;
      
      for (var block in p.blocks) {
        final rect = Rect.fromLTWH(block.dx * blockSize, block.dy * blockSize, blockSize - 2, blockSize - 2);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

        // 1. Draw Glow
        final glowPaint = Paint()
          ..color = p.color.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(rrect.shift(const Offset(0, 0)), glowPaint);

        // 2. Draw Main Block
        final fillPaint = Paint()
          ..color = p.color.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rrect, fillPaint);

        // 3. Draw Shine/Highlight (Subtle white top-left)
        final shinePaint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawRRect(rrect, shinePaint);
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
    return Stack(
      children: [
        // Corner Accents Painter
        Positioned.fill(
          child: CustomPaint(painter: _HUDFramePainter(color)),
        ),
        
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.05), blurRadius: 30, spreadRadius: 0),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: GoogleFonts.orbitron(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      Text("SYS_RD: 0x${(Random().nextInt(999)).toString().padLeft(3, '0')}", 
                        style: GoogleFonts.orbitron(color: Colors.white10, fontSize: 8)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HUDFramePainter extends CustomPainter {
  final Color color;
  _HUDFramePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double cornerSize = 15.0;

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
    
    // Subtle side dashes
    paint.strokeWidth = 1.0;
    paint.color = color.withOpacity(0.2);
    canvas.drawLine(Offset(0, size.height / 2 - 10), Offset(0, size.height / 2 + 10), paint);
    canvas.drawLine(Offset(size.width, size.height / 2 - 10), Offset(size.width, size.height / 2 + 10), paint);
  }

  @override
  bool shouldRepaint(covariant _HUDFramePainter oldDelegate) => false;
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: _isPressed ? widget.color.withOpacity(0.4) : Colors.black.withOpacity(0.2),
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
        ),
      ),
    );
  }
}

class _FullGridPainter extends CustomPainter {
  final double progress;
  _FullGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.15)
      ..strokeWidth = 1.0;
    
    const double gridSize = 50.0;
    final double offset = progress * gridSize;

    for (double x = -gridSize; x <= size.width + gridSize; x += gridSize) {
      canvas.drawLine(Offset(x + offset, 0), Offset(x + offset, size.height), paint);
    }
    for (double y = -gridSize; y <= size.height + gridSize; y += gridSize) {
      canvas.drawLine(Offset(0, y + offset), Offset(size.width, y + offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullGridPainter oldDelegate) => true;
}

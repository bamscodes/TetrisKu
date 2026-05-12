import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../music_manager.dart';
import '../tetris_game.dart';
import '../widgets/control_panel.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/interstitial_ad_widget.dart';
import 'info_panel.dart';
import 'board_card.dart';
import 'game_over_dialog.dart';
import 'intents.dart';
import '../services/high_score_service.dart'; // << tambah import

class TetrisHome extends StatefulWidget {
  const TetrisHome({super.key});

  @override
  State<TetrisHome> createState() => _TetrisHomeState();
}

class _TetrisHomeState extends State<TetrisHome> {
  late TetrisGame game;
  late InterstitialAdWidget interstitialHelper;

  int _freePlayCount = 0; // Hitungan main gratis (max 2)
  int _countdownValue = 0;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();
    MusicManager.stop();
    game = TetrisGame(onGameOver: _showGameOverDialog);
    _freePlayCount = 1; // Main pertama = gratis
    interstitialHelper = InterstitialAdWidget();
    interstitialHelper.loadAd();
    
    // Mulai dengan countdown
    _startCountdown();
  }

  void _startCountdown() async {
    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
    });

    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() => _countdownValue = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;
    setState(() {
      _countdownValue = 0; // Menunjukkan "GO!"
    });
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    setState(() => _isCountingDown = false);
    MusicManager.playGameplayMusic(); // << Mulai musik gameplay
    game.start();
  }

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  /// Sisa main gratis sebelum harus nonton iklan
  int get _remainingFreePlays => (2 - _freePlayCount).clamp(0, 2);

  Future<bool> _updateHighScoreIfNeeded() async {
    final hs = HighScoreProvider.of(context);
    final isNewScore = await hs.updateScore(game.score);
    await hs.updateLevel(game.level);
    return isNewScore;
  }

  void _showGameOverDialog() async {
    // Update high score jika perlu
    final isNewHighScore = await _updateHighScoreIfNeeded();
    final highScore = HighScoreProvider.of(context).highScore;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameOverDialog(
        score: game.score,
        level: game.level,
        highScore: highScore,
        isNewHighScore: isNewHighScore,
        remainingFreePlays: _remainingFreePlays,
        onRestart: () {
          Navigator.of(ctx).pop();
            if (_freePlayCount < 2) {
              // Masih ada jatah main gratis
              setState(() => _freePlayCount++);
              game.reset();
              MusicManager.playGameplayMusic(); // << Langsung mulai musik
              game.start(); // << Langsung start tanpa countdown
              // Peringatan saat main gratis terakhir
              if (_freePlayCount == 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '⚠️ Main gratis terakhir! Selanjutnya harus nonton iklan.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.deepOrange,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          } else {
            // Sudah habis, harus nonton iklan dulu
            interstitialHelper.showAd(() {
              setState(() => _freePlayCount = 0); // Reset setelah nonton iklan
              game.reset();
              MusicManager.playGameplayMusic();
              game.start();
            });
          }
        },
        onExit: () {
          Navigator.of(ctx).pop();
          interstitialHelper.showAd(() {
            Navigator.of(context).pop();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        interstitialHelper.showAd(() {
          Navigator.of(context).pop(true);
        });
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Shortcuts(
                shortcuts: <LogicalKeySet, Intent>{
                  LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                      const MoveLeftIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowRight):
                      const MoveRightIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowDown):
                      const SoftDropIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowUp): const RotateIntent(),
                  LogicalKeySet(LogicalKeyboardKey.space): const HardDropIntent(),
                },
                child: Actions(
                  actions: <Type, Action<Intent>>{
                    MoveLeftIntent: CallbackAction(
                      onInvoke: (_) => game.moveLeft(),
                    ),
                    MoveRightIntent: CallbackAction(
                      onInvoke: (_) => game.moveRight(),
                    ),
                    SoftDropIntent: CallbackAction(
                      onInvoke: (_) => game.softDrop(),
                    ),
                    RotateIntent: CallbackAction(onInvoke: (_) => game.rotate()),
                    HardDropIntent: CallbackAction(
                      onInvoke: (_) => game.hardDrop(),
                    ),
                  },
                  child: Focus(
                    autofocus: true,
                    // Background statis — tidak perlu rebuild setiap tick
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0D0D2B), Color(0xFF1A1A3F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 24.0 : 0.0, // << Set ke 0.0
                              vertical: isWide ? 12.0 : 4.0,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1200,
                                ),
                                child: isWide
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // InfoPanel: rebuild hanya saat score/level/state berubah
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                AnimatedBuilder(
                                                  animation: game,
                                                  builder: (context, _) => InfoPanel(
                                                    game: game,
                                                    lives: _remainingFreePlays,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16.0),
                                          // BoardCard: rebuild hanya saat posisi blok berubah
                                          Flexible(
                                            flex: 2,
                                            child: AnimatedBuilder(
                                              animation: game,
                                              builder: (context, _) => BoardCard(game: game),
                                            ),
                                          ),
                                          const SizedBox(width: 16.0),
                                          // ControlPanel: Navigasi + Pause/Reset (Bottom)
                                          Expanded(
                                            child: AnimatedBuilder(
                                              animation: game,
                                              builder: (context, _) => ControlPanel(game: game),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          // InfoPanel: compact top bar
                                          AnimatedBuilder(
                                            animation: game,
                                            builder: (context, _) => InfoPanel(
                                              game: game,
                                              lives: _remainingFreePlays,
                                            ),
                                          ),
                                          // BoardCard: fill available space
                                          Expanded(
                                            child: AnimatedBuilder(
                                              animation: game,
                                              builder: (context, _) => BoardCard(game: game),
                                            ),
                                          ),
                                          const BannerAdWidget(),
                                          const SizedBox(height: 4.0),
                                          // ControlPanel: bottom controls
                                          AnimatedBuilder(
                                            animation: game,
                                            builder: (context, _) => ControlPanel(game: game),
                                          ),
                                          const SizedBox(height: 4.0),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // ── Countdown Overlay ──
              if (_isCountingDown)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(_countdownValue),
                        tween: Tween(begin: 1.5, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: (2.0 - value).clamp(0.0, 1.0),
                              child: Text(
                                _countdownValue == 0 ? "GO!" : "$_countdownValue",
                                style: GoogleFonts.orbitron(
                                  fontSize: 80,
                                  fontWeight: FontWeight.w900,
                                  color: _countdownValue == 0 
                                      ? Colors.lightGreenAccent 
                                      : Colors.cyanAccent,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 30,
                                      color: (_countdownValue == 0 
                                              ? Colors.lightGreenAccent 
                                              : Colors.cyanAccent)
                                          .withOpacity(0.8),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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

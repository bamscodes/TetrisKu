import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  int lives = 3; // << default nyawa

  @override
  void initState() {
    super.initState();
    MusicManager.stop();
    game = TetrisGame(onGameOver: _showGameOverDialog);
    game.start();
    interstitialHelper = InterstitialAdWidget();
    interstitialHelper.loadAd();
  }

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

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
        onRestart: () {
          Navigator.of(ctx).pop();
          if (lives > 0) {
            setState(() => lives--);
            game.continueFromGameOver();
          } else {
            interstitialHelper.showAd(() {
              setState(() => lives = 3); // Reset lives after ad
              game.continueFromGameOver();
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
          child: Shortcuts(
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
                      final sidePad = isWide ? 24.0 : 12.0;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: sidePad,
                          vertical: 12.0,
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
                                                lives: lives,
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
                                : SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // InfoPanel: Judul & Nyawa (Top)
                                        AnimatedBuilder(
                                          animation: game,
                                          builder: (context, _) => InfoPanel(
                                            game: game,
                                            lives: lives,
                                          ),
                                        ),
                                        // BoardCard (HUD is now integrated inside)
                                        AnimatedBuilder(
                                          animation: game,
                                          builder: (context, _) => BoardCard(game: game),
                                        ),
                                        const BannerAdWidget(),
                                        const SizedBox(height: 8.0),
                                        // ControlPanel: Navigasi + Pause/Reset (Bottom)
                                        AnimatedBuilder(
                                          animation: game,
                                          builder: (context, _) => ControlPanel(game: game),
                                        ),
                                      ],
                                    ),
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
        ),
      ),
    );
  }
}

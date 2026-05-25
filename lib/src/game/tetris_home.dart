import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../music_manager.dart';
import '../tetris_game.dart';
import '../tetromino.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/interstitial_ad_widget.dart';
import 'board_card.dart';
import 'game_over_dialog.dart';
import 'intents.dart';
import '../services/high_score_service.dart';
import '../widgets/next_piece_preview.dart';

class TetrisHome extends StatefulWidget {
  const TetrisHome({super.key});

  @override
  State<TetrisHome> createState() => _TetrisHomeState();
}

class _TetrisHomeState extends State<TetrisHome> {
  late TetrisGame game;
  late InterstitialAdWidget interstitialHelper;

  int _freePlayCount = 0;
  int _countdownValue = 0;
  bool _isCountingDown = false;

  // Cache TextStyles to avoid GoogleFonts rebuild every frame
  static final _titleStyle = GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.cyanAccent);
  static final _labelStyle = GoogleFonts.orbitron(fontSize: 7, color: Colors.white38, fontWeight: FontWeight.bold);
  static final _statLabelStyle = GoogleFonts.orbitron(fontSize: 6, color: Colors.white38);
  static final _statValueStyle = GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white);
  static final _countdownStyle = GoogleFonts.orbitron(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.cyanAccent);
  static final _countdownGoStyle = GoogleFonts.orbitron(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.lightGreenAccent);

  @override
  void initState() {
    super.initState();
    MusicManager.stop();
    game = TetrisGame(onGameOver: _showGameOverDialog);
    _freePlayCount = 1;
    interstitialHelper = InterstitialAdWidget();
    interstitialHelper.loadAd();
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
    setState(() => _countdownValue = 0);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _isCountingDown = false);
    MusicManager.playGameplayMusic();
    game.start();
  }

  @override
  void dispose() {
    game.dispose();
    interstitialHelper.dispose();
    super.dispose();
  }

  int get _remainingFreePlays => (3 - _freePlayCount).clamp(0, 3);

  void _showGameOverDialog() async {
    final hs = HighScoreProvider.of(context);
    final isNewHighScore = await hs.updateScore(game.score);
    await hs.updateLevel(game.level);
    final highScore = hs.highScore;

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
          if (_freePlayCount < 3) {
            setState(() => _freePlayCount++);
            game.reset();
            MusicManager.playGameplayMusic();
            game.start();
          } else {
            interstitialHelper.showAd(() {
              setState(() => _freePlayCount = 0);
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
        backgroundColor: const Color(0xFF050515),
        body: SafeArea(
          child: Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.arrowLeft): const MoveLeftIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowRight): const MoveRightIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowDown): const SoftDropIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowUp): const RotateIntent(),
              LogicalKeySet(LogicalKeyboardKey.space): const HardDropIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                MoveLeftIntent: CallbackAction(onInvoke: (_) => game.moveLeft()),
                MoveRightIntent: CallbackAction(onInvoke: (_) => game.moveRight()),
                SoftDropIntent: CallbackAction(onInvoke: (_) => game.softDrop()),
                RotateIntent: CallbackAction(onInvoke: (_) => game.rotate()),
                HardDropIntent: CallbackAction(onInvoke: (_) => game.hardDrop()),
              },
              child: Focus(
                autofocus: true,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildCompactTopHUD(game),
                        Expanded(
                          child: Center(
                            child: BoardCard(
                              game: game,
                              lives: _remainingFreePlays,
                            ),
                          ),
                        ),
                        const BannerAdWidget(),
                      ],
                    ),

                    if (_isCountingDown)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey(_countdownValue),
                              tween: Tween(begin: 2.0, end: 1.0),
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(
                                    opacity: (2.0 - value).clamp(0.0, 1.0),
                                    child: Text(
                                      _countdownValue == 0 ? "GO!" : "$_countdownValue",
                                      style: _countdownValue == 0 ? _countdownGoStyle : _countdownStyle,
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
          ),
        ),
      ),
    );
  }

  Widget _buildCompactTopHUD(TetrisGame game) {
    return AnimatedBuilder(
      animation: game,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: Colors.black26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPieceBox("HOLD", game.heldPiece),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("TETRISKU", style: _titleStyle),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat("SCORE", "${game.score}"),
                      const SizedBox(width: 12),
                      _buildStat("LEVEL", "${game.level}"),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _buildMiniLives(),
                ],
              ),
            ),
            _buildPieceBox("NEXT", game.nextPiece),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceBox(String label, Tetromino? piece) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 2),
        SizedBox(
          width: 35,
          height: 35,
          child: piece != null
              ? NextPiecePreview(piece: piece)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: _statLabelStyle),
        Text(value, style: _statValueStyle),
      ],
    );
  }

  Widget _buildMiniLives() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final bool isFilled = index < _remainingFreePlays;
        return Icon(
          Icons.bolt_rounded,
          color: isFilled ? Colors.cyanAccent : Colors.white12,
          size: 14,
        );
      }),
    );
  }
}

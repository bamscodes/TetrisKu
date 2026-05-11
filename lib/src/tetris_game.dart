import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'board.dart';
import 'tetromino.dart';
import 'services/sound_manager.dart';

enum GameState { idle, running, paused, gameOver }

class TetrisGame extends ChangeNotifier {
  final Board board;
  final Random rng = Random();
  final void Function()? onGameOver;

  bool _isDisposed = false;

  late Tetromino current;
  late Tetromino nextPiece;
  late Offset origin;
  Tetromino? ghost;
  late Offset _ghostOrigin;

  int score = 0;
  int level = 1;
  int linesCleared = 0;

  List<int> flashingRows = [];
  int lastClearedLines = 0;

  GameState _state = GameState.idle;
  Duration tick = const Duration(milliseconds: 700);
  Timer? _timer;
  Timer? _flashTimer;

  TetrisGame({this.onGameOver, int width = 10, int height = 20})
    : board = Board(width: width, height: height) {
    nextPiece = Tetromino(randomPiece(rng));
    _spawnNew();
  }

  // Status getters
  GameState get state => _state;
  bool get isIdle => _state == GameState.idle;
  bool get isRunning => _state == GameState.running;
  bool get isPaused => _state == GameState.paused;
  bool get isGameOver => _state == GameState.gameOver;

  double get boardAspectRatio => board.width / board.height;
  Offset get ghostOrigin => _ghostOrigin;

  void start() {
    if (_state == GameState.running) return;
    _state = GameState.running;
    _scheduleTick();
    _safeNotify();
  }

  void pause() {
    if (_state == GameState.running) {
      _state = GameState.paused;
      _timer?.cancel();
      _safeNotify();
    }
  }

  void reset() {
    _state = GameState.idle;
    _timer?.cancel();
    _flashTimer?.cancel();
    board.cells = List.generate(
      board.height,
      (_) => List<Color?>.filled(board.width, null),
    );
    score = 0;
    level = 1;
    linesCleared = 0;
    flashingRows.clear();
    lastClearedLines = 0;
    tick = const Duration(milliseconds: 700);
    _spawnNew();
    start();
  }

  void gameOver() {
    _state = GameState.gameOver;
    _timer?.cancel();
    SoundManager.playSound('sounds/berakhir.mp3');
    onGameOver?.call();
    _safeNotify();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  /// Memanggil notifyListeners() hanya jika belum di-dispose.
  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  void _scheduleTick() {
    _timer?.cancel();
    _timer = Timer.periodic(tick, (_) => _gameTick());
  }

  void _spawnNew() {
    current = nextPiece;
    nextPiece = Tetromino(randomPiece(rng));
    origin = Offset(board.width / 2.0, 0.0);
    _computeGhost();
  }

  void _computeGhost() {
    var ghostOrigin = origin;
    while (_canMove(current, const Offset(0.0, 1.0), at: ghostOrigin)) {
      ghostOrigin = ghostOrigin.translate(0.0, 1.0);
    }
    ghost = current.copyWith();
    _ghostOrigin = ghostOrigin;
  }

  bool _canMove(Tetromino p, Offset delta, {Offset? at}) {
    final pos = (at ?? origin) + delta;
    return board.canPlace(p, pos);
  }

  void _lock() {
    board.lockPiece(current, origin);
    flashingRows = board.getFilledRows();

    if (flashingRows.isNotEmpty) {
      _safeNotify();

      // Gunakan Timer yang bisa di-cancel, bukan Future.delayed
      // agar tidak ada callback menggantung saat dispose.
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 500), () {
        if (_isDisposed) return;

        final cleared = board.clearLines();
        lastClearedLines = cleared;

        if (cleared > 0) {
          linesCleared += cleared;
          score += [0, 40, 100, 300, 1200][cleared] * level;
          SoundManager.playSound('sounds/hapus.mp3');

          if (linesCleared ~/ 10 >= level) {
            level++;
            tick = Duration(milliseconds: max(120, 700 - (level - 1) * 70));
            if (isRunning) _scheduleTick();
          }
        }

        flashingRows.clear();
        _spawnNew();

        if (!board.canPlace(current, origin)) {
          gameOver();
        }

        _safeNotify();
      });
    } else {
      lastClearedLines = 0;
      _spawnNew();

      if (!board.canPlace(current, origin)) {
        gameOver();
      }

      _safeNotify();
    }
  }

  // Tambahkan di dalam class TetrisGame
  void continueFromGameOver() {
    // Jika state bukan gameOver, abaikan
    if (!isGameOver) return;

    // Jangan reset score/level/linesCleared; hanya reset board dan piece
    _flashTimer?.cancel();
    board.cells = List.generate(
      board.height,
      (_) => List<Color?>.filled(board.width, null),
    );
    flashingRows.clear();
    lastClearedLines = 0;

    // Recompute tick dari level agar konsisten
    tick = Duration(milliseconds: max(120, 700 - (level - 1) * 70));

    _spawnNew();
    _state = GameState.running;
    _scheduleTick();
    _safeNotify();
  }

  void _gameTick() {
    if (!isRunning || _isDisposed) return;
    if (_canMove(current, const Offset(0.0, 1.0))) {
      origin = origin.translate(0.0, 1.0);
    } else {
      _lock();
    }
    _computeGhost();
    _safeNotify();
  }

  // Controls
  void moveLeft() {
    if (_canMove(current, const Offset(-1.0, 0.0))) {
      origin = origin.translate(-1.0, 0.0);
      _computeGhost();
      _safeNotify();
    }
  }

  void moveRight() {
    if (_canMove(current, const Offset(1.0, 0.0))) {
      origin = origin.translate(1.0, 0.0);
      _computeGhost();
      _safeNotify();
    }
  }

  void softDrop() {
    if (_canMove(current, const Offset(0.0, 1.0))) {
      origin = origin.translate(0.0, 1.0);
      score += 1;
      _computeGhost();
      SoundManager.playSound('sounds/drop.mp3');
      _safeNotify();
    }
  }

  void hardDrop() {
    bool dropped = false;
    while (_canMove(current, const Offset(0.0, 1.0))) {
      origin = origin.translate(0.0, 1.0);
      score += 2;
      dropped = true;
    }
    if (dropped) SoundManager.playSound('sounds/drop.mp3');
    _lock();
  }

  void rotate() {
    final rotated = current.rotatedCW();
    for (final kick in Tetromino.kicks) {
      final testOrigin = origin + Offset(kick.dx, kick.dy);
      if (board.canPlace(rotated, testOrigin)) {
        current = rotated;
        origin = testOrigin;
        _computeGhost();
        SoundManager.playSound('sounds/rotate.mp3');
        _safeNotify();
        return;
      }
    }
  }
}

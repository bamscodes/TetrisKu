import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'board.dart';
import 'tetromino.dart';
import 'services/sound_manager.dart';

enum GameState { idle, running, gameOver }

class TetrisGame extends ChangeNotifier {
  final Board board;
  final Random rng = Random();
  late final PieceBag _bag;
  final void Function()? onGameOver;

  bool _isDisposed = false;

  late Tetromino current;
  late Tetromino nextPiece;
  Tetromino? heldPiece; // Balok yang sedang disimpan
  bool canHold = true;   // Flag untuk membatasi hold 1x per spawn
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
    _bag = PieceBag(rng);
    nextPiece = Tetromino(_bag.next());
    _spawnNew();
  }

  // Status getters
  GameState get state => _state;
  bool get isIdle => _state == GameState.idle;
  bool get isRunning => _state == GameState.running;

  bool get isGameOver => _state == GameState.gameOver;

  double get boardAspectRatio => board.width / board.height;
  Offset get ghostOrigin => _ghostOrigin;

  void start() {
    if (_state == GameState.running) return;
    _state = GameState.running;
    _scheduleTick();
    _safeNotify();
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
    SoundManager.playSound('sounds/berakhir.wav');
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
    nextPiece = Tetromino(_bag.next());
    origin = Offset(board.width / 2.0, 0.0);
    canHold = true; // Reset flag hold setiap kali balok baru muncul
    _computeGhost();
  }

  void hold() {
    if (!canHold || !isRunning) return;

    if (heldPiece == null) {
      // Simpan balok sekarang, ambil yang baru dari bag
      heldPiece = Tetromino(current.type);
      _spawnNew();
    } else {
      // Tukar balok sekarang dengan yang disimpan
      final tempType = current.type;
      current = Tetromino(heldPiece!.type);
      heldPiece = Tetromino(tempType);
      origin = Offset(board.width / 2.0, 0.0);
      _computeGhost();
    }

    canHold = false; // Kunci fitur hold sampai balok berikutnya
    SoundManager.playSound('sounds/rotate.wav'); // Efek suara transisi
    _safeNotify();
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
          SoundManager.playSound('sounds/hapus.wav');

          if (linesCleared ~/ 10 >= level) {
            level++;
            tick = Duration(milliseconds: max(120, 700 - (level - 1) * 70));
            if (isRunning) _scheduleTick();
          }
        }

        flashingRows.clear();
        _spawnNew();
        Future.delayed(const Duration(milliseconds: 100), () => lastClearedLines = 0);

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
      SoundManager.playSound('sounds/drop.wav');
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
    if (dropped) SoundManager.playSound('sounds/drop.wav');
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
        SoundManager.playSound('sounds/rotate.wav');
        _safeNotify();
        return;
      }
    }
  }
}

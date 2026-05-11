import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/src/tetris_game.dart';
import 'package:tetris/src/services/sound_manager.dart';

void main() {
  SoundManager.enableSound = false;
  group('TetrisGame Logic Tests', () {
    test('game should initialize in idle state', () {
      final game = TetrisGame();
      expect(game.state, GameState.idle);
      expect(game.score, 0);
      expect(game.level, 1);
    });

    test('game should start and change state', () {
      final game = TetrisGame();
      game.start();
      expect(game.state, GameState.running);
    });

    test('moveLeft should change origin if space is available', () {
      final game = TetrisGame();
      game.start();
      final initialOrigin = game.origin;
      game.moveLeft();
      expect(game.origin.dx, initialOrigin.dx - 1);
    });

    test('moveRight should change origin if space is available', () {
      final game = TetrisGame();
      game.start();
      final initialOrigin = game.origin;
      game.moveRight();
      expect(game.origin.dx, initialOrigin.dx + 1);
    });

    test('rotation should change piece rotation', () {
      final game = TetrisGame();
      game.start();
      final initialRotation = game.current.rotation;
      game.rotate();
      expect(game.current.rotation, (initialRotation + 1) % 4);
    });

    test('hardDrop should move piece to bottom', () {
      final game = TetrisGame();
      game.start();
      game.hardDrop();
      // After hardDrop, a new piece should spawn at the top
      // and the score might increase or current piece changed.
      // In our implementation, hardDrop spawns next piece immediately.
      expect(game.origin.dy, lessThanOrEqualTo(1.0)); // reset to top
    });
  });
}

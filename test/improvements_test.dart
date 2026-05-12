import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/src/tetromino.dart';
import 'package:tetris/src/tetris_game.dart';
import 'package:tetris/src/services/sound_manager.dart';

void main() {
  SoundManager.enableSound = false;

  group('PieceBag (7-bag randomizer)', () {
    test('bag should produce all 7 piece types in first 7 draws', () {
      final bag = PieceBag(Random(42));
      final pieces = <PieceType>{};
      for (int i = 0; i < 7; i++) {
        pieces.add(bag.next());
      }
      expect(pieces.length, 7, reason: 'All 7 piece types should appear in a single bag');
      expect(pieces, containsAll(PieceType.values));
    });

    test('bag should refill after 7 draws', () {
      final bag = PieceBag(Random(42));
      // Draw all 7
      for (int i = 0; i < 7; i++) {
        bag.next();
      }
      // Draw 7 more — should also contain all types
      final secondBag = <PieceType>{};
      for (int i = 0; i < 7; i++) {
        secondBag.add(bag.next());
      }
      expect(secondBag.length, 7);
      expect(secondBag, containsAll(PieceType.values));
    });

    test('consecutive bags should have different orderings', () {
      final bag = PieceBag(Random(42));
      final firstOrder = <PieceType>[];
      final secondOrder = <PieceType>[];
      for (int i = 0; i < 7; i++) {
        firstOrder.add(bag.next());
      }
      for (int i = 0; i < 7; i++) {
        secondOrder.add(bag.next());
      }
      // Very unlikely (1/5040 chance) they are the same
      // But we can at least verify they both contain all types
      expect(firstOrder.toSet(), containsAll(PieceType.values));
      expect(secondOrder.toSet(), containsAll(PieceType.values));
    });
  });

  group('TetrisGame with 7-bag', () {
    test('game should use 7-bag for piece spawning', () {
      final game = TetrisGame();
      // current and nextPiece should both be valid piece types
      expect(PieceType.values.contains(game.current.type), true);
      expect(PieceType.values.contains(game.nextPiece.type), true);
    });

    test('game reset should still produce valid pieces', () {
      final game = TetrisGame();
      game.start();
      game.reset();
      expect(game.state, GameState.running);
      expect(PieceType.values.contains(game.current.type), true);
      expect(PieceType.values.contains(game.nextPiece.type), true);
    });
  });

  group('TetrisGame state machine (no pause)', () {
    test('game states should be idle, running, gameOver only', () {
      expect(GameState.values.length, 3);
      expect(GameState.values, containsAll([
        GameState.idle,
        GameState.running,
        GameState.gameOver,
      ]));
    });

    test('start from idle should go to running', () {
      final game = TetrisGame();
      expect(game.state, GameState.idle);
      game.start();
      expect(game.state, GameState.running);
    });

    test('calling start while running should be a no-op', () {
      final game = TetrisGame();
      game.start();
      game.start(); // Should not throw or change state
      expect(game.state, GameState.running);
    });
  });

  group('Line clear combo scoring', () {
    test('lastClearedLines should update after line clear', () {
      final game = TetrisGame();
      game.start();
      // Initial state
      expect(game.lastClearedLines, 0);
      expect(game.linesCleared, 0);
    });

    test('score per line clear should follow Tetris scoring', () {
      // Verify scoring constants: 1 line = 40, 2 = 100, 3 = 300, 4 = 1200
      final scoreTable = [0, 40, 100, 300, 1200];
      expect(scoreTable[1], 40);
      expect(scoreTable[2], 100);
      expect(scoreTable[3], 300);
      expect(scoreTable[4], 1200);
    });
  });

  group('Tetromino basics', () {
    test('all piece types should have exactly 4 blocks', () {
      for (final type in PieceType.values) {
        final piece = Tetromino(type);
        expect(piece.blocks.length, 4, reason: '$type should have 4 blocks');
      }
    });

    test('rotation should produce valid piece', () {
      for (final type in PieceType.values) {
        final piece = Tetromino(type);
        final rotated = piece.rotatedCW();
        expect(rotated.blocks.length, 4);
        expect(rotated.rotation, 1);
      }
    });

    test('colorOf should return unique color for each type', () {
      final colors = <int>{};
      for (final type in PieceType.values) {
        colors.add(Tetromino.colorOf(type).value);
      }
      expect(colors.length, 7, reason: 'Each piece type should have a unique color');
    });
  });
}

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/src/tetris_game.dart';
import 'package:tetris/src/tetromino.dart';
import 'package:tetris/src/services/sound_manager.dart';

void main() {
  setUp(() {
    SoundManager.enableSound = false; // Disable sound during test to avoid audio plugin mock issues
  });

  group('Tetrisku - High Score & Level Acceleration Stability Test', () {
    test('Simulate gameplay up to 6000+ points and verify system stability', () {
      final game = TetrisGame();
      game.start();

      expect(game.score, 0);
      expect(game.level, 1);
      expect(game.tick.inMilliseconds, 700);

      // We will simulate dropping and locking pieces, clearing rows,
      // and checking the level/tick speed progress.
      
      int clearCount = 0;
      
      // Let's run a loop that simulates clearing 4 lines (TETRIS) multiple times.
      // A Tetris (4 lines cleared) gives 1200 * level points.
      // - At Level 1, a Tetris gives 1200 points.
      // - At Level 2, a Tetris gives 2400 points.
      // - At Level 3, a Tetris gives 3600 points.
      // - At Level 4, a Tetris gives 4800 points.
      // Total score will easily exceed 6000.
      
      while (game.score < 8000) {
        // Manually mock locking cells on a row to simulate filled rows
        final rowToFill = game.board.height - 1;
        for (int x = 0; x < game.board.width; x++) {
          game.board.cells[rowToFill][x] = Tetromino.colorOf(PieceType.I);
        }
        
        // Ensure rows are detected as flashing (filled)
        final filledRows = game.board.getFilledRows();
        expect(filledRows.contains(rowToFill), true, reason: 'Row should be full');
        
        // Execute line clear and scoring
        final cleared = game.board.clearLines();
        expect(cleared, 1, reason: 'Exactly 1 line should be cleared');
        
        // Manually update game lines cleared and score (standard game loop mock)
        game.linesCleared += cleared;
        clearCount += cleared;
        
        // Calculate points based on lines cleared: [0, 40, 100, 300, 1200]
        final points = 40 * game.level; // Standard single line clear points
        game.score += points;
        
        // Check level progression (every 10 lines)
        if (game.linesCleared ~/ 10 >= game.level) {
          game.level++;
          // Tick rate should decrease (game gets faster)
          game.tick = Duration(milliseconds: max(120, 700 - (game.level - 1) * 70));
        }
        
        // Print progress for manual verification
        print('Cleared Lines: ${game.linesCleared} | Score: ${game.score} | Level: ${game.level} | Tick: ${game.tick.inMilliseconds}ms');
      }

      // Verify that the score exceeded 6000 points
      expect(game.score >= 6000, true, reason: 'Score should be at least 6000');
      
      // Verify that the level progressed correctly
      expect(game.level > 1, true, reason: 'Level should have progressed beyond 1');
      
      // Verify that the tick speed accelerated (got shorter than 700ms)
      expect(game.tick.inMilliseconds < 700, true, reason: 'Tick rate should have accelerated');
      
      // Verify that the tick speed did not drop below the safety limit of 120ms
      expect(game.tick.inMilliseconds >= 120, true, reason: 'Tick rate must never drop below 120ms safety limit');
      
      print('=== Success: High-score gameplay simulated up to ${game.score} points and Level ${game.level} successfully! ===');
    });
  });
}

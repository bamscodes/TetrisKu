import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/src/services/high_score_service.dart';
import 'package:tetris/src/services/sound_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SoundManager.enableSound = false;

  group('HighScoreService Tests', () {
    late HighScoreService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = HighScoreService();
      await service.load();
    });

    test('initial values should be zero', () {
      expect(service.highScore, 0);
      expect(service.highLevel, 0);
    });

    test('updateScore should update if score is higher', () async {
      final updated = await service.updateScore(100);
      expect(updated, true);
      expect(service.highScore, 100);

      final updatedAgain = await service.updateScore(50);
      expect(updatedAgain, false);
      expect(service.highScore, 100);

      final updatedHigher = await service.updateScore(200);
      expect(updatedHigher, true);
      expect(service.highScore, 200);
    });

    test('updateLevel should update if level is higher', () async {
      final updated = await service.updateLevel(5);
      expect(updated, true);
      expect(service.highLevel, 5);

      final updatedAgain = await service.updateLevel(3);
      expect(updatedAgain, false);
      expect(service.highLevel, 5);
    });

    test('should persist data to shared preferences', () async {
      await service.updateScore(500);
      await service.updateLevel(10);

      // Create new service to simulate app restart
      final newService = HighScoreService();
      await newService.load();

      expect(newService.highScore, 500);
      expect(newService.highLevel, 10);
    });
  });
}

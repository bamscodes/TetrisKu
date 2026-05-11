import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reactive high score service yang menyimpan state di memori
/// dan menyinkronkan ke disk (SharedPreferences) secara otomatis.
///
/// Dimuat sekali saat startup dan diinjeksi ke widget tree via
/// [HighScoreProvider], sehingga semua layar selalu sinkron.
class HighScoreService extends ChangeNotifier {
  static const _keyHighScore = 'highScore';
  static const _keyHighLevel = 'highLevel';

  int _highScore = 0;
  int _highLevel = 0;

  int get highScore => _highScore;
  int get highLevel => _highLevel;

  /// Memuat data dari disk. Panggil sekali saat app startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(_keyHighScore) ?? 0;
    _highLevel = prefs.getInt(_keyHighLevel) ?? 0;
    notifyListeners();
  }

  /// Memperbarui high score jika [score] lebih tinggi dari yang tersimpan.
  /// Mengembalikan `true` jika record baru tercapai.
  Future<bool> updateScore(int score) async {
    if (score <= _highScore) return false;
    _highScore = score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHighScore, _highScore);
    notifyListeners();
    return true;
  }

  /// Memperbarui high level jika [level] lebih tinggi dari yang tersimpan.
  /// Mengembalikan `true` jika record baru tercapai.
  Future<bool> updateLevel(int level) async {
    if (level <= _highLevel) return false;
    _highLevel = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHighLevel, _highLevel);
    notifyListeners();
    return true;
  }
}

/// InheritedNotifier yang menyediakan [HighScoreService] ke seluruh widget tree.
/// Widgets di bawahnya akan otomatis rebuild saat highScore/highLevel berubah.
class HighScoreProvider extends InheritedNotifier<HighScoreService> {
  const HighScoreProvider({
    super.key,
    required HighScoreService service,
    required super.child,
  }) : super(notifier: service);

  static HighScoreService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<HighScoreProvider>();
    assert(provider != null, 'No HighScoreProvider found in context');
    return provider!.notifier!;
  }
}
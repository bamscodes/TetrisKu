import 'dart:developer' as developer;
import 'package:audioplayers/audioplayers.dart';

class MusicManager {
  static AudioPlayer? _player;
  static bool _isPlaying = false;

  static Future<void> playMenuMusic() async {
    if (_isPlaying) return;

    _player ??= AudioPlayer();

    try {
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(1.0);
      await _player!.play(AssetSource('sounds/menu_theme.wav'));
      _isPlaying = true;
      developer.log("🎵 Memutar musik menu...", name: "MusicManager");
    } catch (e, st) {
      developer.log("❌ Gagal memutar musik menu", error: e, stackTrace: st, name: "MusicManager");
    }
  }

  static Future<void> playGameplayMusic() async {
    await stop();

    _player ??= AudioPlayer();

    try {
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(1.0);
      await _player!.play(AssetSource('sounds/gameplay_theme.wav'));
      _isPlaying = true;
      developer.log("🎮 Memutar musik gameplay...", name: "MusicManager");
    } catch (e) {
      developer.log("⚠️ Musik gameplay gagal", error: e, name: "MusicManager");
    }
  }

  static Future<void> stop() async {
    if (_player != null) {
      await _player!.stop();
    }
    _isPlaying = false;
  }

  static Future<void> reset() async {
    await stop();
    await playMenuMusic();
  }
}
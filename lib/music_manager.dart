import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicManager {
  static final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
  static bool _isMuted = false;

  static Future<void> playMenuMusic() async {
    if (_isMuted) return;
    try {
      await _player.stop();
      await _player.setSource(AssetSource('sounds/menu.wav'));
      await _player.resume();
    } catch (e) {
      debugPrint("Music error: $e");
    }
  }

  static Future<void> playGameplayMusic() async {
    if (_isMuted) return;
    try {
      await _player.stop();
      await _player.setSource(AssetSource('sounds/gameplay.wav'));
      await _player.resume();
    } catch (e) {
      debugPrint("Music error: $e");
    }
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static Future<void> reset() async {
    if (_isMuted) return;
    await _player.stop();
    await _player.resume();
  }

  static void setMute(bool muted) {
    _isMuted = muted;
    if (muted) _player.pause();
  }
}
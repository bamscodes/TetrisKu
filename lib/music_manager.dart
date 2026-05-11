import 'dart:developer' as developer;
import 'package:audioplayers/audioplayers.dart';

class MusicManager {
  static AudioPlayer? _player;
  static bool _isPlaying = false;

  static Future<void> playMenuMusic() async {
    if (_isPlaying) return;

    _player?.stop();
    _player?.dispose();

    _player = AudioPlayer();

    try {
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(1.0);
      await _player!.play(AssetSource('sounds/menu_theme.mp3'));
      _isPlaying = true;
      developer.log("🎵 Memutar ulang musik menu...", name: "MusicManager");
    } catch (e, st) {
      developer.log("❌ Gagal memutar musik", error: e, stackTrace: st, name: "MusicManager");
    }
  }

  static Future<void> stop() async {
    if (_player != null) {
      await _player!.stop();
      await _player!.dispose();
      _player = null;
    }
    _isPlaying = false;
  }

  static Future<void> reset() async {
    await stop();
    await playMenuMusic();
  }

  static Future<void> mute() async {
    if (_player != null) await _player!.setVolume(0);
  }

  static Future<void> unmute() async {
    if (_player != null) await _player!.setVolume(1.0);
  }
}
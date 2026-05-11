import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static List<AudioPlayer>? _players;
  static int _currentIndex = 0;
  static bool _isMuted = false;
  
  /// Set ini ke `false` saat unit testing untuk menghindari error plugin audio.
  static bool enableSound = true;

  static void _ensureInitialized() {
    if (!enableSound) return;
    _players ??= List.generate(
      5,
      (_) => AudioPlayer()..setPlayerMode(PlayerMode.lowLatency),
    );
  }

  /// Memainkan efek suara pendek (SFX) dari assets.
  static void playSound(String assetPath) {
    if (_isMuted || !enableSound) return;

    try {
      _ensureInitialized();
      final player = _players![_currentIndex];
      
      player.play(AssetSource(assetPath)).catchError((e, st) {
        developer.log(
          "❌ Gagal memutar sfx $assetPath",
          error: e,
          stackTrace: st,
          name: "SoundManager",
        );
      });

      _currentIndex = (_currentIndex + 1) % _players!.length;
    } catch (e) {
      debugPrint("SoundManager Error: $e");
    }
  }

  static void mute() {
    _isMuted = true;
    _ensureInitialized();
    _players?.forEach((p) => p.setVolume(0));
  }

  static void unmute() {
    _isMuted = false;
    _ensureInitialized();
    _players?.forEach((p) => p.setVolume(1.0));
  }

  static void dispose() {
    _players?.forEach((p) => p.dispose());
    _players = null;
  }
}

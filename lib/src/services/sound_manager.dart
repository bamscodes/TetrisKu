import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final Map<String, List<AudioPlayer>> _sfxPool = {};
  static final Map<String, int> _sfxIndices = {};
  static final Map<String, int> _lastPlayTimes = {};
  
  static bool _isMuted = false;
  static bool enableSound = true;
  static int _lastGlobalPlayTime = 0;

  static Future<void> preload() async {
    if (!enableSound) return;
    try {
      // AudioContext untuk meminimalkan gangguan focus di Android
      await AudioPlayer.global.setAudioContext(AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
        respectSilence: true,
        stayAwake: false,
      ).build());

      final sfxPaths = [
        'sounds/rotate.wav',
        'sounds/hapus.wav',
        'sounds/berakhir.wav',
        'sounds/drop.wav',
      ];

      for (final path in sfxPaths) {
        // Pool kecil: 2 player per suara sudah cukup
        final players = <AudioPlayer>[];
        for (int i = 0; i < 2; i++) {
          final p = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
          await p.setSource(AssetSource(path));
          players.add(p);
        }
        _sfxPool[path] = players;
        _sfxIndices[path] = 0;
      }
    } catch (e) {
      debugPrint("Preload error: $e");
    }
  }

  static void playSound(String assetPath) {
    if (_isMuted || !enableSound) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Global Throttle: Max 1 SFX per 120ms across the entire game to protect platform channel
    if (now - _lastGlobalPlayTime < 120) return;

    final lastPlay = _lastPlayTimes[assetPath] ?? 0;
    // 2. Per-Asset Throttle: Max 1 of the same sound per 220ms
    if (now - lastPlay < 220) return;

    _lastGlobalPlayTime = now;
    _lastPlayTimes[assetPath] = now;

    try {
      final players = _sfxPool[assetPath];
      if (players != null && players.isNotEmpty) {
        final idx = _sfxIndices[assetPath]! % players.length;
        final p = players[idx];
        
        // 3. Reliable playback: seek(Duration.zero) first, then resume, entirely non-blocking
        p.seek(Duration.zero).then((_) {
          if (!_isMuted && enableSound) {
            p.resume().catchError((_) {});
          }
        }).catchError((_) {});
        
        _sfxIndices[assetPath] = idx + 1;
      }
    } catch (e) {
      // Fail silently
    }
  }

  static void mute() => _isMuted = true;
  static void unmute() => _isMuted = false;
  static bool get isMuted => _isMuted;
}

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final Map<String, List<AudioPlayer>> _sfxPool = {};
  static final Map<String, int> _sfxIndices = {};
  static bool _isMuted = false;
  
  /// Set ini ke `false` saat unit testing untuk menghindari error plugin audio.
  static bool enableSound = true;

  static Future<void> preload() async {
    if (!enableSound) return;
    try {
      final sfxCounts = {
        'sounds/drop.wav': 5,     // << Tambah dari 3 ke 5
        'sounds/rotate.wav': 5,   // << Tambah dari 3 ke 5
        'sounds/hapus.wav': 3,
        'sounds/berakhir.wav': 1,
      };

      for (final entry in sfxCounts.entries) {
        final path = entry.key;
        final count = entry.value;
        final players = <AudioPlayer>[];
        
        for (int i = 0; i < count; i++) {
          final p = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
          await p.setSource(AssetSource(path));
          players.add(p);
        }
        
        _sfxPool[path] = players;
        _sfxIndices[path] = 0;
      }
      developer.log("✅ SFX Pool ditingkatkan untuk responsivitas tinggi", name: "SoundManager");
    } catch (e) {
      developer.log("Preload error: $e", name: "SoundManager");
    }
  }

  /// Memainkan efek suara pendek (SFX) dari assets.
  static void playSound(String assetPath) {
    if (_isMuted || !enableSound) return;

    try {
      final players = _sfxPool[assetPath];
      if (players != null && players.isNotEmpty) {
        final idx = _sfxIndices[assetPath]! % players.length;
        final p = players[idx];
        
        // Langsung lompat ke awal dan putar (metode paling stabil & cepat)
        p.seek(Duration.zero);
        p.resume();

        _sfxIndices[assetPath] = idx + 1;
      } else {
        // Fallback jika belum di-preload
        final p = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
        p.play(AssetSource(assetPath)).catchError((_) {});
      }
    } catch (e) {
      debugPrint("SoundManager Error: $e");
    }
  }

  static void mute() {
    _isMuted = true;
    for (final list in _sfxPool.values) {
      for (final p in list) {
        p.setVolume(0);
      }
    }
  }

  static void unmute() {
    _isMuted = false;
    for (final list in _sfxPool.values) {
      for (final p in list) {
        p.setVolume(1.0);
      }
    }
  }

  static void dispose() {
    for (final list in _sfxPool.values) {
      for (final p in list) {
        p.dispose();
      }
    }
    _sfxPool.clear();
    _sfxIndices.clear();
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicManager {
  static final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
  static bool _isMuted = false;

  static Future<void> playMenuMusic() async {
    if (_isMuted) return;
    try {
      _player.setSource(AssetSource('sounds/menu_theme.wav')).then((_) {
        if (!_isMuted) {
          _player.resume().catchError((e) {
            debugPrint("Music resume error: $e");
          });
        }
      }).catchError((e) {
        debugPrint("Music setSource error: $e");
      });
    } catch (e) {
      debugPrint("Music playMenuMusic error: $e");
    }
  }

  static Future<void> playGameplayMusic() async {
    if (_isMuted) return;
    try {
      _player.setSource(AssetSource('sounds/menu_theme.wav')).then((_) {
        if (!_isMuted) {
          _player.resume().catchError((e) {
            debugPrint("Music resume error: $e");
          });
        }
      }).catchError((e) {
        debugPrint("Music setSource error: $e");
      });
    } catch (e) {
      debugPrint("Music playGameplayMusic error: $e");
    }
  }

  static Future<void> stop() async {
    try {
      _player.stop().catchError((e) {
        debugPrint("Music stop error: $e");
      });
    } catch (e) {
      debugPrint("Music stop catch error: $e");
    }
  }

  static Future<void> reset() async {
    if (_isMuted) return;
    try {
      _player.setSource(AssetSource('sounds/menu_theme.wav')).then((_) {
        if (!_isMuted) {
          _player.resume().catchError((e) {
            debugPrint("Music reset resume error: $e");
          });
        }
      }).catchError((e) {
        debugPrint("Music reset setSource error: $e");
      });
    } catch (e) {
      debugPrint("Music reset error: $e");
    }
  }

  static void setMute(bool muted) {
    _isMuted = muted;
    if (muted) {
      _player.pause().catchError((e) {
        debugPrint("Music pause error: $e");
      });
    }
  }
}
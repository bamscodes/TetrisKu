import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'src/app.dart';
import 'src/services/high_score_service.dart';
import 'src/services/sound_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mode Full Screen & Kunci Portrait
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  unawaited(MobileAds.instance.initialize());
  unawaited(SoundManager.preload());

  // Muat high score sekali saat startup
  final highScoreService = HighScoreService();
  await highScoreService.load();

  runApp(
    HighScoreProvider(
      service: highScoreService,
      child: const TetrisApp(),
    ),
  );
}

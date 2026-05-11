import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'src/app.dart';
import 'src/services/high_score_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());

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

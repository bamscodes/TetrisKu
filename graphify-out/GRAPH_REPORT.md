# Graph Report - tetris  (2026-05-08)

## Corpus Check
- 54 files · ~211,160 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 348 nodes · 372 edges · 35 communities (27 shown, 8 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 18 edges
2. `package:google_fonts/google_fonts.dart` - 7 edges
3. `AppDelegate` - 6 edges
4. `../tetris_game.dart` - 6 edges
5. `Create()` - 6 edges
6. `Destroy()` - 6 edges
7. `dart:math` - 5 edges
8. `MessageHandler()` - 5 edges
9. `RunnerTests` - 4 edges
10. `../tetromino.dart` - 4 edges

## Surprising Connections (you probably didn't know these)
- `fl_register_plugins()` --calls--> `my_application_activate()`  [INFERRED]
  linux/flutter/generated_plugin_registrant.cc → linux/runner/my_application.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `RegisterPlugins()` --calls--> `OnCreate()`  [INFERRED]
  windows/flutter/generated_plugin_registrant.cc → windows/runner/flutter_window.cpp
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp
- `OnCreate()` --calls--> `SetChildContent()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp

## Communities (35 total, 8 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.06
Nodes (34): BoardCard, build, Card, Column, Container, _HUDOverlay, SizedBox, _StatText (+26 more)

### Community 1 - "Community 1"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 2 - "Community 2"
Cohesion: 0.08
Nodes (25): BackdropFilter, build, _ConfettiPainter, _ConfettiParticle, Container, Dialog, _DialogButton, dispose (+17 more)

### Community 3 - "Community 3"
Cohesion: 0.08
Nodes (25): board_card.dart, BannerAdWidget, build, Container, dispose, Icon, initState, MoveLeftIntent (+17 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (22): Color, colorOf, copyWith, randomPiece, rotatedCW, Tetromino, _BoardPainter, build (+14 more)

### Community 5 - "Community 5"
Cohesion: 0.09
Nodes (22): board.dart, _canMove, _computeGhost, continueFromGameOver, dispose, Function, gameOver, _gameTick (+14 more)

### Community 6 - "Community 6"
Cohesion: 0.09
Nodes (18): build, MaterialApp, TetrisApp, HighScoreProvider, HighScoreService, of, main, main (+10 more)

### Community 7 - "Community 7"
Cohesion: 0.1
Nodes (20): Align, _BackgroundPainter, build, dispose, _FallingBlock, GestureDetector, Icon, initState (+12 more)

### Community 8 - "Community 8"
Cohesion: 0.11
Nodes (15): main, BannerAdWidget, _BannerAdWidgetState, build, dispose, initState, SizedBox, InterstitialAdWidget (+7 more)

### Community 9 - "Community 9"
Cohesion: 0.12
Nodes (15): Board, canPlace, clearLines, inBounds, isCellEmpty, isTopOccupied, lockPiece, reset (+7 more)

### Community 10 - "Community 10"
Cohesion: 0.12
Nodes (15): _ActionButton, build, _buildActionButtons, _buildDPad, _buildSystemButtons, Column, Container, _controlButton (+7 more)

### Community 11 - "Community 11"
Cohesion: 0.15
Nodes (12): MusicManager, playMenuMusic, stop, dispose, _ensureInitialized, mute, playSound, SoundManager (+4 more)

### Community 12 - "Community 12"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 14 - "Community 14"
Cohesion: 0.29
Nodes (6): HardDropIntent, MoveLeftIntent, MoveRightIntent, RotateIntent, SoftDropIntent, package:flutter/widgets.dart

### Community 15 - "Community 15"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 16 - "Community 16"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

## Knowledge Gaps
- **216 isolated node(s):** `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `main`, `src/app.dart` (+211 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 6` to `Community 0`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 10`?**
  _High betweenness centrality (0.331) - this node is a cross-community bridge._
- **Why does `package:audioplayers/audioplayers.dart` connect `Community 11` to `Community 5`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Why does `dart:math` connect `Community 4` to `Community 2`, `Community 5`, `Community 7`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **What connects `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry` to the rest of the system?**
  _216 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
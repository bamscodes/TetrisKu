# Graph Report - tetris  (2026-05-13)

## Corpus Check
- 53 files · ~240,835 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 508 nodes · 560 edges · 25 communities detected
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
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
- [[_COMMUNITY_Community 24|Community 24]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 19 edges
2. `package:google_fonts/google_fonts.dart` - 9 edges
3. `dart:math` - 7 edges
4. `AppDelegate` - 6 edges
5. `../tetris_game.dart` - 6 edges
6. `Create()` - 6 edges
7. `Destroy()` - 6 edges
8. `write_wav()` - 6 edges
9. `MessageHandler()` - 5 edges
10. `note_freq()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `fl_register_plugins()` --calls--> `my_application_activate()`  [INFERRED]
  linux\flutter\generated_plugin_registrant.cc → linux\runner\my_application.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux\runner\main.cc → linux\runner\my_application.cc
- `RegisterPlugins()` --calls--> `OnCreate()`  [INFERRED]
  windows\flutter\generated_plugin_registrant.cc → windows\runner\flutter_window.cpp
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows\runner\flutter_window.cpp → windows\runner\win32_window.cpp
- `OnCreate()` --calls--> `SetChildContent()`  [INFERRED]
  windows\runner\flutter_window.cpp → windows\runner\win32_window.cpp

## Communities

### Community 0 - "Community 0"
Cohesion: 0.02
Nodes (121): Align, _AmbientParticles, _AmbientParticlesState, AnimatedBuilder, AnimatedContainer, _AnimatedLine, AnimatedOpacity, _AnimatedScoreCard (+113 more)

### Community 1 - "Community 1"
Cohesion: 0.05
Nodes (40): board_card.dart, AnimatedBuilder, BannerAdWidget, build, _buildStatsHUD, _buildTopHUD, Center, Container (+32 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (35): build, MaterialApp, TetrisApp, Board, canPlace, clearLines, inBounds, isCellEmpty (+27 more)

### Community 3 - "Community 3"
Cohesion: 0.06
Nodes (31): build, Column, Container, HUDPanel, _HUDStat, SizedBox, _Badge, build (+23 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (23): HighScoreProvider, HighScoreService, of, Color, colorOf, copyWith, next, PieceBag (+15 more)

### Community 5 - "Community 5"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 6 - "Community 6"
Cohesion: 0.08
Nodes (25): BackdropFilter, build, _ConfettiPainter, _ConfettiParticle, Container, Dialog, _DialogButton, dispose (+17 more)

### Community 7 - "Community 7"
Cohesion: 0.08
Nodes (23): board.dart, _canMove, _computeGhost, continueFromGameOver, dispose, Function, gameOver, _gameTick (+15 more)

### Community 8 - "Community 8"
Cohesion: 0.09
Nodes (19): main, BannerAdWidget, _BannerAdWidgetState, build, Center, dispose, initState, SizedBox (+11 more)

### Community 9 - "Community 9"
Cohesion: 0.1
Nodes (20): _ActionButton, build, _buildActionButtons, _buildDPad, _buildSystemButtons, Column, Container, _controlButton (+12 more)

### Community 10 - "Community 10"
Cohesion: 0.11
Nodes (18): BoardCard, _BoardCardState, build, Card, Column, Container, dispose, _handleSwipe (+10 more)

### Community 11 - "Community 11"
Cohesion: 0.11
Nodes (17): MusicManager, playMenuMusic, stop, _BoardPainter, Color, dispose, _drawCell, _ensureInitialized (+9 more)

### Community 12 - "Community 12"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 13 - "Community 13"
Cohesion: 0.49
Nodes (9): generate_sweep(), generate_tone(), make_berakhir(), make_drop(), make_hapus(), make_menu_theme(), make_rotate(), note_freq() (+1 more)

### Community 14 - "Community 14"
Cohesion: 0.29
Nodes (2): FlutterAppDelegate, AppDelegate

### Community 15 - "Community 15"
Cohesion: 0.29
Nodes (6): HardDropIntent, MoveLeftIntent, MoveRightIntent, RotateIntent, SoftDropIntent, package:flutter/widgets.dart

### Community 16 - "Community 16"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 17 - "Community 17"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 18 - "Community 18"
Cohesion: 0.4
Nodes (2): RunnerTests, XCTestCase

### Community 19 - "Community 19"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 20 - "Community 20"
Cohesion: 0.67
Nodes (1): GeneratedPluginRegistrant

### Community 21 - "Community 21"
Cohesion: 0.67
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 22 - "Community 22"
Cohesion: 0.67
Nodes (2): Getting Started, tetris

### Community 23 - "Community 23"
Cohesion: 1.0
Nodes (1): MainActivity

### Community 24 - "Community 24"
Cohesion: 1.0
Nodes (1): Launch Screen Assets

## Knowledge Gaps
- **362 isolated node(s):** `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `main`, `src/app.dart` (+357 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 14`** (7 nodes): `FlutterAppDelegate`, `AppDelegate.swift`, `AppDelegate.swift`, `AppDelegate`, `.application()`, `.applicationShouldTerminateAfterLastWindowClosed()`, `.applicationSupportsSecureRestorableState()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 18`** (5 nodes): `RunnerTests.swift`, `RunnerTests.swift`, `RunnerTests`, `.testExample()`, `XCTestCase`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 19`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 20`** (3 nodes): `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant`, `.registerWith()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 21`** (3 nodes): `GeneratedPluginRegistrant.m`, `GeneratedPluginRegistrant`, `-registerWithRegistry`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 22`** (3 nodes): `README.md`, `Getting Started`, `tetris`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 23`** (2 nodes): `MainActivity.kt`, `MainActivity`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 24`** (2 nodes): `README.md`, `Launch Screen Assets`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 2` to `Community 0`, `Community 1`, `Community 3`, `Community 4`, `Community 6`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`?**
  _High betweenness centrality (0.270) - this node is a cross-community bridge._
- **Why does `package:google_fonts/google_fonts.dart` connect `Community 3` to `Community 0`, `Community 1`, `Community 6`, `Community 8`, `Community 9`, `Community 10`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **Why does `dart:math` connect `Community 4` to `Community 0`, `Community 2`, `Community 6`, `Community 7`, `Community 11`?**
  _High betweenness centrality (0.067) - this node is a cross-community bridge._
- **What connects `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry` to the rest of the system?**
  _362 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.02 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:collection';
import '../l10n/app_localizations.dart';
import '../models/game_level_model.dart';
import '../services/ad_service.dart';
import '../services/api_service.dart';
import '../services/game_data_manager.dart';
import '../services/island_catalog.dart';
import '../services/level_generator.dart';
import '../services/puzzle_solver.dart';
import '../services/sound_service.dart';
import '../widgets/remove_ads_promo.dart';
import 'level_selection_screen.dart';

/// Snapshot of color-mode board state for undo (one entry per pan gesture).
class _ColorSnapshot {
  final Map<DotColor, List<GridPoint>> paths;
  final Set<DotColor> lockedPaths;

  const _ColorSnapshot({required this.paths, required this.lockedPaths});
}

class GameScreen extends StatefulWidget {
  final GameLevel level;
  final String? dotAssetPath;
  final String islandId;
  final int levelId;

  const GameScreen({
    super.key, 
    required this.level,
    this.dotAssetPath,
    required this.islandId,
    required this.levelId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Game State - Color Dots
  final Map<DotColor, List<GridPoint>> _paths = {};
  DotColor? _activeColor;
  
  // Game State - Number Path
  List<GridPoint> _numberPath = []; // Sequential path for number puzzles
  Map<GridPoint, int> _playerNumbers = {}; // Numbers filled by player
  
  // Timer State
  Timer? _gameTimer;
  int _remainingSeconds = 0;
  int _totalTime = 0;
  bool _isGameActive = false;
  // True when the countdown was paused because the app went to the background
  // (or a full-screen ad took over), so we know to resume it on return.
  bool _pausedByLifecycle = false;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _flowController; 
  late AnimationController _backgroundController; 
  late AnimationController _handController; 
  late AnimationController _confettiController; // NEW: Confetti Physics

  // Particles
  final List<_SpaceParticle> _bgParticles = [];
  final List<_ConfettiParticle> _confettiParticles = []; // NEW: Confetti

  // Win State
  bool _showWinUI = false;
  bool _showFailedUI = false; // NEW: Failed state
  bool _hasStarted = false; // New State
  int _earnedStars = 0;
  
  // Hint System
  Timer? _inactivityTimer;
  Timer? _hintTimer;
  bool _showHint = false;
  
  // Path Locking & Game State
  final Set<DotColor> _lockedPaths = {};
  bool _showLevelAnnouncement = false;
  bool _showAlmostThereUI = false;
  bool _showTimeUpUI = false; // NEW: time-up dialog (watch ad +30s / restart)
  bool _showIslandComplete = false; // NEW: island finished celebration before next island
  String _nextIslandName = "";
  int _targetLevelId = 0;

  // Hint System
  bool _hintUsed = false;
  bool _isHintAnimating = false;

  // Color-mode undo (one free per level, then rewarded ad per undo).
  static const int _maxUndoSnapshots = 30;
  final List<_ColorSnapshot> _colorUndoStack = [];
  bool _freeUndoUsed = false;
  _ColorSnapshot? _gestureUndoBaseline;
  bool _gestureModified = false;

  // Extra seconds granted per rewarded "continue" ad.
  static const int _rewardExtraSeconds = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _startGame(); // WAIT for user input
    
    // Existing Animations
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _flowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
    _backgroundController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    
    // Confetti Animation (runs physics loop)
    _confettiController = AnimationController(vsync: this, duration: const Duration(seconds: 10)); // Long duration for simulation
    _confettiController.addListener(_updateConfetti);

    // BG Particles
    final r = math.Random();
    for(int i=0; i<40; i++) {
        _bgParticles.add(_SpaceParticle(
            x: r.nextDouble(), 
            y: r.nextDouble(), 
            size: r.nextDouble() * 3 + 1, 
            speed: r.nextDouble() * 0.05 + 0.01,
            opacity: r.nextDouble() * 0.5 + 0.1
        ));
    }

    _handController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    // Hand animation starts ONLY when game starts
    
    // Initialize path state if needed
    if (widget.level.gameType == GameType.numberPath || widget.level.gameType == GameType.operationPath) {
      _playerNumbers = widget.level.gameType == GameType.numberPath 
          ? Map.from(widget.level.fixedNumbers ?? {})
          : (widget.level.startNode != null ? {widget.level.startNode!: widget.level.startValue} : {});
    }
    
    // Load hint status
    _loadGameState();
  }
  
  Future<void> _loadGameState() async {
    final hintUsed = GameDataManager().isHintUsed(widget.islandId, widget.levelId);
    setState(() {
      _hintUsed = hintUsed;
    });
  }



  void _startGame() {
      _hasStarted = true;
      _isGameActive = true;
      _totalTime = widget.level.timeLimit;
      _remainingSeconds = _totalTime;
      _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
              if (_remainingSeconds > 0) {
                  _remainingSeconds--;
              } else {
                  _handleTimeout();
              }
          });
      });
      if (widget.level.id == 1) _handController.repeat(); 
      if (widget.level.id == 2) _resetInactivityTimer(); // Start hint timer for Level 2
  }

  void _resetInactivityTimer() {
      if (widget.level.id != 2) return; // Only for Level 2 per request

      _inactivityTimer?.cancel();
      _hintTimer?.cancel();
      if (_showHint) {
          setState(() => _showHint = false);
      }

      _inactivityTimer = Timer(const Duration(seconds: 10), () {
          if (!mounted || !_isGameActive) return;
          setState(() => _showHint = true);
          // Hide after 2 seconds
          _hintTimer = Timer(const Duration(seconds: 2), () {
               if (mounted) setState(() => _showHint = false);
          });
      });
  }


  void _stopGame() {
      _isGameActive = false;
      _gameTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Only resume if we paused the countdown ourselves and the game is still
      // in a live, playable state (not won/failed/timed-out).
      final bool canResume = _pausedByLifecycle &&
          _isGameActive &&
          _hasStarted &&
          _remainingSeconds > 0 &&
          !_showWinUI &&
          !_showFailedUI &&
          !_showTimeUpUI;
      _pausedByLifecycle = false;
      if (canResume) _resumeTimer();
    } else {
      // App is leaving the foreground (inactive/paused/hidden/detached) or a
      // full-screen ad is taking over: freeze the countdown so time can't drain
      // off-screen.
      if (_isGameActive && _gameTimer != null) {
        _pausedByLifecycle = true;
        _gameTimer?.cancel();
        _gameTimer = null;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameTimer?.cancel();
    _inactivityTimer?.cancel();
    _hintTimer?.cancel();
    _pulseController.dispose();
    _flowController.dispose();
    _backgroundController.dispose();
    _handController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _handleTimeout() {
      _stopGame();
      SoundService().playError();
      // Offer to continue with a rewarded ad (+30s) or restart the level.
      setState(() {
          _showTimeUpUI = true;
      });
  }

  /// Resumes the countdown after a rewarded "continue" without resetting the
  /// board.
  void _resumeTimer() {
      _isGameActive = true;
      _gameTimer?.cancel();
      _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
              if (_remainingSeconds > 0) {
                  _remainingSeconds--;
              } else {
                  _handleTimeout();
              }
          });
      });
  }

  /// Freezes the countdown while a full-screen ad is on screen. This is
  /// independent of the app-lifecycle hook because ad SDKs don't always emit a
  /// reliable background/foreground event (especially on iOS).
  void _pauseTimerForAd() {
      if (_gameTimer != null) {
          _gameTimer?.cancel();
          _gameTimer = null;
      }
  }

  /// Restarts the countdown after an ad closes, but only if the game is still in
  /// a live, playable state.
  void _resumeTimerAfterAd() {
      if (!mounted) return;
      _pausedByLifecycle = false;
      final bool canResume = _isGameActive &&
          _hasStarted &&
          _remainingSeconds > 0 &&
          _gameTimer == null &&
          !_showWinUI &&
          !_showFailedUI &&
          !_showTimeUpUI;
      if (canResume) _resumeTimer();
  }

  Future<void> _continueWithRewardedAd() async {
      bool rewarded = false;
      await AdService().showRewarded(onReward: () {
          rewarded = true;
      });
      if (!mounted) return;
      if (rewarded) {
          setState(() {
              _showTimeUpUI = false;
              _remainingSeconds += _rewardExtraSeconds;
          });
          _resumeTimer();
      } else {
          // Ad not available or skipped: fall back to restarting the level.
          setState(() {
              _showTimeUpUI = false;
          });
          _resetGame();
      }
  }

  String _formatTime() {
      int minutes = (_remainingSeconds / 60).floor();
      int seconds = _remainingSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false, // Prevent layout shifts
      appBar: AppBar(
        toolbarHeight: 80, // Increased height for larger buttons
        // NEW: Timer Display in Title
        title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 22),
                    const SizedBox(width: 4),
                    Text(
                        _formatTime(), 
                        style: TextStyle(
                            fontFamily: 'monospace', 
                            fontWeight: FontWeight.w800,
                            color: _remainingSeconds <= 10 ? Colors.redAccent : Colors.white,
                            fontSize: 22,
                            letterSpacing: 1.0,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 10)]
                        )
                    ),
                    const SizedBox(width: 8), // Replaced pOnly with SizedBox
                ],
            ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Removed background color
        elevation: 0,
        leadingWidth: 100, // accommodate larger back button
        leading: Center(
            child: _BouncingButton(
                onTap: () => Navigator.pop(context),
                child: Container(
                    width: 70, height: 45, // Oval shape matching LevelSelection
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFAB40), Color(0xFFFF6D00)], // Vivid Orange
                        ),
                        borderRadius: BorderRadius.circular(22.5),
                        border: Border.all(color: Colors.black, width: 2.5),
                        boxShadow: [
                            BoxShadow(color: Colors.black, offset: const Offset(0, 3), blurRadius: 0),
                        ]
                    ),
                    child: const Center(
                        child: Icon(Icons.close_rounded, color: Colors.black, size: 28)
                    ),
                ),
            ),
        ),
        actions: [
            // Redesigned Hint Button (Larger, Amber, Circular)
            Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ValueListenableBuilder<bool>(
                        valueListenable: AdService().rewardedReady,
                        builder: (context, adReady, _) {
                        final bool isColor = widget.level.gameType == GameType.colorDots;
                        final bool extraHintMode = _hintUsed && isColor;
                        final bool freeHintAvailable = !_hintUsed;
                        final bool adHintReady = extraHintMode && adReady;
                        final bool wantsAdHint = extraHintMode &&
                            !adReady &&
                            _isGameActive &&
                            !_isHintAnimating;
                        final bool enabled = _isGameActive &&
                            !_isHintAnimating &&
                            (freeHintAvailable || adHintReady);
                        VoidCallback onTap;
                        if (freeHintAvailable && _isGameActive && !_isHintAnimating) {
                            onTap = _useHint;
                        } else if (adHintReady) {
                            onTap = _useExtraHintViaAd;
                        } else if (wantsAdHint) {
                            onTap = _showNoAdSnack;
                        } else {
                            onTap = () {};
                        }
                        final Color accent = freeHintAvailable && enabled
                            ? Colors.amberAccent
                            : (adHintReady ? Colors.lightGreenAccent : Colors.grey);
                        return _BouncingButton(
                            onTap: onTap,
                            child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                    Container(
                                        width: 58, height: 58,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF2A2A1A),
                                            border: Border.all(color: accent, width: 3),
                                            boxShadow: [
                                                if (enabled) BoxShadow(
                                                    color: accent.withValues(alpha: 0.4),
                                                    blurRadius: 12,
                                                    spreadRadius: 2,
                                                )
                                            ],
                                        ),
                                        child: Icon(
                                            Icons.lightbulb_rounded,
                                            color: accent,
                                            size: 32,
                                        ),
                                    ),
                                    if (extraHintMode && (adHintReady || wantsAdHint))
                                        Positioned(
                                            right: -2, bottom: -2,
                                            child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: const BoxDecoration(
                                                    color: Colors.black,
                                                    shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.play_circle_fill,
                                                    color: adHintReady
                                                        ? Colors.lightGreenAccent
                                                        : Colors.grey,
                                                    size: 18),
                                            ),
                                        ),
                                ],
                            ),
                        );
                    }),
                ),
            ),
            // Custom Larger Restart Button (Magenta, New Shape)
            Center(
                child: Padding(
                    padding: const EdgeInsets.only(right: 16, left: 4),
                    child: _BouncingButton(
                        onTap: _resetGame,
                        child: Container(
                            width: 58, height: 58,
                            decoration: BoxDecoration(
                                color: const Color(0xFF2A1A2A),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.pinkAccent, width: 3),
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.pinkAccent.withValues(alpha: 0.4), 
                                        blurRadius: 12, 
                                        spreadRadius: 2
                                    )
                                ]
                            ),
                            child: const Icon(Icons.refresh_rounded, color: Colors.pinkAccent, size: 36),
                        ),
                    ),
                ),
            ),
        ],
      ),
      body: Stack(
        children: [
            // 1. BG
            AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) => CustomPaint(size: Size.infinite, painter: _SpaceBackgroundPainter(particles: _bgParticles, animValue: _backgroundController.value)),
            ),

            // 2. Game Content
            SafeArea(
                child: Center(
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                            // Calculate safe size: Use smallest dimension, leaving vertical space for header/footer
                            // Header is AppBar (implicit), Footer is text + gap (~80px)
                            double maxW = constraints.maxWidth - 48; // Padding
                            double maxH = constraints.maxHeight - 140; // Top bar space + Footer space
                            
                            double gridSize = math.max(0.0, math.min(maxW, maxH));
                            if (gridSize <= 0) return const SizedBox();
                            
                            return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    if (widget.level.gameType == GameType.colorDots && _hasStarted)
                                        Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: SizedBox(
                                                width: gridSize,
                                                child: Align(
                                                    alignment: Alignment.centerRight,
                                                    child: ValueListenableBuilder<bool>(
                                                        valueListenable: AdService().rewardedReady,
                                                        builder: (_, adReady, __) =>
                                                            _buildUndoButton(adReady),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    Container(
                                        width: gridSize,
                                        height: gridSize,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: -10)]
                                        ),
                                        // Pass the explicit size down
                                        child: Stack(
                                            alignment: Alignment.topLeft, // Ensure coordinate origin
                                            children: [
                                                CustomPaint(size: Size(gridSize, gridSize), painter: _NeonGridPainter(rows: widget.level.rows, cols: widget.level.cols)),
                                                AnimatedBuilder(animation: _flowController, builder: (_,__) => CustomPaint(size: Size(gridSize, gridSize), painter: _NeonPathPainter(level: widget.level, paths: _paths, cellSize: gridSize / widget.level.cols, flowPhase: _flowController.value, lockedPaths: _lockedPaths, numberPath: _numberPath, playerNumbers: _playerNumbers))),
                                                AnimatedBuilder(animation: _pulseController, builder: (_,__) => CustomPaint(size: Size(gridSize, gridSize), painter: _NeonNodePainter(level: widget.level, cellSize: gridSize / widget.level.cols, pulseValue: _pulseController.value, playerNumbers: _playerNumbers))),
                                                
                                                // Input
                                                GestureDetector(
                                                    onPanStart: _isGameActive ? (d) => _handleInputStart(d, gridSize) : null,
                                                    onPanUpdate: _isGameActive ? (d) => _handleInputUpdate(d, gridSize) : null,
                                                    onPanEnd: _isGameActive ? (_) => _handleInputEnd() : null,
                                                    behavior: HitTestBehavior.opaque, // Prevent event leak
                                                    child: Container(width: gridSize, height: gridSize, color: Colors.transparent),
                                                ),
                                                
                                                if (widget.level.id == 1 && _paths.isEmpty && _numberPath.isEmpty) _buildTutorialOverlay(gridSize / widget.level.cols),
                                            ],
                                        ),
                                    ),
                                    const SizedBox(height: 40),
                                    // Footer Level Info
                                    Text(
                                        "LEVEL ${widget.level.id}",
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 18, letterSpacing: 2),
                                    )
                                ],
                            );
                        },
                    ),
                ),
            ),
            
            // 3. Confetti Layer (Behind Win Dialog)
            if (_showWinUI)
                IgnorePointer(
                    child: AnimatedBuilder(
                        animation: _confettiController,
                        builder: (context, child) => CustomPaint(
                            size: Size.infinite,
                            painter: _ConfettiPainter(particles: _confettiParticles),
                        ),
                    ),
                ),

            // 4. Start Overlay (New)
            if (!_hasStarted) _buildStartOverlay(),

            // 6. Win Dialog Overlay
            if (_showWinUI) _buildWinOverlay(),
            
            // 7. Ad Overlay
            if (_showTimeUpUI) _buildTimeUpOverlay(),

            // 8. Level Announcement Overlay
            if (_showLevelAnnouncement) _buildLevelAnnouncementOverlay(),

            // 9. Almost There overlay (color: all pairs connected, board not full)
            if (_showAlmostThereUI) _buildAlmostThereOverlay(),

            // 10. Failed Overlay (New)
            if (_showFailedUI) _buildFailedOverlay(),

            // 11. Island Complete celebration (before sailing to next island)
            if (_showIslandComplete) _buildIslandCompleteOverlay(),
        ],
      ),
    );
  }

  // --- LOGIC ---

  void _updateConfetti() {
      // Simple Physics Step
      for (var p in _confettiParticles) {
          p.x += p.vx;
          p.y += p.vy;
          p.vy += 0.2; // Gravity
          p.rotation += p.rotSpeed;
          p.opacity -= 0.005; // Fade out slowly
      }
      // Remove dead particles
      _confettiParticles.removeWhere((p) => p.y > MediaQuery.of(context).size.height || p.opacity <= 0);
  }

  void _triggerConfetti() {
      SoundService().playWin();
      // Explosion from center
      final r = math.Random();
      final double cx = MediaQuery.of(context).size.width / 2;
      final double cy = MediaQuery.of(context).size.height / 2;

      for (int i=0; i<100; i++) {
          double angle = r.nextDouble() * 2 * math.pi;
          double speed = r.nextDouble() * 15 + 5;
          _confettiParticles.add(_ConfettiParticle(
              x: cx, 
              y: cy, 
              vx: math.cos(angle) * speed, 
              vy: math.sin(angle) * speed - 5, // Upward bias
              color: [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple][r.nextInt(5)],
              size: r.nextDouble() * 8 + 4,
              rotation: r.nextDouble() * 360,
              rotSpeed: r.nextDouble() * 10 - 5,
              opacity: 1.0
          ));
      }
      _confettiController.repeat();
  }

  // Removed legacy method

  /// Computes stars from the remaining-time ratio. Guards against a zero
  /// [_totalTime] (which would make the ratio NaN/infinite).
  int _starsForRemainingTime() {
    if (_totalTime <= 0) return 1;
    final double ratio = _remainingSeconds / _totalTime;
    if (ratio > 0.70) return 3;
    if (ratio > 0.40) return 2;
    return 1;
  }

  /// Persists the earned stars the moment a level is won so progress is never
  /// lost if the player leaves before pressing CONTINUE. saveStars only ever
  /// upgrades the stored value, so re-saving on CONTINUE is harmless.
  void _persistProgress() {
    GameDataManager().saveStars(widget.islandId, widget.levelId, _earnedStars);
  }

  void _checkWin() {
    // OPERATION PATH MODE
    if (widget.level.gameType == GameType.operationPath) {
      if (widget.level.validateOperationPath(_numberPath)) {
        _stopGame();
        
        _earnedStars = _starsForRemainingTime();
        _persistProgress();
        
        setState(() {
          _showWinUI = true;
        });
        _triggerConfetti();
      } else {
        // NEW: Check if path reached target but failed validation (wrong value or incomplete grid)
        if (_numberPath.isNotEmpty && _numberPath.last == widget.level.targetNode) {
          _stopGame();
          SoundService().playError();
          setState(() {
            _showFailedUI = true;
          });
        }
      }
      return;
    }

    // NUMBER PATH MODE
    if (widget.level.gameType == GameType.numberPath) {
      final totalCells = widget.level.rows * widget.level.cols;
      
      // Check if all cells are filled
      if (_playerNumbers.length == totalCells) {
        // The drawn path must be a Hamiltonian path: it visits every cell on
        // the grid exactly once. Without this check, fixed clue cells that are
        // pre-seeded into _playerNumbers could stay off the path while the board
        // still counts as "full".
        final bool pathCoversBoard = _numberPath.length == totalCells &&
            _numberPath.toSet().length == totalCells;

        // Check if path is sequential from startValue
        bool isSequential = true;
        int startVal = widget.level.startNode != null ? widget.level.startValue : 1;
        int endVal = startVal + totalCells - 1;
        
        for (int i = startVal; i <= endVal; i++) {
          if (!_playerNumbers.containsValue(i)) {
            isSequential = false;
            break;
          }
        }
        
        if (pathCoversBoard && isSequential) {
          // --- BUG FIX: Check if the LAST point on path is actually the END value ---
          if (_numberPath.isNotEmpty) {
              final lastPt = _numberPath.last;
              if (_playerNumbers[lastPt] != endVal) {
                  return; // Not reached yet
              }
          }

          _stopGame();
          
          _earnedStars = _starsForRemainingTime();
          _persistProgress();
          
          setState(() {
            _showWinUI = true;
          });
          _triggerConfetti();
        } else {
          // Board is full but the path is invalid (skipped cells / not
          // sequential): surface the failure instead of leaving the player in
          // limbo with no feedback.
          _stopGame();
          SoundService().playError();
          setState(() {
            _showFailedUI = true;
          });
        }
      }
      return;
    }
    
    // COLOR DOT MODE (original logic)
    bool allConnected = true;
    Set<GridPoint> filled = {};
    int totalPathCells = 0;

    widget.level.dotPositions.forEach((color, nodes) {
        if (!_paths.containsKey(color)) { allConnected = false; return; }
        final path = _paths[color]!;
        if (path.isEmpty) { allConnected = false; return; }
        bool startOk = (path.first == nodes[0] && path.last == nodes[1]);
        bool reverseOk = (path.first == nodes[1] && path.last == nodes[0]);
        
        // Check if path is complete and lock it
        if (startOk || reverseOk) {
            if (!_lockedPaths.contains(color)) {
                SoundService().playConnect();
                setState(() {
                    _lockedPaths.add(color);
                });
            }
        } else {
            allConnected = false;
        }
        
        filled.addAll(path);
        totalPathCells += path.length;
    });

    if (!allConnected) return;

    // Flow-Free rule: paths must be cell-disjoint. If the summed path lengths
    // exceed the unique covered cells, two paths overlap and the board is not a
    // valid solution even when every cell happens to be touched.
    final bool disjoint = totalPathCells == filled.length;
    bool boardFull = disjoint && filled.length == (widget.level.rows * widget.level.cols);
    
    if (boardFull) {
        _stopGame();
        _earnedStars = _starsForRemainingTime();
        _persistProgress();

        setState(() {
            _showWinUI = true;
        });
        _triggerConfetti();
    } else {
        // All pairs connected but board isn't full — paths are locked and
        // can't be fixed; end the round instead of letting the timer drain.
        _stopGame();
        SoundService().playError();
        setState(() {
            _showAlmostThereUI = true;
        });
    }
  }

  /// Called from the win overlay's CONTINUE button on the final level of an
  /// island. Plays an "island complete" celebration and then sails to the next
  /// island's level map. If there is no next playable island, simply returns to
  /// the current island map.
  Future<void> _goToNextIslandOrExit() async {
      final nextIsland = IslandCatalog.nextPlayable(widget.islandId);

      if (nextIsland == null) {
          if (mounted) Navigator.pop(context, _earnedStars);
          return;
      }

      // Capture the navigator before any awaits/pops invalidate this context.
      final navigator = Navigator.of(context);

      setState(() {
          _nextIslandName = nextIsland.name;
          _showIslandComplete = true;
      });
      SoundService().playWin();

      await Future.delayed(const Duration(milliseconds: 2600));
      if (!mounted) return;

      // Pop back to the world map (first route) then open the next island so
      // the back button returns to the world map rather than this game screen.
      navigator.popUntil((route) => route.isFirst);
      navigator.push(
          PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 700),
              pageBuilder: (_, __, ___) => LevelSelectionScreen(island: nextIsland),
              transitionsBuilder: (ctx, anim, _, child) =>
                  FadeTransition(opacity: anim, child: child),
          ),
      );
  }

  Widget _buildIslandCompleteOverlay() {
      return Stack(
          children: [
              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.85))),
              Center(
                  child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      builder: (context, t, child) => Transform.scale(
                          scale: 0.7 + (0.3 * t.clamp(0.0, 1.0)),
                          child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD54F), size: 90),
                                  const SizedBox(height: 20),
                                  Text(
                                      AppLocalizations.of(context).islandComplete,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: 1.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                      AppLocalizations.of(context).nextIslandUnlocking(_nextIslandName),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70, fontSize: 18, height: 1.4),
                                  ),
                                  const SizedBox(height: 28),
                                  const SizedBox(
                                      width: 30, height: 30,
                                      child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFFFFD54F)),
                                  ),
                              ],
                          ),
                      ),
                  ),
              ),
          ],
      );
  }

  Widget _buildWinOverlay() {
      return Stack(
          children: [
              // Darken BG
              Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.7)),
              ),
              Center(
                  child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                          return Transform.scale(
                              scale: value,
                              child: Container(
                                  padding: const EdgeInsets.all(30),
                                  margin: const EdgeInsets.symmetric(horizontal: 40),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E2C),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: Colors.white24, width: 1),
                                      boxShadow: [
                                          BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.5), blurRadius: 50, spreadRadius: 0)
                                      ]
                                  ),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          Text(AppLocalizations.of(context).levelComplete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28, fontFamily: 'Comic Sans MS')),
                                          const SizedBox(height: 10),
                                          Text(AppLocalizations.of(context).timeLeft(_formatTime()), style: const TextStyle(color: Colors.white70, fontSize: 18)),
                                          const SizedBox(height: 20),
                                          // Stars
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List.generate(3, (i) {
                                                  if (i >= _earnedStars) return const Icon(Icons.star_border, color: Colors.grey, size: 50);
                                                  return TweenAnimationBuilder<double>(
                                                      tween: Tween(begin: 0.0, end: 1.0),
                                                      duration: Duration(milliseconds: 400 + (i * 200)), // Staggered
                                                      curve: Curves.elasticOut,
                                                      builder: (ctx, val, _) => Transform.scale(
                                                          scale: val,
                                                          child: const Icon(Icons.star, color: Colors.amber, size: 50),
                                                      ),
                                                  );
                                              }),
                                          ),
                                          const SizedBox(height: 30),
                                          // Buttons
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                  IconButton(
                                                      icon: const Icon(Icons.replay_rounded, color: Colors.redAccent),
                                                      onPressed: _resetGame,
                                                      iconSize: 60, // Larger red icon
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                  ),
                                                  _BouncingButton(
                                                      onTap: () async {
                                                          // 1. Save progress
                                                          await GameDataManager().saveStars(widget.islandId, widget.levelId, _earnedStars);

                                                          // 1a. Publish updated stars/plays to the backend (fire-and-forget, offline-safe)
                                                          ApiService().heartbeat();

                                                          // 1b. Occasionally show an interstitial (skipped if ads removed)
                                                          final bool interstitialShown = await AdService().onLevelCompleted();
                                                          if (!mounted) return;

                                                          // 1c. If no interstitial showed, occasionally offer "Remove Ads"
                                                          // (cadence-limited; no-op if already ad-free).
                                                          if (!interstitialShown) {
                                                              await maybeShowRemoveAdsPromo(context);
                                                              if (!mounted) return;
                                                          }

                                                          // 2. Load next level if one exists on THIS island. Each
                                                          // island has its own level count (Logic Core has 35, not
                                                          // 50), so using a per-island count avoids advancing past
                                                          // the last level into a fallback of the wrong game type.
                                                          final int islandLevelCount =
                                                              GameDataManager.islandLevelCounts[widget.islandId] ?? 50;
                                                          if (widget.levelId < islandLevelCount && mounted) {
                                                              final nextLevelId = widget.levelId + 1;
                                                              
                                                              // NEW: Show Level Announcement First
                                                              setState(() {
                                                                  _targetLevelId = nextLevelId;
                                                                  _showLevelAnnouncement = true;
                                                              });
                                                              
                                                              await Future.delayed(const Duration(milliseconds: 2000));
                                                              
                                                              if (!mounted) return;

                                                              final nextGameLevel = LevelGenerator.generate(nextLevelId, islandId: widget.islandId);
                                                              
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  PageRouteBuilder(
                                                                      transitionDuration: const Duration(milliseconds: 600),
                                                                      pageBuilder: (_, __, ___) => GameScreen(
                                                                          level: nextGameLevel,
                                                                          dotAssetPath: widget.dotAssetPath,
                                                                          islandId: widget.islandId,
                                                                          levelId: nextLevelId,
                                                                      ),
                                                                      transitionsBuilder: (ctx, anim, _, child) {
                                                                          return FadeTransition(
                                                                              opacity: anim,
                                                                              child: ScaleTransition(
                                                                                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                                                                                      CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                                                                                  ),
                                                                                  child: child,
                                                                              ),
                                                                          );
                                                                      },
                                                                  ),
                                                              );
                                                          } else {
                                                              // Last level of this island finished. If a next
                                                              // playable island exists, celebrate and sail to it.
                                                              await _goToNextIslandOrExit();
                                                          }
                                                      },
                                                      child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                                          decoration: BoxDecoration(
                                                              gradient: const LinearGradient(
                                                                  begin: Alignment.topLeft,
                                                                  end: Alignment.bottomRight,
                                                                  colors: [Color(0xFFFFAB40), Color(0xFFFF6D00)],
                                                              ),
                                                              borderRadius: BorderRadius.circular(30),
                                                              border: Border.all(color: Colors.black, width: 2),
                                                              boxShadow: [
                                                                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), offset: const Offset(0, 4), blurRadius: 4)
                                                              ]
                                                          ),
                                                          child: Text(
                                                              AppLocalizations.of(context).continueButton,
                                                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)
                                                          ),
                                                      ),
                                                  )
                                              ],
                                          )
                                      ],
                                  ),
                              ),
                          );
                      },
                  ),
              )
          ],
      );
  }

  Widget _buildLevelAnnouncementOverlay() {
      return Stack(
          children: [
              Positioned.fill(
                  child: Container(
                      color: Colors.black.withValues(alpha: 0.9),
                      child: Center(
                          child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                  return Transform.scale(
                                      scale: value,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                              Text(
                                                  AppLocalizations.of(context).levelLabel,
                                                  style: TextStyle(
                                                      color: Colors.white.withValues(alpha: 0.7),
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.w300,
                                                      letterSpacing: 10,
                                                  ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                  "$_targetLevelId",
                                                  style: TextStyle(
                                                      color: Colors.cyanAccent,
                                                      fontSize: 120,
                                                      fontWeight: FontWeight.w900,
                                                      shadows: [
                                                          Shadow(color: Colors.cyanAccent.withValues(alpha: 0.8), blurRadius: 40),
                                                          Shadow(color: Colors.cyanAccent.withValues(alpha: 0.5), blurRadius: 80),
                                                      ]
                                                  ),
                                              ),
                                          ],
                                      ),
                                  );
                              },
                          ),
                      ),
                  ),
              ),
          ],
      );
  }

  Widget _buildStartOverlay() {
      return Stack(
          children: [
               // Blur BG
               Positioned.fill(
                   child: BackdropFilter(
                       filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                       child: Container(color: const Color(0xFF001A04).withValues(alpha: 0.75)), // Deep Green/Black tint
                   ),
               ),
               Center(
                   child: TweenAnimationBuilder<double>(
                       tween: Tween(begin: 0.0, end: 1.0),
                       duration: const Duration(milliseconds: 800),
                       curve: Curves.elasticOut,
                       builder: (ctx, val, child) {
                           return Transform.scale(
                               scale: val,
                               child: GestureDetector(
                                   onTap: () {
                                       setState(() {
                                           _startGame();
                                       });
                                   },
                                   child: Container(
                                       width: 140, height: 140, 
                                       decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           // Premium Neon Gradient
                                           gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                  Color(0xFFCCFF90), // Light Lime (Highlight)
                                                  Color(0xFF76FF03), // Neon Green
                                                  Color(0xFF00C853), // Darker Green
                                              ],
                                              stops: [0.1, 0.5, 1.0],
                                           ),
                                           boxShadow: [
                                               // 1. Bright Core Glow
                                               BoxShadow(color: const Color(0xFF76FF03).withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 0),
                                               // 2. Wide Ambient Glow
                                               BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10),
                                               // 3. Bottom Depth Shadow
                                               BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15, offset: const Offset(0, 8)),
                                           ],
                                           // Matching Green Border
                                           border: Border.all(color: const Color(0xFFB2FF59).withValues(alpha: 0.9), width: 3), 
                                       ),
                                       child: Container(
                                           // Inner subtle gradient for 3D feel
                                           decoration: BoxDecoration(
                                               shape: BoxShape.circle,
                                               gradient: LinearGradient(
                                                   begin: Alignment.topCenter,
                                                   end: Alignment.bottomCenter,
                                                   colors: [
                                                       Colors.white.withValues(alpha: 0.3),
                                                       Colors.transparent,
                                                       Colors.black.withValues(alpha: 0.1),
                                                   ]
                                               )
                                           ),
                                           child: const Center(
                                               child: Icon(
                                                   Icons.play_arrow_rounded, 
                                                   color: Colors.white, 
                                                   size: 80, 
                                                   // Sharp shadow to make icon pop
                                                   shadows: [BoxShadow(color: Colors.black38, blurRadius: 5, offset: Offset(2,2))]
                                               ),
                                           ),
                                       ),
                                   ),
                               ),
                           );
                       },
                   ),
               )
          ],
      );
  }
  

  

  
  Widget _buildTimeUpOverlay() {
      final bool canWatch = AdService().isRewardedReady;
      return Center(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.orangeAccent, width: 3),
                  boxShadow: [
                      BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.4), blurRadius: 28)
                  ],
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      const Icon(Icons.timer_off_rounded, color: Colors.orangeAccent, size: 72),
                      const SizedBox(height: 16),
                      Text(
                          AppLocalizations.of(context).timesUp,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: 2),
                      ),
                      const SizedBox(height: 24),
                      // Only show the rewarded "continue" button when an ad is
                      // actually ready; otherwise show a clear unavailable state
                      // instead of a dead, greyed-out button.
                      if (canWatch)
                          _BouncingButton(
                              onTap: _continueWithRewardedAd,
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B0FF)]),
                                      borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                          const Icon(Icons.play_circle_fill, color: Colors.white),
                                          const SizedBox(width: 10),
                                          Text(AppLocalizations.of(context).watchAdContinue,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                      ],
                                  ),
                              ),
                          )
                      else
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      const Icon(Icons.hourglass_empty_rounded, color: Colors.white54, size: 18),
                                      const SizedBox(width: 10),
                                      Text(AppLocalizations.of(context).noAdAvailable,
                                          style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, fontSize: 15)),
                                  ],
                              ),
                          ),
                      const SizedBox(height: 12),
                      _BouncingButton(
                          onTap: () {
                              setState(() => _showTimeUpUI = false);
                              _resetGame();
                          },
                          child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(AppLocalizations.of(context).restart,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                      ),
                  ],
              ),
          ),
      );
  }

  // Removed legacy _buildGameOverOverlay 

  Widget _buildAlmostThereOverlay() {
      const Color accent = Colors.amberAccent;
      final t = AppLocalizations.of(context);
      return Stack(
          children: [
              Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.75)),
              ),
              Center(
                  child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) => Transform.scale(
                          scale: scale.clamp(0.0, 1.0),
                          child: child,
                      ),
                      child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                          decoration: BoxDecoration(
                              color: const Color(0xFF1E1E2C),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: accent, width: 3),
                              boxShadow: [
                                  BoxShadow(
                                      color: accent.withValues(alpha: 0.45),
                                      blurRadius: 32,
                                      spreadRadius: 0,
                                  ),
                              ],
                          ),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  Container(
                                      width: 88,
                                      height: 88,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF2A2A1A),
                                          border: Border.all(color: accent, width: 3),
                                          boxShadow: [
                                              BoxShadow(
                                                  color: accent.withValues(alpha: 0.35),
                                                  blurRadius: 18,
                                                  spreadRadius: 2,
                                              ),
                                          ],
                                      ),
                                      child: Icon(
                                          Icons.star_half_rounded,
                                          color: accent,
                                          size: 52,
                                          shadows: [
                                              Shadow(
                                                  color: accent.withValues(alpha: 0.8),
                                                  blurRadius: 16,
                                              ),
                                          ],
                                      ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                      t.almostThereTitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                          letterSpacing: 2,
                                      ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                      t.almostThereBody,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 18,
                                          height: 1.35,
                                      ),
                                  ),
                                  const SizedBox(height: 28),
                                  _BouncingButton(
                                      onTap: () {
                                          setState(() => _showAlmostThereUI = false);
                                          _resetGame();
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          decoration: BoxDecoration(
                                              color: Colors.pinkAccent,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.pinkAccent.withValues(alpha: 0.4),
                                                      blurRadius: 12,
                                                      offset: const Offset(0, 4),
                                                  ),
                                              ],
                                          ),
                                          child: Text(
                                              t.restart,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  letterSpacing: 1.2,
                                              ),
                                          ),
                                      ),
                                  ),
                              ],
                          ),
                      ),
                  ),
              ),
          ],
      );
  }

  void _showNoAdSnack() {
      final msg = AppLocalizations.of(context).noAdAvailable;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(msg),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
          ),
      );
  }

  Widget _buildUndoButton(bool adReady) {
      final bool hasUndo = _colorUndoStack.isNotEmpty;
      final bool needsAd = _freeUndoUsed && hasUndo;
      final bool canUndo = _isGameActive &&
          !_isHintAnimating &&
          hasUndo &&
          (!needsAd || adReady);
      final bool wantsAdUndo = needsAd &&
          hasUndo &&
          !adReady &&
          _isGameActive &&
          !_isHintAnimating;
      final Color accent = canUndo
          ? (needsAd ? Colors.lightGreenAccent : const Color(0xFF4FC3F7))
          : Colors.grey;

      VoidCallback onTap;
      if (canUndo) {
          onTap = _useUndo;
      } else if (wantsAdUndo) {
          onTap = _showNoAdSnack;
      } else {
          onTap = () {};
      }

      return _BouncingButton(
          onTap: onTap,
          child: Semantics(
              label: AppLocalizations.of(context).undo,
              button: true,
              enabled: canUndo || wantsAdUndo,
              child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                      Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1A1A2A),
                              border: Border.all(color: accent, width: 2.5),
                              boxShadow: canUndo
                                  ? [
                                      BoxShadow(
                                          color: accent.withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                          ),
                          child: Icon(
                              Icons.undo_rounded,
                              color: accent,
                              size: 26,
                          ),
                      ),
                      if (needsAd && (canUndo || wantsAdUndo))
                          Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                      Icons.play_circle_fill,
                                      color: adReady
                                          ? Colors.lightGreenAccent
                                          : Colors.grey,
                                      size: 16,
                                  ),
                              ),
                          ),
                  ],
              ),
          ),
      );
  }

  Widget _buildFailedOverlay() {
      return Center(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.redAccent, width: 3),
                  boxShadow: [
                      BoxShadow(color: Colors.redAccent.withValues(alpha: 0.5), blurRadius: 30)
                  ],
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 80),
                      const SizedBox(height: 20),
                      Text(
                          AppLocalizations.of(context).failed,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 2),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          widget.level.gameType == GameType.operationPath
                            ? AppLocalizations.of(context).failReasonOperation
                            : AppLocalizations.of(context).failReasonPath,
                          style: const TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      const SizedBox(height: 30),
                      _BouncingButton(
                          onTap: () {
                              _resetGame();
                              setState(() {
                                  _showFailedUI = false;
                              });
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                      BoxShadow(color: Colors.redAccent.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))
                                  ],
                              ),
                              child: Text(
                                  AppLocalizations.of(context).playAgain,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                          ),
                      ),
                  ],
              ),
          ),
      );
  }
  

  void _resetGame() {
      _stopGame();
      _inactivityTimer?.cancel();
      _hintTimer?.cancel();
      _pausedByLifecycle = false;
      setState(() {
          _paths.clear();
          _numberPath.clear(); // Clear number path
          _activeColor = null;
          // Clear every transient/overlay flag so a stale fail/time-up/win
          // overlay can never linger over a freshly reset board.
          _showWinUI = false;
          _showFailedUI = false;
          _showTimeUpUI = false;
          _showAlmostThereUI = false;
          _showLevelAnnouncement = false;
          _showHint = false;
          _earnedStars = 0;
          _hasStarted = false; // SHOW START BUTTON
          _confettiParticles.clear();
          _lockedPaths.clear();
          _colorUndoStack.clear();
          _freeUndoUsed = false;
          _gestureUndoBaseline = null;
          _gestureModified = false;
          
          // Reset player numbers
          if (widget.level.gameType == GameType.numberPath || widget.level.gameType == GameType.operationPath) {
            _playerNumbers = widget.level.gameType == GameType.numberPath 
                ? Map.from(widget.level.fixedNumbers ?? {})
                : (widget.level.startNode != null ? {widget.level.startNode!: widget.level.startValue} : {});
          }
          
          if (widget.level.id == 1) _handController.repeat();
      });
      _loadGameState(); 
  }
  

  
  void _handlePathBreak(DotColor color) {
      // Path break logic: now we don't have lives/penalty overlay.
      // We could optionally reset the path or just let it be.
      // For now, let's keep it empty to fulfill "removing lives system".
  }
  
  // Hint System - BFS Pathfinding

  /// Reveals (animates) a solution hint. For colour levels it draws the first
  /// incomplete colour's path; for number/operation levels it advances the
  /// player's path a few steps along a real solution. Returns true if a hint
  /// was shown.
  Future<bool> _revealHint() async {
      if (widget.level.gameType == GameType.numberPath) {
          return _revealNumberHint();
      }
      if (widget.level.gameType == GameType.operationPath) {
          return _revealOperationHint();
      }
      // Find first incomplete color
      DotColor? targetColor;
      widget.level.dotPositions.forEach((color, nodes) {
          if (targetColor == null && !_lockedPaths.contains(color)) {
              targetColor = color;
          }
      });

      if (targetColor == null) return false;

      final nodes = widget.level.dotPositions[targetColor]!;
      final path = _findPath(nodes[0], nodes[1], targetColor!);

      if (path == null || path.isEmpty) return false;

      setState(() {
          _isHintAnimating = true;
      });

      // Animate path drawing
      _paths[targetColor!] = [path.first];
      for (int i = 1; i < path.length; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return true;
          setState(() {
              _paths[targetColor!]!.add(path[i]);
          });
      }

      setState(() {
          _isHintAnimating = false;
      });

      // Check win after hint completes
      _checkWin();
      return true;
  }

  /// Number hint: solves the puzzle on a background isolate and advances the
  /// player's path a few steps along a real solution (correcting wrong moves).
  Future<bool> _revealNumberHint() async {
      setState(() => _isHintAnimating = true);
      final solution = await PuzzleSolver.solveNumberPath(widget.level);
      if (!mounted) return true;
      if (solution == null || solution.isEmpty) {
          setState(() => _isHintAnimating = false);
          return false;
      }

      // How far the current path already matches the solution.
      int prefix = 0;
      while (prefix < _numberPath.length &&
             prefix < solution.length &&
             _numberPath[prefix] == solution[prefix]) {
          prefix++;
      }
      final int revealTo = math.min(solution.length, math.max(prefix + 4, 4));
      final int startVal = widget.level.startNode != null ? widget.level.startValue : 1;

      _numberPath = [];
      _playerNumbers = Map.from(widget.level.fixedNumbers ?? {});
      for (int i = 0; i < revealTo; i++) {
          await Future.delayed(const Duration(milliseconds: 80));
          if (!mounted) return true;
          setState(() {
              _numberPath.add(solution[i]);
              _playerNumbers[solution[i]] = startVal + i;
          });
      }

      setState(() => _isHintAnimating = false);
      _checkWin();
      return true;
  }

  /// Operation hint: solves on a background isolate and advances the player's
  /// path a few steps along a valid start->target solution.
  Future<bool> _revealOperationHint() async {
      setState(() => _isHintAnimating = true);
      final solution = await PuzzleSolver.solveOperationPath(widget.level);
      if (!mounted) return true;
      if (solution == null || solution.isEmpty) {
          setState(() => _isHintAnimating = false);
          return false;
      }

      int prefix = 0;
      while (prefix < _numberPath.length &&
             prefix < solution.length &&
             _numberPath[prefix] == solution[prefix]) {
          prefix++;
      }
      // Never auto-complete to the target via a hint; leave the final cell.
      final int revealTo =
          math.min(solution.length - 1, math.max(prefix + 4, 4)).clamp(0, solution.length);

      _numberPath = [];
      for (int i = 0; i < revealTo; i++) {
          await Future.delayed(const Duration(milliseconds: 80));
          if (!mounted) return true;
          setState(() {
              _numberPath.add(solution[i]);
          });
      }

      setState(() => _isHintAnimating = false);
      return true;
  }

  /// Free, once-per-level hint.
  Future<void> _useHint() async {
      if (_hintUsed || _isHintAnimating) return;
      final shown = await _revealHint();
      if (shown) {
          await GameDataManager().markHintUsed(widget.islandId, widget.levelId);
          if (mounted) setState(() => _hintUsed = true);
      }
  }

  /// Extra hint earned by watching a rewarded ad (Color island only).
  Future<void> _useExtraHintViaAd() async {
      if (_isHintAnimating || !_isGameActive) return;
      if (!AdService().isRewardedReady) {
          _showNoAdSnack();
          return;
      }
      _pauseTimerForAd();
      final earned = await AdService().showRewarded(onReward: () {});
      if (!mounted) return;
      _resumeTimerAfterAd();
      if (earned) {
          await _revealHint();
      } else {
          _showNoAdSnack();
      }
  }

  _ColorSnapshot _captureColorSnapshot() => _ColorSnapshot(
      paths: _paths.map((c, pts) => MapEntry(c, List<GridPoint>.from(pts))),
      lockedPaths: Set<DotColor>.from(_lockedPaths),
  );

  void _commitGestureToUndoStack() {
      if (_gestureModified && _gestureUndoBaseline != null) {
          final current = _captureColorSnapshot();
          if (!_colorSnapshotsEqual(_gestureUndoBaseline!, current)) {
              _colorUndoStack.add(_gestureUndoBaseline!);
              if (_colorUndoStack.length > _maxUndoSnapshots) {
                  _colorUndoStack.removeAt(0);
              }
          }
      }
      _gestureUndoBaseline = null;
      _gestureModified = false;
  }

  bool _colorSnapshotsEqual(_ColorSnapshot a, _ColorSnapshot b) {
      if (a.lockedPaths.length != b.lockedPaths.length ||
          !a.lockedPaths.containsAll(b.lockedPaths)) {
          return false;
      }
      if (a.paths.length != b.paths.length) return false;
      for (final entry in a.paths.entries) {
          final other = b.paths[entry.key];
          if (other == null || other.length != entry.value.length) return false;
          for (int i = 0; i < entry.value.length; i++) {
              if (entry.value[i] != other[i]) return false;
          }
      }
      return true;
  }

  void _restoreColorSnapshot(_ColorSnapshot snap) {
      _paths
        ..clear()
        ..addAll(snap.paths.map((c, pts) => MapEntry(c, List<GridPoint>.from(pts))));
      _lockedPaths
        ..clear()
        ..addAll(snap.lockedPaths);
      _activeColor = null;
  }

  void _applyUndo() {
      if (_colorUndoStack.isEmpty) return;
      _restoreColorSnapshot(_colorUndoStack.removeLast());
  }

  Future<void> _useUndo() async {
      if (!_isGameActive || _isHintAnimating || _colorUndoStack.isEmpty) return;

      if (!_freeUndoUsed) {
          setState(() {
              _freeUndoUsed = true;
              _applyUndo();
          });
          SoundService().playTap();
          return;
      }

      if (!AdService().isRewardedReady) {
          _showNoAdSnack();
          return;
      }

      _pauseTimerForAd();
      final earned = await AdService().showRewarded(onReward: () {});
      if (!mounted) return;
      _resumeTimerAfterAd();
      if (earned && _colorUndoStack.isNotEmpty) {
          setState(_applyUndo);
          SoundService().playTap();
      } else if (!earned) {
          _showNoAdSnack();
      }
  }
  
  List<GridPoint>? _findPath(GridPoint start, GridPoint end, DotColor color) {
      // BFS pathfinding
      final queue = Queue<List<GridPoint>>();
      final visited = <GridPoint>{};
      
      queue.add([start]);
      visited.add(start);
      
      while (queue.isNotEmpty) {
          final path = queue.removeFirst();
          final current = path.last;
          
          if (current == end) {
              return path;
          }
          
          // Check all 4 orthogonal neighbors
          final neighbors = [
              GridPoint(current.row - 1, current.col), // Up
              GridPoint(current.row + 1, current.col), // Down
              GridPoint(current.row, current.col - 1), // Left
              GridPoint(current.row, current.col + 1), // Right
          ];
          
          for (final neighbor in neighbors) {
              // Check bounds
              if (neighbor.row < 0 || neighbor.row >= widget.level.rows ||
                  neighbor.col < 0 || neighbor.col >= widget.level.cols) {
                  continue;
              }
              
              if (visited.contains(neighbor)) continue;
              
              // Check if cell is occupied by another color's node (not our endpoints)
              bool blockedByNode = false;
              widget.level.dotPositions.forEach((c, nodes) {
                  if (c != color && nodes.contains(neighbor)) {
                      blockedByNode = true;
                  }
              });
              if (blockedByNode) continue;
              
              // Check if cell is occupied by a locked path
              bool blockedByLockedPath = false;
              _paths.forEach((c, p) {
                  if (c != color && _lockedPaths.contains(c) && p.contains(neighbor)) {
                      blockedByLockedPath = true;
                  }
              });
              if (blockedByLockedPath) continue;
              
              visited.add(neighbor);
              queue.add([...path, neighbor]);
          }
      }
      
      return null; // No path found
  }
  
  // ... Keep Tutorial & Input Logic same as previous artifact ...
   Widget _buildTutorialOverlay(double cellSize) {
      final start = widget.level.startNode ?? const GridPoint(0, 0);
      // For tutorial, we'll just demonstrate moving 2 cells right or down
      final bool canMoveRight = start.col + 2 < widget.level.cols;
      
      return IgnorePointer(
          child: AnimatedBuilder(
              animation: _handController,
              builder: (context, child) {
                   double t = _handController.value;
                   double row, col;
                   
                   // Dynamic animation based on start node
                   if (canMoveRight) {
                       // Move Horizontal then Vertical
                       if (t < 0.5) {
                           double localT = t * 2; 
                           row = start.row.toDouble();
                           col = start.col + (localT * 2); 
                       } else {
                           double localT = (t - 0.5) * 2; 
                           col = (start.col + 2).toDouble();
                           row = start.row + (localT * 2);
                       }
                   } else {
                       // Move Vertical then Horizontal
                       if (t < 0.5) {
                           double localT = t * 2; 
                           col = start.col.toDouble();
                           row = start.row + (localT * 2); 
                       } else {
                           double localT = (t - 0.5) * 2; 
                           row = (start.row + 2).toDouble();
                           col = start.col + (localT * 2);
                       }
                   }

                   return Stack(
                       children: [
                           Positioned(
                               left: col * cellSize + (cellSize/2), 
                               top: row * cellSize + (cellSize/2),
                               child: Transform.translate(
                                   offset: const Offset(10, 10),
                                   child: Icon(Icons.touch_app, size: cellSize * 0.8, color: Colors.white, shadows: const [Shadow(color: Colors.black, blurRadius: 10)])
                               ),
                           ),
                           Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Text(AppLocalizations.of(context).tutorialSwipe, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                ),
                           )
                       ],
                   );
              },
          ),
      );
  }

  GridPoint _getGridPoint(Offset localPosition, double size) {
    if (size <= 0) return const GridPoint(0, 0);
    double cellW = size / widget.level.cols;
    double cellH = size / widget.level.rows;
    int col = (localPosition.dx / cellW).floor().clamp(0, widget.level.cols - 1);
    int row = (localPosition.dy / cellH).floor().clamp(0, widget.level.rows - 1);
    return GridPoint(row, col);
  }

  void _handleInputStart(DragStartDetails details, double size) {
  _resetInactivityTimer(); // Reset on input
  SoundService().playTap();
  
  GridPoint p = _getGridPoint(details.localPosition, size);
  
  // NUMBER PATH & OPERATION PATH MODE
  if (widget.level.gameType == GameType.numberPath || widget.level.gameType == GameType.operationPath) {
    // Must start at the designated Start Node
    final bool isStartNode = widget.level.startNode != null && p == widget.level.startNode;
    final bool isLegacyStart = widget.level.gameType == GameType.numberPath && widget.level.fixedNumbers?[p] == 1;

    if (isStartNode || isLegacyStart) {
      setState(() {
        _numberPath = [p];
        _playerNumbers = widget.level.gameType == GameType.numberPath 
            ? Map.from(widget.level.fixedNumbers ?? {})
            : {p: widget.level.startValue};
        
        if (isStartNode) {
          _playerNumbers[p] = widget.level.startValue;
        } else if (isLegacyStart) {
          _playerNumbers[p] = 1;
        }
        
        if (widget.level.id == 1) _handController.stop();
      });
    }
    return;
  }
  
  // COLOR DOT MODE (original logic)
  if (_isGameActive) {
      _gestureUndoBaseline = _captureColorSnapshot();
      _gestureModified = false;
  }
  // Auto-delete incomplete paths when starting a new interaction
  setState(() {
      _paths.removeWhere((color, path) => !_lockedPaths.contains(color));
  });

  widget.level.dotPositions.forEach((color, locations) {
      if (locations.contains(p)) {
          if (_lockedPaths.contains(color)) {
              _handlePathBreak(color);
              return;
          }
          setState(() {
              _activeColor = color;
              _paths[color] = [p]; 
              if (widget.level.id == 1) _handController.stop();
              if (_isGameActive) _gestureModified = true;
          });
      }
  });
  if (_activeColor == null) {
      _paths.forEach((color, path) {
          if (path.isNotEmpty && path.last == p) {
              if (_lockedPaths.contains(color)) {
                  _handlePathBreak(color);
                  return;
              }
              setState(() {
                  _activeColor = color;
                  if (widget.level.id == 1) _handController.stop();
                  if (_isGameActive) _gestureModified = true;
              });
          }
      });
  }
}

  void _handleInputUpdate(DragUpdateDetails details, double size) {
    _resetInactivityTimer(); // Reset on input
    
    GridPoint p = _getGridPoint(details.localPosition, size);
    
    // OPERATION PATH MODE
    if (widget.level.gameType == GameType.operationPath) {
      if (_numberPath.isEmpty) return;
      
      GridPoint last = _numberPath.last;
      if (p == last) return;
      
      bool isOrthogonal = (p.row == last.row && (p.col - last.col).abs() == 1) || 
                          (p.col == last.col && (p.row - last.row).abs() == 1);
      if (!isOrthogonal) return;

      // Backtracking
      if (_numberPath.length > 1 && _numberPath[_numberPath.length - 2] == p) {
        setState(() {
          _numberPath.removeLast();
          _playerNumbers.remove(last);
        });
        return;
      }
      
      // Rule: Cannot move to target unless it's the last cell (totalCells - 1 already in path)
      final totalCells = widget.level.rows * widget.level.cols;
      if (p == widget.level.targetNode && _numberPath.length < totalCells - 1) {
        return;
      }
      
      if (_playerNumbers.containsKey(p)) return;

      // Calculation
      int currentVal = _playerNumbers[last] ?? widget.level.startValue;
      final op = widget.level.operations?[p];
      if (op == null) return;

      int nextVal = currentVal;
      switch (op.type) {
        case OperationType.add: nextVal += op.operand; break;
        case OperationType.subtract: nextVal -= op.operand; break;
        case OperationType.multiply: nextVal *= op.operand; break;
        case OperationType.divide: 
          if (op.operand == 0 || currentVal % op.operand != 0) return;
          nextVal ~/= op.operand;
          break;
      }

      setState(() {
        _numberPath.add(p);
        _playerNumbers[p] = nextVal;
      });
      return;
    }

    // NUMBER PATH MODE
    if (widget.level.gameType == GameType.numberPath) {
      if (_numberPath.isEmpty) return;
      
      GridPoint last = _numberPath.last;
      if (p == last) return;
      
      // Rule 1: Must be orthogonal (adjacent) - only horizontal or vertical
      bool isOrthogonal = (p.row == last.row && (p.col - last.col).abs() == 1) || 
                          (p.col == last.col && (p.row - last.row).abs() == 1);
      if (!isOrthogonal) return;
      
      // --- NEW: Path Locking Logic ---
      // Find the index of the most recently reached fixed number (clue)
      int lastFixedIndex = 0;
      for (int i = _numberPath.length - 1; i >= 0; i--) {
        if (widget.level.fixedNumbers?.containsKey(_numberPath[i]) ?? false) {
          lastFixedIndex = i;
          break;
        }
      }

      // Allow backtracking (but only if last point isn't locked by being a fixed number clue)
      if (_numberPath.length > 1 && _numberPath[_numberPath.length - 2] == p) {
        // If the current tip of the path is a fixed number reached AFTER the start, lock it.
        if (_numberPath.length - 1 <= lastFixedIndex && lastFixedIndex > 0) {
          return; // Locked!
        }
        
        setState(() {
          _numberPath.removeLast();
          final lastNum = _playerNumbers[last];
          if (lastNum != null && !(widget.level.fixedNumbers?.containsKey(last) ?? false)) {
            _playerNumbers.remove(last);
          }
        });
        return;
      }
      
      // Rule 2: Cell must be empty OR match expected next number (for fixed cells)
      final currentNum = _playerNumbers[last] ?? 1;
      final nextNum = currentNum + 1;
      
      if (_playerNumbers.containsKey(p)) {
        final existingNum = _playerNumbers[p];
        
        // If it's a fixed number, check if it matches expected sequence
        if (widget.level.fixedNumbers?.containsKey(p) ?? false) {
          if (existingNum == nextNum) {
            // Valid: moving to correct fixed number
            setState(() {
              _numberPath.add(p);
            });
            return;
          } else {
            // Invalid: fixed number doesn't match sequence
            return;
          }
        }
        
        // Allow retracing to this point (for player-filled cells)
        int idx = _numberPath.indexOf(p);
        if (idx >= 0) {
          // Cannot retrace into a locked section (past the last clue)
          if (idx < lastFixedIndex) return;
          
          setState(() {
            // Remove all points after this one
            for (int i = _numberPath.length - 1; i > idx; i--) {
              final pt = _numberPath[i];
              if (!(widget.level.fixedNumbers?.containsKey(pt) ?? false)) {
                _playerNumbers.remove(pt);
              }
            }
            _numberPath = _numberPath.sublist(0, idx + 1);
          });
        }
        return;
      }
      
      // Rule 3: Add next sequential number to empty cell
      setState(() {
        _numberPath.add(p);
        _playerNumbers[p] = nextNum;
      });
      
      // Don't check win here - only check on input end
      return;
    }
    
    // COLOR DOT MODE (original logic)
    if (_activeColor == null) return;
    List<GridPoint> currentPath = _paths[_activeColor!]!;
    GridPoint last = currentPath.last;
    if (p == last) return; 

    // Stop if we've already reached the destination dot (and aren't backtracking)
    final endpoints = widget.level.dotPositions[_activeColor!]!;
    if (currentPath.length > 1 && endpoints.contains(last)) {
        if (currentPath[currentPath.length - 2] == p) {
            setState(() {
                currentPath.removeLast();
                _gestureModified = true;
            });
        }
        return;
    }

    bool isOrthogonal = (p.row == last.row && (p.col - last.col).abs() == 1) || (p.col == last.col && (p.row - last.row).abs() == 1);
    if (!isOrthogonal) return; 
    if (currentPath.length > 1 && currentPath[currentPath.length - 2] == p) {
        setState(() {
            currentPath.removeLast();
            _gestureModified = true;
        });
        return;
    }
    if (currentPath.contains(p)) {
        int idx = currentPath.indexOf(p);
        setState(() {
            _paths[_activeColor!] = currentPath.sublist(0, idx + 1);
            _gestureModified = true;
        });
        return;
    }
    
    // Check if trying to cross a locked path
    bool hitLockedPath = false;
    _paths.forEach((c, path) {
        if (c != _activeColor && _lockedPaths.contains(c) && path.contains(p)) {
            hitLockedPath = true;
        }
    });
    if (hitLockedPath) return; // Stop drawing if hitting a locked path
    
    bool hitWrongNode = false;
    widget.level.dotPositions.forEach((c, locs) {
        if (c != _activeColor && locs.contains(p)) hitWrongNode = true;
    });
    if (hitWrongNode) return;
    setState(() {
         _paths.forEach((c, path) {
            if (c != _activeColor && path.contains(p)) {
               int idx = path.indexOf(p);
               _paths[c] = path.sublist(0, idx);
            }
        });
        _paths[_activeColor!]!.add(p);
        _gestureModified = true;
    });
}

  void _handleInputEnd() {
      if (widget.level.gameType == GameType.colorDots && _isGameActive) {
          _commitGestureToUndoStack();
      }
      _activeColor = null;
      _checkWin();
  }

}

// --- VISUAL CLASSES ---

class _SpaceParticle {
    double x, y, size, speed, opacity;
    _SpaceParticle({required this.x, required this.y, required this.size, required this.speed, required this.opacity});
}

class _ConfettiParticle {
    double x, y, vx, vy, size, rotation, rotSpeed, opacity;
    Color color;
    _ConfettiParticle({required this.x, required this.y, required this.vx, required this.vy, required this.color, required this.size, required this.rotation, required this.rotSpeed, required this.opacity});
}

class _SpaceBackgroundPainter extends CustomPainter {
    final List<_SpaceParticle> particles;
    final double animValue;
    _SpaceBackgroundPainter({required this.particles, required this.animValue});
    @override
    void paint(Canvas canvas, Size size) {
        final Rect rect = Offset.zero & size;
        final Paint bgPaint = Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF050510), const Color(0xFF101025)]).createShader(rect);
        canvas.drawRect(rect, bgPaint);
        for (var p in particles) {
            double dy = (p.y + (animValue * p.speed)) % 1.0;
            canvas.drawCircle(Offset(p.x * size.width, dy * size.height), p.size, Paint()..color = Colors.white.withValues(alpha: p.opacity * 0.5));
        }
    }
    @override bool shouldRepaint(covariant _SpaceBackgroundPainter old) => true;
}

class _ConfettiPainter extends CustomPainter {
    final List<_ConfettiParticle> particles;
    _ConfettiPainter({required this.particles});
    
    @override
    void paint(Canvas canvas, Size size) {
        for (var p in particles) {
            canvas.save();
             canvas.translate(p.x, p.y);
            canvas.rotate(p.rotation * math.pi / 180);
            canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), Paint()..color = p.color.withValues(alpha: p.opacity));
            canvas.restore();
        }
    }
    @override bool shouldRepaint(old) => true;
}

// ... Grid/Path/Node Painters same as before ... 
class _NeonGridPainter extends CustomPainter {
    final int rows, cols;
    _NeonGridPainter({required this.rows, required this.cols});
    @override
    void paint(Canvas canvas, Size size) {
        final double cellW = size.width / cols;
        final double cellH = size.height / rows;
        final Paint linePaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.4) // Increased visibility for larger grids
            ..strokeWidth = 3.0 // Thicker lines
            ..style = PaintingStyle.stroke;
        for(int i=0; i<=cols; i++) canvas.drawLine(Offset(i * cellW, 0), Offset(i * cellW, size.height), linePaint);
        for(int i=0; i<=rows; i++) canvas.drawLine(Offset(0, i * cellH), Offset(size.width, i * cellH), linePaint);
    }
    @override bool shouldRepaint(old) => false;
}
class _NeonPathPainter extends CustomPainter {
    final GameLevel level;
    final Map<DotColor, List<GridPoint>> paths;
    final double cellSize;
    final double flowPhase;
    final Set<DotColor> lockedPaths;
    final List<GridPoint>? numberPath; // NEW: For number path rendering
    final Map<GridPoint, int>? playerNumbers; // NEW: For gradient colors

    _NeonPathPainter({
        required this.level, 
        required this.paths, 
        required this.cellSize, 
        required this.flowPhase,
        this.lockedPaths = const {},
        this.numberPath, // NEW
        this.playerNumbers, // NEW
    });

    @override
    void paint(Canvas canvas, Size size) {
        // NUMBER PATH MODE - Draw gradient path
        if (level.gameType == GameType.numberPath && numberPath != null && numberPath!.length > 1 && playerNumbers != null) {
            _paintNumberPath(canvas);
            return;
        }

        // OPERATION PATH MODE - Draw teal/green path
        if (level.gameType == GameType.operationPath && numberPath != null && numberPath!.length > 1) {
            _paintOperationPath(canvas);
            return;
        }
        
        // COLOR DOT MODE - Original rendering
        paths.forEach((color, points) {
            if (points.length < 2) return;
            final Path path = Path();
            for(int i=0; i<points.length; i++) {
                final Offset center = Offset((points[i].col * cellSize) + (cellSize/2), (points[i].row * cellSize) + (cellSize/2));
                if (i==0) path.moveTo(center.dx, center.dy); else path.lineTo(center.dx, center.dy);
            }
            
            // Check if this path is locked
            bool isLocked = lockedPaths.contains(color);
            
            // Enhanced glow for locked paths
            if (isLocked) {
                // Extra bright outer glow - Reduced from 0.9 and 20 blur
                canvas.drawPath(path, Paint()..color = color.color.withValues(alpha: 0.8)..strokeWidth = cellSize * 0.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
                // Solid core - Reduced from 0.4
                canvas.drawPath(path, Paint()..color = color.color..strokeWidth = cellSize * 0.25..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
                // Bright highlight - Reduced from 0.15
                canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.7)..strokeWidth = cellSize * 0.1..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
            } else {
                // Normal path rendering
                // Reduced from 0.6 and 12 blur
                canvas.drawPath(path, Paint()..color = color.color.withValues(alpha: 0.5)..strokeWidth = cellSize * 0.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
                // Core - Reduced from 0.3
                canvas.drawPath(path, Paint()..color=color.color..strokeWidth=cellSize*0.2..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
                // Highlight - Reduced from 0.1
                canvas.drawPath(path, Paint()..color=Colors.white.withValues(alpha: 0.5)..strokeWidth=cellSize*0.06..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
            }
        });
    }
    
    void _paintNumberPath(Canvas canvas) {
        if (numberPath == null || numberPath!.length < 2) return;
        
        // Color palette for numbers
        final List<Color> numberColors = [
            Colors.blueAccent,
            Colors.yellowAccent,
            Colors.purpleAccent,
            Colors.orangeAccent,
            Colors.pinkAccent,
            Colors.tealAccent,
            Colors.amberAccent,
            Colors.indigoAccent,
            Colors.cyanAccent,
            Colors.limeAccent,
        ];
        
        // Collect indices for segments (all fixed numbers + current tip)
        List<int> segmentIndices = [];
        for (int i = 0; i < numberPath!.length; i++) {
            if (level.fixedNumbers?.containsKey(numberPath![i]) ?? false) {
                segmentIndices.add(i);
            }
        }
        
        // Always include the current tip of the path for continuous rendering
        if (segmentIndices.isEmpty || segmentIndices.last != numberPath!.length - 1) {
            segmentIndices.add(numberPath!.length - 1);
        }
        
        // Draw segments between the indices
        for (int s = 0; s < segmentIndices.length - 1; s++) {
            final int startIdx = segmentIndices[s];
            final int endIdx = segmentIndices[s + 1];
            
            // Get colors for this segment
            final startNum = playerNumbers![numberPath![startIdx]] ?? 1;
            final endNum = playerNumbers![numberPath![endIdx]] ?? startNum;
            final Color startColor = numberColors[(startNum - 1) % numberColors.length];
            final Color endColor = numberColors[(endNum - 1) % numberColors.length];
            
            // Create continuous path
            final Path path = Path();
            Offset? firstPoint;
            Offset? lastPoint;
            
            for (int i = startIdx; i <= endIdx; i++) {
                final point = numberPath![i];
                final Offset offset = Offset(
                    (point.col * cellSize) + (cellSize/2), 
                    (point.row * cellSize) + (cellSize/2)
                );
                if (!offset.dx.isFinite || !offset.dy.isFinite) continue;
                if (i == startIdx) {
                    path.moveTo(offset.dx, offset.dy);
                    firstPoint = offset;
                } else {
                    path.lineTo(offset.dx, offset.dy);
                }
                if (i == endIdx) {
                    lastPoint = offset;
                }
            }
            
            // Create gradient shader using absolute points to avoid division by zero in Alignment
            if (firstPoint == null || lastPoint == null || firstPoint == lastPoint) continue;
            
            final Shader gradientShader = ui.Gradient.linear(
                firstPoint, 
                lastPoint, 
                [startColor, endColor]
            );
            
            // Draw glow
            final Paint glowPaint = Paint()
                ..shader = gradientShader
                ..strokeWidth = cellSize * 0.4
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
            canvas.drawPath(path, glowPaint);
            
            // Draw core
            final Paint corePaint = Paint()
                ..shader = gradientShader
                ..strokeWidth = cellSize * 0.2
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round;
            canvas.drawPath(path, corePaint);
            
            // Draw highlight
            final Paint highlightPaint = Paint()
                ..color = Colors.white.withValues(alpha: 0.5)
                ..strokeWidth = cellSize * 0.06
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round;
            canvas.drawPath(path, highlightPaint);
        }
    }


    void _paintOperationPath(Canvas canvas) {
        if (numberPath == null || numberPath!.length < 2) return;

        final ops = level.operations ?? {};
        
        Color getOpColor(GridPoint point) {
            if (point == level.startNode) return Colors.greenAccent;
            if (point == level.targetNode) return Colors.redAccent;
            final op = ops[point];
            if (op == null) return Colors.tealAccent;
            switch (op.type) {
                case OperationType.add: return Colors.blueAccent;
                case OperationType.subtract: return Colors.pinkAccent;
                case OperationType.multiply: return Colors.orangeAccent;
                case OperationType.divide: return Colors.purpleAccent;
            }
        }

        for (int i = 0; i < numberPath!.length - 1; i++) {
            final p1 = numberPath![i];
            final p2 = numberPath![i + 1];
            
            final Offset o1 = Offset((p1.col * cellSize) + (cellSize / 2), (p1.row * cellSize) + (cellSize / 2));
            final Offset o2 = Offset((p2.col * cellSize) + (cellSize / 2), (p2.row * cellSize) + (cellSize / 2));
            
            if (!o1.dx.isFinite || !o2.dx.isFinite) continue;

            final Color c1 = getOpColor(p1);
            final Color c2 = getOpColor(p2);

            final Path segmentPath = Path();
            segmentPath.moveTo(o1.dx, o1.dy);
            segmentPath.lineTo(o2.dx, o2.dy);

            final Paint glowPaint = Paint()
                ..strokeWidth = cellSize * 0.4
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

            final Paint corePaint = Paint()
                ..strokeWidth = cellSize * 0.2
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round;

            if (o1 == o2) {
                glowPaint.color = c1.withValues(alpha: 0.5);
                corePaint.color = c1;
            } else {
                final Shader gradientShader = ui.Gradient.linear(o1, o2, [c1, c2]);
                glowPaint.shader = gradientShader;
                corePaint.shader = gradientShader;
            }

            // Glow
            canvas.drawPath(segmentPath, glowPaint);

            // Core
            canvas.drawPath(segmentPath, corePaint);

            // Highlight
            canvas.drawPath(segmentPath, Paint()
                ..color = Colors.white.withValues(alpha: 0.5)
                ..strokeWidth = cellSize * 0.06
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round);
        }
    }

    @override bool shouldRepaint(_NeonPathPainter old) => old.flowPhase != flowPhase || old.numberPath != numberPath;
}
class _NeonNodePainter extends CustomPainter {
    final GameLevel level;
    final double cellSize;
    final double pulseValue;
    final Map<GridPoint, int>? playerNumbers; // NEW: For number puzzles
    
    _NeonNodePainter({
      required this.level, 
      required this.cellSize, 
      required this.pulseValue,
      this.playerNumbers,
    });
    
    @override
    void paint(Canvas canvas, Size size) {
        // Render based on game type
        if (level.gameType == GameType.numberPath) {
            // RENDER NUMBERS
            _paintNumbers(canvas, size);
        } else if (level.gameType == GameType.operationPath) {
            // RENDER OPERATIONS
            _paintOperations(canvas, size);
        } else {
            // RENDER COLOR DOTS (original logic)
            _paintColorDots(canvas, size);
        }
    }
    
    void _paintNumbers(Canvas canvas, Size size) {
        // Only draw FIXED numbers (not player-filled numbers)
        final numbersToRender = level.fixedNumbers ?? {};
        
        // Color palette for numbers (cycling through available colors)
        final List<Color> numberColors = [
            Colors.blueAccent,
            Colors.yellowAccent,
            Colors.purpleAccent,
            Colors.orangeAccent,
            Colors.pinkAccent,
            Colors.tealAccent,
            Colors.amberAccent,
            Colors.indigoAccent,
            Colors.cyanAccent,
            Colors.limeAccent,
        ];
        
        numbersToRender.forEach((gridPoint, number) {
            final Offset center = Offset(
                (gridPoint.col * cellSize) + (cellSize/2), 
                (gridPoint.row * cellSize) + (cellSize/2)
            );
            if (!center.dx.isFinite || !center.dy.isFinite) return;
            
            // Assign color based on number (cycling through palette)
            final Color bgColor = numberColors[(number - 1) % numberColors.length];
            final double glowSize = (cellSize * 0.4) + (pulseValue * (cellSize * 0.05));
            if (!glowSize.isFinite || glowSize < 0) return;
            
            // Glow
            canvas.drawCircle(
                center, 
                glowSize, 
                Paint()..color = bgColor.withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
            );
            
            // Solid circle
            canvas.drawCircle(
                center, 
                cellSize * 0.35, 
                Paint()..color = bgColor
            );

            // NEW: Visual distinction for START node
            final bool isActualStartNode = level.startNode != null && gridPoint == level.startNode;
            if (isActualStartNode) {
                // Outer Ring
                canvas.drawCircle(
                    center, 
                    cellSize * 0.45, 
                    Paint()
                        ..color = Colors.white.withValues(alpha: 0.5 + (0.5 * pulseValue))
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3.0
                );
                
                // "START" Text Badge
                final startSpan = TextSpan(
                    text: 'START',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: cellSize * 0.15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                    ),
                );
                final startPainter = TextPainter(text: startSpan, textDirection: TextDirection.ltr);
                startPainter.layout();
                
                // Background for badge
                final Rect badgeRect = Rect.fromCenter(
                    center: center + Offset(0, cellSize * 0.45),
                    width: startPainter.width + 8,
                    height: startPainter.height + 4
                );
                canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)), Paint()..color = Colors.black87);
                
                startPainter.paint(canvas, center + Offset(-startPainter.width / 2, cellSize * 0.45 - startPainter.height / 2));
            }
            
            // Shine effect
            canvas.drawOval(
                Rect.fromCenter(
                    center: center - Offset(0, cellSize*0.15), 
                    width: cellSize*0.25, 
                    height: cellSize*0.12
                ), 
                Paint()..color = Colors.white.withValues(alpha: 0.4)
            );
            
            // Draw number text
            final textSpan = TextSpan(
                text: '$number',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: cellSize * 0.4,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                        Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))
                    ]
                ),
            );
            
            final textPainter = TextPainter(
                text: textSpan,
                textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            
            // Center the text
            textPainter.paint(
                canvas, 
                Offset(
                    center.dx - textPainter.width / 2, 
                    center.dy - textPainter.height / 2
                )
            );
        });
    }
    
    void _paintOperations(Canvas canvas, Size size) {
        final ops = level.operations ?? {};
        final Set<GridPoint> nodesToPaint = {};
        if (level.startNode != null) nodesToPaint.add(level.startNode!);
        if (level.targetNode != null) nodesToPaint.add(level.targetNode!);
        nodesToPaint.addAll(ops.keys);
        
        for (final gridPoint in nodesToPaint) {
            final op = ops[gridPoint];
            final Offset center = Offset(
                (gridPoint.col * cellSize) + (cellSize/2), 
                (gridPoint.row * cellSize) + (cellSize/2)
            );
            if (!center.dx.isFinite || !center.dy.isFinite) continue;
            
            final bool isStart = level.startNode == gridPoint;
            final bool isTarget = level.targetNode == gridPoint;

            // Determine color based on operation type
            Color color;
            if (isStart) {
                color = Colors.greenAccent;
            } else if (isTarget) {
                color = Colors.redAccent;
            } else if (op != null) {
                switch (op.type) {
                    case OperationType.add: color = Colors.blueAccent; break;
                    case OperationType.subtract: color = Colors.pinkAccent; break;
                    case OperationType.multiply: color = Colors.orangeAccent; break;
                    case OperationType.divide: color = Colors.purpleAccent; break;
                }
            } else {
                color = Colors.tealAccent;
            }
            
            // Glow
            canvas.drawCircle(
                center, 
                cellSize * 0.4, 
                Paint()..color = color.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
            );

            // Ring
            canvas.drawCircle(
                center, 
                cellSize * 0.35, 
                Paint()
                    ..color = color
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2.0
            );

            // NEW: Square-based Start/Target Visuals
            if (isStart || isTarget) {
                final Rect squareRect = Rect.fromLTWH(
                    gridPoint.col * cellSize + 4, 
                    gridPoint.row * cellSize + 4, 
                    cellSize - 8, 
                    cellSize - 8
                );
                final RRect rRect = RRect.fromRectAndRadius(squareRect, const Radius.circular(12));
                
                // 1. Subtle Background Fill
                canvas.drawRRect(rRect, Paint()..color = color.withValues(alpha: 0.08));
                
                // 2. Glowing Square Border
                canvas.drawRRect(rRect, Paint()
                    ..color = color.withValues(alpha: 0.4)
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2.5
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
                
                // 3. Corner Icon
                final IconData iconData = isStart ? Icons.play_arrow : Icons.flag_rounded;
                final iconSpan = TextSpan(
                    text: String.fromCharCode(iconData.codePoint),
                    style: TextStyle(
                        fontFamily: 'MaterialIcons',
                        fontSize: cellSize * 0.2, // Slightly larger icon
                        color: color.withValues(alpha: 0.9),
                    ),
                );
                final iconPainter = TextPainter(text: iconSpan, textDirection: TextDirection.ltr);
                iconPainter.layout();
                
                // Position at top-right or top-left
                final Offset iconOffset = isStart 
                    ? Offset(gridPoint.col * cellSize + 8, gridPoint.row * cellSize + 8) // Top-Left
                    : Offset((gridPoint.col + 1) * cellSize - iconPainter.width - 8, gridPoint.row * cellSize + 8); // Top-Right
                
                iconPainter.paint(canvas, iconOffset);
            }

            // Draw Operator Text
            String text = "";
            if (isStart) {
                text = "${level.startValue}";
            } else if (isTarget) {
                if (op != null && (op.type != OperationType.add || op.operand != 0)) {
                    text = "${op.display}\n${level.targetValue}";
                } else {
                    text = "${level.targetValue}";
                }
            } else if (op != null) {
                text = op.display;
            }

            final textSpan = TextSpan(
                text: text,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isTarget ? cellSize * 0.2 : (isStart ? cellSize * 0.35 : cellSize * 0.28),
                    fontWeight: FontWeight.bold,
                ),
            );
            
            final textPainter = TextPainter(
                text: textSpan, 
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
            );
            textPainter.layout(maxWidth: cellSize * 0.85); 
            textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));

            // Draw current path value overlay if visited (for player feedback)
            // Skip for START node as it already showing its value as the primary label
            if (!isStart && (playerNumbers?.containsKey(gridPoint) ?? false)) {
                final currentVal = playerNumbers![gridPoint];
                final valSpan = TextSpan(
                    text: '$currentVal',
                    style: TextStyle(
                        color: color.withValues(alpha: 0.9), // Match operation color
                        fontSize: cellSize * 0.22,
                        fontWeight: FontWeight.w900,
                        shadows: [
                            Shadow(color: Colors.black, blurRadius: 4),
                        ]
                    ),
                );
                final valPainter = TextPainter(text: valSpan, textDirection: TextDirection.ltr);
                valPainter.layout();
                valPainter.paint(canvas, center + Offset(-valPainter.width / 2, cellSize * 0.22));
            }
        }
    }
    void _paintColorDots(Canvas canvas, Size size) {
        // Original color dot rendering
        level.dotPositions.forEach((color, nodes) {
            for (var node in nodes) {
                final Offset center = Offset((node.col * cellSize) + (cellSize/2), (node.row * cellSize) + (cellSize/2));
                double glowSize = (cellSize * 0.35) + (pulseValue * (cellSize * 0.05));
                canvas.drawCircle(center, glowSize, Paint()..color = color.color.withValues(alpha: 0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
                canvas.drawCircle(center, cellSize * 0.25, Paint()..color = color.color);
                canvas.drawOval(Rect.fromCenter(center: center - Offset(0, cellSize*0.15), width: cellSize*0.3, height: cellSize*0.15), Paint()..color = Colors.white.withValues(alpha: 0.3));
            }
        });
    }
    
    @override bool shouldRepaint(_NeonNodePainter old) => old.pulseValue != pulseValue || old.playerNumbers != playerNumbers;
}
class _BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncingButton({required this.child, required this.onTap});

  @override
  State<_BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
         _controller.reverse();
         widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

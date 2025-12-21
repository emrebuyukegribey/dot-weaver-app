import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:collection';
import '../models/game_level_model.dart';
import '../services/game_data_manager.dart';
import '../services/level_generator.dart';

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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
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
  bool _hasStarted = false; // New State
  int _earnedStars = 0;
  
  // Hint System
  Timer? _inactivityTimer;
  Timer? _hintTimer;
  bool _showHint = false;
  // Hardcoded Hint for Level 2 Yellow: (3,4) -> (4,4) filling bottom rows
  final List<GridPoint> _level2Hint = const [
      GridPoint(3, 4), GridPoint(3, 3), GridPoint(3, 2), GridPoint(3, 1), GridPoint(3, 0),
      GridPoint(4, 0), GridPoint(4, 1), GridPoint(4, 2), GridPoint(4, 3), GridPoint(4, 4)
  ];
  
  // Path Locking & Game State
  final Set<DotColor> _lockedPaths = {};
  bool _showAdOverlay = false;
  bool _showLevelAnnouncement = false;
  bool _showBoardNotFullWarning = false;
  int _targetLevelId = 0;
  
  // Hint System
  bool _hintUsed = false;
  bool _isHintAnimating = false;

  @override
  void initState() {
    super.initState();
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
    
    // Initialize number path state if needed
    if (widget.level.gameType == GameType.numberPath) {
      _playerNumbers = Map.from(widget.level.fixedNumbers ?? {});
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
  void dispose() {
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
      // Show Time's Up / Watch Ad Dialog
      _watchAdToRestart(); 
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
                        child: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 28)
                    ),
                ),
            ),
        ),
        actions: [
            // Redesigned Hint Button (Larger, Amber, Circular)
            Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _BouncingButton(
                        onTap: (_hintUsed || _isHintAnimating || !_isGameActive) ? () {} : _useHint,
                        child: Container(
                            width: 58, height: 58,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF2A2A1A),
                                border: Border.all(
                                    color: _hintUsed ? Colors.grey : Colors.amberAccent, 
                                    width: 3
                                ),
                                boxShadow: [
                                    if (!_hintUsed) BoxShadow(
                                        color: Colors.amberAccent.withOpacity(0.4), 
                                        blurRadius: 12, 
                                        spreadRadius: 2
                                    )
                                ]
                            ),
                            child: Icon(
                                Icons.lightbulb_rounded,
                                color: _hintUsed ? Colors.grey : Colors.amberAccent,
                                size: 32,
                            ),
                        ),
                    ),
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
                                        color: Colors.pinkAccent.withOpacity(0.4), 
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
                                    Container(
                                        width: gridSize,
                                        height: gridSize,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 40, spreadRadius: -10)]
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
                                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18, letterSpacing: 2),
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
            if (_showAdOverlay) _buildAdOverlay(),

            // 8. Level Announcement Overlay
            if (_showLevelAnnouncement) _buildLevelAnnouncementOverlay(),

            // 9. Board Not Full Warning (New)
            if (_showBoardNotFullWarning) _buildBoardNotFullOverlay(),
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


  void _checkWin() {
    // NUMBER PATH MODE
    if (widget.level.gameType == GameType.numberPath) {
      final totalCells = widget.level.rows * widget.level.cols;
      
      // Check if all cells are filled
      if (_playerNumbers.length == totalCells) {
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
        
        if (isSequential) {
          // --- BUG FIX: Check if the LAST point on path is actually the END value ---
          if (_numberPath.isNotEmpty) {
              final lastPt = _numberPath.last;
              if (_playerNumbers[lastPt] != endVal) {
                  return; // Not reached yet
              }
          }

          _stopGame();
          
          // Calculate stars based on remaining time
          double ratio = _remainingSeconds / _totalTime;
          if (ratio > 0.70) _earnedStars = 3;
          else if (ratio > 0.40) _earnedStars = 2;
          else _earnedStars = 1;
          
          setState(() {
            _showWinUI = true;
          });
          _triggerConfetti();
        }
      }
      return;
    }
    
    // COLOR DOT MODE (original logic)
    bool allConnected = true;
    Set<GridPoint> filled = {};

    widget.level.dotPositions.forEach((color, nodes) {
        if (!_paths.containsKey(color)) { allConnected = false; return; }
        final path = _paths[color]!;
        if (path.isEmpty) { allConnected = false; return; }
        bool startOk = (path.first == nodes[0] && path.last == nodes[1]);
        bool reverseOk = (path.first == nodes[1] && path.last == nodes[0]);
        
        // Check if path is complete and lock it
        if (startOk || reverseOk) {
            if (!_lockedPaths.contains(color)) {
                setState(() {
                    _lockedPaths.add(color);
                });
            }
        } else {
            allConnected = false;
        }
        
        filled.addAll(path);
    });

    if (!allConnected) return;

    bool boardFull = filled.length == (widget.level.rows * widget.level.cols);
    
    if (boardFull) {
        _stopGame();
        // Score Calculation
        // Score Calculation
        // Stars based on remaining time percentage? Or just completion within limit (3 stars always?)
        // Prompt implies "change timer to countdown", let's keep star logic simple for now:
        // If you finish, you get stars. Maybe quicker = more stars?
        // Let's use remaining time ratio.
        double ratio = _remainingSeconds / _totalTime;
        // Custom Star Logic (Balanced for short times)
        if (ratio > 0.70) _earnedStars = 3; // > 70% time left
        else if (ratio > 0.40) _earnedStars = 2; // > 40% time left
        else _earnedStars = 1;

        setState(() {
            _showWinUI = true;
        });
        _triggerConfetti();
    } else {
        // All connected but board NOT full -> Show warning then Ad
        _stopGame();
        setState(() {
            _showBoardNotFullWarning = true;
        });
        
        Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
                setState(() {
                    _showBoardNotFullWarning = false;
                });
                _watchAdToRestart();
            }
        });
    }
  }

  List<int> _getStarThresholds(int levelId) {
    if (levelId <= 1) return [5, 10];
    if (levelId <= 3) return [10, 20];
    if (levelId <= 6) return [15, 25];
    if (levelId <= 10) return [30, 50];  // 6x6
    if (levelId <= 13) return [50, 90];  // 7x7
    if (levelId <= 16) return [80, 150]; // 8x8
    if (levelId <= 17) return [130, 240]; // 9x9
    if (levelId <= 30) return [60, 100]; // 6x6 (L21-30)
    if (levelId <= 40) return [90, 150]; // 7x7 (L31-40)
    if (levelId <= 50) return [120, 200]; // 8x8 (L41-50)
    return [200, 400]; // Fallback
  }

  Widget _buildWinOverlay() {
      return Stack(
          children: [
              // Darken BG
              Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.7)),
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
                                          BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 50, spreadRadius: 0)
                                      ]
                                  ),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          const Text("LEVEL COMPLETE!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28, fontFamily: 'Comic Sans MS')),
                                          const SizedBox(height: 10),
                                          Text("Time Left: ${_formatTime()}", style: const TextStyle(color: Colors.white70, fontSize: 18)),
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
                                                          
                                                          // 2. Load next level if exists
                                                          if (widget.levelId < 50 && mounted) {
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
                                                              Navigator.pop(context, _earnedStars);
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
                                                                  BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 4)
                                                              ]
                                                          ),
                                                          child: const Text(
                                                              "CONTINUE", 
                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)
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
                      color: Colors.black.withOpacity(0.9),
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
                                                  "LEVEL",
                                                  style: TextStyle(
                                                      color: Colors.white.withOpacity(0.7),
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
                                                          Shadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 40),
                                                          Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 80),
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
                       child: Container(color: const Color(0xFF001A04).withOpacity(0.75)), // Deep Green/Black tint
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
                                               BoxShadow(color: const Color(0xFF76FF03).withOpacity(0.6), blurRadius: 20, spreadRadius: 0),
                                               // 2. Wide Ambient Glow
                                               BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
                                               // 3. Bottom Depth Shadow
                                               BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8)),
                                           ],
                                           // Matching Green Border
                                           border: Border.all(color: const Color(0xFFB2FF59).withOpacity(0.9), width: 3), 
                                       ),
                                       child: Container(
                                           // Inner subtle gradient for 3D feel
                                           decoration: BoxDecoration(
                                               shape: BoxShape.circle,
                                               gradient: LinearGradient(
                                                   begin: Alignment.topCenter,
                                                   end: Alignment.bottomCenter,
                                                   colors: [
                                                       Colors.white.withOpacity(0.3),
                                                       Colors.transparent,
                                                       Colors.black.withOpacity(0.1),
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
  

  

  
  Future<void> _watchAdToRestart() async {
    setState(() {
        _showAdOverlay = true;
    });
    
    // Mock ad delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
        setState(() {
            _showAdOverlay = false;
        });
        _resetGame();
    }
  }

  Widget _buildAdOverlay() {
      return Stack(
          children: [
              Positioned.fill(
                  child: Container(
                      color: Colors.black,
                      child: Center(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  const Icon(Icons.play_circle_fill, color: Colors.orangeAccent, size: 80),
                                  const SizedBox(height: 20),
                                  const Text(
                                      "REKLAM İZLENİYOR...",
                                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                  ),
                                  const SizedBox(height: 10),
                                  const SizedBox(
                                      width: 200,
                                      child: LinearProgressIndicator(color: Colors.orangeAccent, backgroundColor: Colors.white10),
                                  )
                              ],
                          ),
                      ),
                  ),
              ),
          ],
      );
  }

  // Removed legacy _buildGameOverOverlay 

  Widget _buildBoardNotFullOverlay() {
      return Center(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)
                  ],
              ),
              child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 50),
                      SizedBox(height: 10),
                      Text(
                          "MASA TAMAMLANMADI!",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      Text(
                          "Tüm kareleri doldurmalısın!",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                  ],
              ),
          ),
      );
  }
  

  void _resetGame() {
      _stopGame();
      setState(() {
          _paths.clear();
          _numberPath.clear(); // Clear number path
          _showWinUI = false;
          _hasStarted = false; // SHOW START BUTTON
          _confettiParticles.clear();
          _lockedPaths.clear();
          
          // Reset player numbers to fixed numbers
          if (widget.level.gameType == GameType.numberPath) {
            _playerNumbers = Map.from(widget.level.fixedNumbers ?? {});
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
  Future<void> _useHint() async {
      if (_hintUsed || _isHintAnimating) return;
      
      // Find first incomplete color
      DotColor? targetColor;
      widget.level.dotPositions.forEach((color, nodes) {
          if (targetColor == null && !_lockedPaths.contains(color)) {
              targetColor = color;
          }
      });
      
      if (targetColor == null) return;
      
      final nodes = widget.level.dotPositions[targetColor]!;
      final path = _findPath(nodes[0], nodes[1], targetColor!);
      
      if (path == null || path.isEmpty) return;
      
      // Mark hint as used
      await GameDataManager().markHintUsed(widget.islandId, widget.levelId);
      setState(() {
          _hintUsed = true;
          _isHintAnimating = true;
      });
      
      // Animate path drawing
      _paths[targetColor!] = [path.first];
      for (int i = 1; i < path.length; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;
          setState(() {
              _paths[targetColor!]!.add(path[i]);
          });
      }
      
      setState(() {
          _isHintAnimating = false;
      });
      
      // Check win after hint completes
      _checkWin();
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
                           const Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Text("Swipe to Connect Numbers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
  
  GridPoint p = _getGridPoint(details.localPosition, size);
  
  // NUMBER PATH MODE
  if (widget.level.gameType == GameType.numberPath) {
    // Must start at the designated Start Node OR fallback to 1 for legacy
    final bool isStartNode = widget.level.startNode != null && p == widget.level.startNode;
    final bool isLegacyStart = widget.level.fixedNumbers?[p] == 1;

    if (isStartNode || isLegacyStart) {
      setState(() {
        _numberPath = [p];
        _playerNumbers = Map.from(widget.level.fixedNumbers ?? {});
        
        // Ensure starting node has the correct value even if not in fixedNumbers
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
              });
          }
      });
  }
}

  void _handleInputUpdate(DragUpdateDetails details, double size) {
    _resetInactivityTimer(); // Reset on input
    
    GridPoint p = _getGridPoint(details.localPosition, size);
    
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
            setState(() { currentPath.removeLast(); });
        }
        return;
    }

    bool isOrthogonal = (p.row == last.row && (p.col - last.col).abs() == 1) || (p.col == last.col && (p.row - last.row).abs() == 1);
    if (!isOrthogonal) return; 
    if (currentPath.length > 1 && currentPath[currentPath.length - 2] == p) {
        setState(() { currentPath.removeLast(); });
        return;
    }
    if (currentPath.contains(p)) {
        int idx = currentPath.indexOf(p);
        setState(() { _paths[_activeColor!] = currentPath.sublist(0, idx + 1); });
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
    });
}

  void _handleInputEnd() { _activeColor = null; _checkWin(); }

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
            canvas.drawCircle(Offset(p.x * size.width, dy * size.height), p.size, Paint()..color = Colors.white.withOpacity(p.opacity * 0.5));
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
            canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), Paint()..color = p.color.withOpacity(p.opacity));
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
            ..color = Colors.white.withOpacity(0.4) // Increased visibility for larger grids
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
    final List<GridPoint>? hintPath;
    final Set<DotColor> lockedPaths;
    final List<GridPoint>? numberPath; // NEW: For number path rendering
    final Map<GridPoint, int>? playerNumbers; // NEW: For gradient colors

    _NeonPathPainter({
        required this.level, 
        required this.paths, 
        required this.cellSize, 
        required this.flowPhase,
        this.hintPath,
        this.lockedPaths = const {},
        this.numberPath, // NEW
        this.playerNumbers, // NEW
    });

    @override
    void paint(Canvas canvas, Size size) {
        // NUMBER PATH MODE - Draw gradient path
        if (numberPath != null && numberPath!.length > 1 && playerNumbers != null) {
            _paintNumberPath(canvas);
            return;
        }
        
        // COLOR DOT MODE - Original rendering
        // Draw Hint Path
        if (hintPath != null && hintPath!.length > 1) {
            final Path hPath = Path();
            for(int i=0; i<hintPath!.length; i++) {
                final Offset center = Offset((hintPath![i].col * cellSize) + (cellSize/2), (hintPath![i].row * cellSize) + (cellSize/2));
                if (i==0) hPath.moveTo(center.dx, center.dy); else hPath.lineTo(center.dx, center.dy);
            }
            
            // Dashed Line Effect
            final Path dashedPath = _createDashedPath(hPath, 10, 10);
            
            // Neon Amber Color for Hint
            final Color hintColor = const Color(0xFFFFD740); // Amber Accent 200
            canvas.drawPath(dashedPath, Paint()..color = hintColor.withOpacity(0.4)..strokeWidth = cellSize * 0.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
            canvas.drawPath(dashedPath, Paint()..color = hintColor.withOpacity(0.2)..strokeWidth = cellSize * 0.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        }

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
                canvas.drawPath(path, Paint()..color = color.color.withOpacity(0.8)..strokeWidth = cellSize * 0.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
                // Solid core - Reduced from 0.4
                canvas.drawPath(path, Paint()..color = color.color..strokeWidth = cellSize * 0.25..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
                // Bright highlight - Reduced from 0.15
                canvas.drawPath(path, Paint()..color = Colors.white.withOpacity(0.7)..strokeWidth = cellSize * 0.1..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
            } else {
                // Normal path rendering
                // Reduced from 0.6 and 12 blur
                canvas.drawPath(path, Paint()..color = color.color.withOpacity(0.5)..strokeWidth = cellSize * 0.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
                // Core - Reduced from 0.3
                canvas.drawPath(path, Paint()..color=color.color..strokeWidth=cellSize*0.2..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
                // Highlight - Reduced from 0.1
                canvas.drawPath(path, Paint()..color=Colors.white.withOpacity(0.5)..strokeWidth=cellSize*0.06..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
            }
        });
    }
    
    void _paintNumberPath(Canvas canvas) {
        if (numberPath == null || numberPath!.length < 2) return;
        
        // Color palette for numbers
        final List<Color> numberColors = [
            Colors.redAccent,
            Colors.blueAccent,
            Colors.greenAccent,
            Colors.yellowAccent,
            Colors.purpleAccent,
            Colors.orangeAccent,
            Colors.pinkAccent,
            Colors.tealAccent,
            Colors.amberAccent,
            Colors.indigoAccent,
            Colors.cyanAccent,
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
            final Rect bounds = path.getBounds();
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
                ..color = Colors.white.withOpacity(0.5)
                ..strokeWidth = cellSize * 0.06
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round;
            canvas.drawPath(path, highlightPaint);
        }
    }
    
    Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
        final Path dest = Path();
        for (final ui.PathMetric metric in source.computeMetrics()) {
            double distance = 0;
            while (distance < metric.length) {
                final double len = math.min(dashWidth, metric.length - distance);
                dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
                distance += dashWidth;
                distance += dashSpace;
            }
        }
        return dest;
    }

    @override bool shouldRepaint(_NeonPathPainter old) => old.flowPhase != flowPhase || old.hintPath != hintPath || old.numberPath != numberPath;
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
            Colors.redAccent,
            Colors.blueAccent,
            Colors.greenAccent,
            Colors.yellowAccent,
            Colors.purpleAccent,
            Colors.orangeAccent,
            Colors.pinkAccent,
            Colors.tealAccent,
            Colors.amberAccent,
            Colors.indigoAccent,
            Colors.cyanAccent,
        ];
        
        numbersToRender.forEach((gridPoint, number) {
            final Offset center = Offset(
                (gridPoint.col * cellSize) + (cellSize/2), 
                (gridPoint.row * cellSize) + (cellSize/2)
            );
            if (!center.dx.isFinite || !center.dy.isFinite) return;
            
            // Determine if this is a fixed number or player number
            final bool isFixed = level.fixedNumbers?.containsKey(gridPoint) ?? false;
            
            // Assign color based on number (cycling through palette)
            final Color bgColor = numberColors[(number - 1) % numberColors.length];
            final double glowSize = (cellSize * 0.4) + (pulseValue * (cellSize * 0.05));
            if (!glowSize.isFinite || glowSize < 0) return;
            
            // Glow
            canvas.drawCircle(
                center, 
                glowSize, 
                Paint()..color = bgColor.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
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
                        ..color = Colors.white.withOpacity(0.5 + (0.5 * pulseValue))
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
                Paint()..color = Colors.white.withOpacity(0.4)
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
    
    void _paintColorDots(Canvas canvas, Size size) {
        // Original color dot rendering
        level.dotPositions.forEach((color, nodes) {
            for (var node in nodes) {
                final Offset center = Offset((node.col * cellSize) + (cellSize/2), (node.row * cellSize) + (cellSize/2));
                double glowSize = (cellSize * 0.35) + (pulseValue * (cellSize * 0.05));
                canvas.drawCircle(center, glowSize, Paint()..color = color.color.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
                canvas.drawCircle(center, cellSize * 0.25, Paint()..color = color.color);
                canvas.drawOval(Rect.fromCenter(center: center - Offset(0, cellSize*0.15), width: cellSize*0.3, height: cellSize*0.15), Paint()..color = Colors.white.withOpacity(0.3));
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

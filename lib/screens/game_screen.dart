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
  // Game State
  final Map<DotColor, List<GridPoint>> _paths = {};
  DotColor? _activeColor;
  
  // Timer State
  Timer? _gameTimer;
  int _elapsedMilliseconds = 0;
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
      _elapsedMilliseconds = 0;
      _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (!mounted) return;
          setState(() {
              _elapsedMilliseconds += 100;
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

  String _formatTime() {
      int seconds = (_elapsedMilliseconds / 1000).floor();
      int mins = (seconds / 60).floor();
      int secs = seconds % 60;
      return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      extendBodyBehindAppBar: true,
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
                        style: const TextStyle(
                            fontFamily: 'monospace', 
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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
                            
                            double gridSize = math.min(maxW, maxH);

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
                                            children: [
                                                CustomPaint(size: Size(gridSize, gridSize), painter: _NeonGridPainter(rows: widget.level.rows, cols: widget.level.cols)),
                                                AnimatedBuilder(animation: _flowController, builder: (_,__) => CustomPaint(size: Size(gridSize, gridSize), painter: _NeonPathPainter(level: widget.level, paths: _paths, cellSize: gridSize / widget.level.cols, flowPhase: _flowController.value, lockedPaths: _lockedPaths))),
                                                AnimatedBuilder(animation: _pulseController, builder: (_,__) => CustomPaint(size: Size(gridSize, gridSize), painter: _NeonNodePainter(level: widget.level, cellSize: gridSize / widget.level.cols, pulseValue: _pulseController.value))),
                                                
                                                // Input
                                                GestureDetector(
                                                    onPanStart: _isGameActive ? (d) => _handleInputStart(d, gridSize) : null,
                                                    onPanUpdate: _isGameActive ? (d) => _handleInputUpdate(d, gridSize) : null,
                                                    onPanEnd: _isGameActive ? (_) => _handleInputEnd() : null,
                                                    behavior: HitTestBehavior.translucent,
                                                    child: Container(width: gridSize, height: gridSize, color: Colors.transparent),
                                                ),
                                                
                                                if (widget.level.id == 1 && _paths.isEmpty) _buildTutorialOverlay(gridSize / widget.level.cols),
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
          int seconds = (_elapsedMilliseconds / 1000).floor();
          // Dynamic Star Thresholds
          final thresholds = _getStarThresholds(widget.levelId);
          if (seconds < thresholds[0]) _earnedStars = 3;
          else if (seconds < thresholds[1]) _earnedStars = 2;
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
    if (levelId <= 18) return [130, 240]; // 9x9
    return [200, 400]; // 10x10 (L19-20)
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
                                          Text("Time: ${_formatTime()}", style: const TextStyle(color: Colors.white70, fontSize: 18)),
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
                                                          if (widget.levelId < 20 && mounted) {
                                                              final nextLevelId = widget.levelId + 1;
                                                              
                                                              // NEW: Show Level Announcement First
                                                              setState(() {
                                                                  _targetLevelId = nextLevelId;
                                                                  _showLevelAnnouncement = true;
                                                              });
                                                              
                                                              await Future.delayed(const Duration(milliseconds: 2000));
                                                              
                                                              if (!mounted) return;

                                                              final nextGameLevel = LevelGenerator.generate(nextLevelId);
                                                              
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
                                       width: 220, height: 220,
                                       decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           // Ultra Neon Green Gradient
                                           gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [Color(0xFFB2FF59), Color(0xFF76FF03)], // Lime to Neon Green
                                           ),
                                           boxShadow: [
                                               // Intense inner glow
                                               BoxShadow(color: const Color(0xFF76FF03).withOpacity(0.8), blurRadius: 25, spreadRadius: 2),
                                               // Outer Ambient Glow
                                               BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 50, spreadRadius: 10),
                                               // Bottom Shadow for depth
                                               BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(5, 8)),
                                           ],
                                           border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                       ),
                                       child: Container(
                                           margin: const EdgeInsets.all(4), // Inner rim
                                           decoration: BoxDecoration(
                                               shape: BoxShape.circle,
                                               color: Colors.transparent,
                                               border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                                           ),
                                           child: const Center(
                                               child: Icon(
                                                   Icons.play_arrow_rounded, 
                                                   color: Colors.white, 
                                                   size: 140, // Much larger icon 
                                                   shadows: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2,2))]
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
          _showWinUI = false;
          _hasStarted = false; // SHOW START BUTTON
          _confettiParticles.clear();
          _lockedPaths.clear();
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
      return IgnorePointer(
          child: AnimatedBuilder(
              animation: _handController,
              builder: (context, child) {
                   double t = _handController.value;
                   double row, col;
                   // (0,0) -> (0,2) -> (2,2)
                   if (t < 0.5) {
                       double localT = t * 2; 
                       row = 0;
                       col = localT * 2; 
                   } else {
                       double localT = (t - 0.5) * 2; 
                       col = 2;
                       row = localT * 2;
                   }

                   return Stack(
                       children: [
                           Positioned(
                               left: col * cellSize + (cellSize/2) - 0, 
                               top: row * cellSize + (cellSize/2) - 0,
                               child: Transform.translate(
                                   offset: const Offset(10, 10),
                                   child: const Icon(Icons.touch_app, size: 50, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)])
                               ),
                           ),
                           const Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text("Swipe to Connect", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                           )
                       ],
                   );
              },
          ),
      );
  }

  GridPoint _getGridPoint(Offset localPosition, double size) {
    double cellSize = size / widget.level.cols;
    int col = (localPosition.dx / cellSize).floor().clamp(0, widget.level.cols - 1);
    int row = (localPosition.dy / cellSize).floor().clamp(0, widget.level.rows - 1);
    return GridPoint(row, col);
  }

  void _handleInputStart(DragStartDetails details, double size) {
    _resetInactivityTimer(); // Reset on input
    GridPoint p = _getGridPoint(details.localPosition, size);
    widget.level.dotPositions.forEach((color, locations) {
        if (locations.contains(p)) {
            // Check if trying to modify a locked path
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
                // Check if trying to continue a locked path
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
      if (_activeColor == null) return;
      GridPoint p = _getGridPoint(details.localPosition, size);
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
            ..color = Colors.white.withOpacity(0.25) // Increased from 0.08
            ..strokeWidth = 2.0 // Thicker lines
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

    _NeonPathPainter({
        required this.level, 
        required this.paths, 
        required this.cellSize, 
        required this.flowPhase,
        this.hintPath,
        this.lockedPaths = const {},
    });

    @override
    void paint(Canvas canvas, Size size) {
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

    @override bool shouldRepaint(_NeonPathPainter old) => old.flowPhase != flowPhase || old.hintPath != hintPath;
}
class _NeonNodePainter extends CustomPainter {
    final GameLevel level;
    final double cellSize;
    final double pulseValue; 
    _NeonNodePainter({required this.level, required this.cellSize, required this.pulseValue});
    @override
    void paint(Canvas canvas, Size size) {
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
    @override bool shouldRepaint(_NeonNodePainter old) => old.pulseValue != pulseValue;
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

import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'dart:math' as math;
import 'dart:ui' as ui; 
import '../models/game_level_model.dart';

class GameScreen extends StatefulWidget {
  final GameLevel level;
  final String? dotAssetPath;

  const GameScreen({
    super.key, 
    required this.level,
    this.dotAssetPath,
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
        // NEW: Timer Display in Title
        title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10)]
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    const Icon(Icons.timer_outlined, color: Colors.cyanAccent, size: 22),
                    const SizedBox(width: 10),
                    Text(
                        _formatTime(), 
                        style: TextStyle(
                            fontFamily: 'monospace', 
                            fontWeight: FontWeight.w700,
                            color: Colors.cyanAccent.shade100,
                            fontSize: 22,
                            letterSpacing: 1.5,
                            shadows: [Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 5)]
                        )
                    ),
                ],
            ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.05),
        elevation: 0,
        flexibleSpace: ClipRect(
            child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
            ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
        ),
        actions: [
            IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _resetGame,
            )
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
                                                AnimatedBuilder(animation: _flowController, builder: (_,__) => CustomPaint(size: Size(gridSize, gridSize), painter: _NeonPathPainter(level: widget.level, paths: _paths, cellSize: gridSize / widget.level.cols, flowPhase: _flowController.value))),
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

            // 5. Win Dialog Overlay
            if (_showWinUI) _buildWinOverlay(),
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
          if (!(startOk || reverseOk)) { allConnected = false; }
          filled.addAll(path);
      });

      if (!allConnected) return;

      bool boardFull = filled.length == (widget.level.rows * widget.level.cols);
      
      if (boardFull) {
          _stopGame();
          // Score Calculation
          int seconds = (_elapsedMilliseconds / 1000).floor();
          if (seconds < 5) _earnedStars = 3;
          else if (seconds < 10) _earnedStars = 2;
          else _earnedStars = 1;

          setState(() {
              _showWinUI = true;
          });
          _triggerConfetti();
      }
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
                                                      icon: const Icon(Icons.replay, color: Colors.white),
                                                      onPressed: _resetGame,
                                                      iconSize: 30,
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                          Navigator.pop(context, _earnedStars);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.cyanAccent,
                                                          foregroundColor: Colors.black,
                                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                                                      ),
                                                      child: const Text("CONTINUE", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildStartOverlay() {
      return Stack(
          children: [
               // Blur BG
               Positioned.fill(
                   child: BackdropFilter(
                       filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                       child: Container(color: Colors.black.withOpacity(0.6)),
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
                                           // Rich Orange Gradient
                                           gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [Color(0xFFFFA726), Color(0xFFFF5722)], // Orange to Deep Orange
                                           ),
                                           boxShadow: [
                                               // Intense inner glow
                                               BoxShadow(color: Colors.orangeAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 0),
                                               // Outer Ambient Glow
                                               BoxShadow(color: Colors.deepOrange.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
                                               // Bottom Shadow for depth
                                               BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(5, 5)),
                                           ],
                                           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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

  void _resetGame() {
      _stopGame();
      setState(() {
          _paths.clear();
          _showWinUI = false;
          _confettiParticles.clear();
          if (widget.level.id == 1) _handController.repeat();
      });
      _startGame();
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
    final List<GridPoint>? hintPath; // NEW

    _NeonPathPainter({
        required this.level, 
        required this.paths, 
        required this.cellSize, 
        required this.flowPhase,
        this.hintPath,
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
            canvas.drawPath(path, Paint()..color = color.color.withOpacity(0.5)..strokeWidth = cellSize * 0.6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
            canvas.drawPath(path, Paint()..color=color.color..strokeWidth=cellSize*0.3..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
            canvas.drawPath(path, Paint()..color=Colors.white.withOpacity(0.5)..strokeWidth=cellSize*0.1..style=PaintingStyle.stroke..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
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

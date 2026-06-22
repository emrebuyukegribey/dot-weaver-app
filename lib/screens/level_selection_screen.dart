import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../l10n/app_localizations.dart';
import 'dart:math' as math;
import '../models/level_model.dart';
import '../models/game_level_model.dart'; // Ensure DotColor is imported
import '../models/island_model.dart';
import '../services/game_data_manager.dart';
import '../widgets/ad_banner.dart';
import 'game_screen.dart';
import '../services/level_generator.dart';
import '../../main.dart'; // for routeObserver

class LevelSelectionScreen extends StatefulWidget {
  final IslandModel island;

  const LevelSelectionScreen({
    super.key,
    required this.island,
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> with TickerProviderStateMixin, RouteAware {
  late List<LevelModel> _levels;
  late List<AnimationController> _floatingControllers;
  late AnimationController _pathAnimationController;
  late AnimationController _bgController;
  final List<_BackgroundParticle> _particles = [];
  final ScrollController _scrollController = ScrollController();
  


  @override
  void initState() {
    super.initState();
    _levels = widget.island.levels;
    _initAnimations();
    _initParticles();
    _refreshLevels(); // Load latest stars/unlocks immediately
    
    // Auto-Scroll to latest level after frame build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLevel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows up.
    _refreshLevels();
    // Auto-scroll to the current level (e.g. if user just unlocked a new one)
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLevel());
  }
  
  void _scrollToCurrentLevel() {
      // Find the last unlocked level index
      int targetIndex = GameDataManager().getLastUnlockedLevelIndex(widget.island.id, _levels.length);
      
      // Calculate offset to center the level
      // Level Y position is roughly: 100 + (index * 120)
      // We want this Y to be in the middle of screen if possible.
      double levelY = 100.0 + (targetIndex * 120.0);
      double screenH = MediaQuery.of(context).size.height;
      
      // Target: Level should be near bottom (approx 20% from bottom)
      double offset = levelY - (screenH * 0.7); 
      
      // Clamp
      if (offset < 0) offset = 0;
      if (_scrollController.hasClients) { // minimal check
         double maxScroll = _scrollController.position.maxScrollExtent;
         if (offset > maxScroll) offset = maxScroll;
         
         _scrollController.animateTo(
             offset, 
             duration: const Duration(milliseconds: 1000), 
             curve: Curves.easeInOutCubic
         );
      }
  }

  void _initAnimations() {
    _pathAnimationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat();

    _floatingControllers = List.generate(_levels.length, (index) {
        final random = math.Random();
        final durationMs = 2000 + random.nextInt(2000);
        final controller = AnimationController(
            vsync: this,
            duration: Duration(milliseconds: durationMs)
        );
        Future.delayed(Duration(milliseconds: random.nextInt(1000)), () {
            if (mounted) controller.repeat(reverse: true);
        });
        return controller;
    });

    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _bgController.addListener(_updateParticles);
  }

  void _initParticles() {
      _particles.clear();
      for (int i = 0; i < 60; i++) { // More particles
          _spawnParticle(i, true); 
      }
  }

  void _spawnParticle(int index, bool randomY) {
      final random = math.Random();
      String? particleText;
      // DEBUG: Check ID and Name
      // print("Particle Spawn: Island ID=${widget.island.id}, Name=${widget.island.name}");
      
      if (widget.island.id == "2" || widget.island.name.contains("Number")) {
          // NUMBER ISLAND: Spawn Numbers 0-9
          particleText = "${random.nextInt(10)}"; // 0-9
      } else if (widget.island.id == "3" || widget.island.name.contains("Operation")) {
          // OPERATION ISLAND: Spawn Symbols +, -, ×, ÷
          const symbols = ["+", "-", "×", "÷"];
          particleText = symbols[random.nextInt(symbols.length)];
      }

      if (_particles.length <= index) {
          _particles.add(_BackgroundParticle(
              x: 0.5, y: 1.0, 
              vx: 0, vy: 0, 
              radius: 0, color: Colors.white, life: 1.0,
              text: particleText
          ));
      } else {
         // Reuse existing
         _particles[index].text = particleText;
      }
      
      var p = _particles[index];
      // Spawn at bottom, spread horizontally
      p.x = 0.2 + random.nextDouble() * 0.6; // Keep somewhat central
      p.y = randomY ? random.nextDouble() : 1.05; // Start below screen if new spawn
      p.radius = random.nextDouble() * 20 + 5;
      
      // Velocity: Slower Upward and slight spread
      p.vx = (random.nextDouble() - 0.5) * 0.003; // Reduced horizontal drift (was 0.005)
      p.vy = -(random.nextDouble() * 0.005 + 0.002); // Much Slower Upward (was 0.01 + 0.005)
      
      p.life = 1.0;
      p.color = [
          Colors.cyanAccent, Colors.purpleAccent, Colors.deepOrangeAccent, 
          Colors.pinkAccent, Colors.limeAccent
      ][random.nextInt(5)];
  }

  void _updateParticles() {
      for (int i = 0; i < _particles.length; i++) {
          var p = _particles[i];
          p.x += p.vx;
          p.y += p.vy;
          p.life -= 0.002; // Slower fade out (was 0.005) to match slower speed
          
          // Respawn if dead or off top
          if (p.life <= 0 || p.y < -0.1) {
              _spawnParticle(i, false);
          }
      }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _bgController.dispose();
    _scrollController.dispose();
    _pathAnimationController.dispose();
    for (var c in _floatingControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _refreshLevels() {
      setState(() {
          _levels = List.generate(widget.island.levels.length, (i) => LevelModel(
              id: i + 1,
              assetPath: widget.island.levels[i].assetPath,
              starsEarned: GameDataManager().getStars(widget.island.id, i+1),
              isLocked: !GameDataManager().isLevelUnlocked(widget.island.id, i + 1),
          ));
      });
  }

  /// Maps an island background to its pre-blurred variant
  /// (e.g. ".../color_island_bg.png" -> ".../color_island_bg_blur.png").
  /// Used only for the level map background so the soft look needs no
  /// runtime blur filter (which causes ghosting of the scrolling node numbers).
  String _blurredBgPath(String path) {
    if (path.endsWith('_bg.png')) {
      return path.replaceFirst('_bg.png', '_bg_blur.png');
    }
    return path;
  }

  Offset _getLevelPosition(int index, double width) {
    final double xCenter = width / 2;
    // Increase amplitude to 40% (total 80% width usage) to make it less vertical
    final double xAmplitude = width * 0.4; 
    // Decrease vertical spacing to emphasize curve
    const double ySpacing = 120.0;
    
    final double y = 100 + (index * ySpacing);
    // Increase frequency slightly to sinusoidal wave turns faster
    final double xOffset = math.sin(index * 1.0) * xAmplitude; 
    return Offset(xCenter + xOffset, y);
  }

  @override
  Widget build(BuildContext context) {
    int starsObtained = _levels.fold(0, (sum, level) => sum + level.starsEarned);
    
    // Show all levels (User requested to not hide locked levels)
    int visibleCount = _levels.length;
    
    // Match ySpacing (120.0) + padding
    // Match ySpacing (120.0) + minimal padding
    final double totalHeight = 100 + (visibleCount * 120.0) + 50.0;

    return Scaffold(
      bottomNavigationBar: const AdBanner(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final List<Offset> basePositions = List.generate(visibleCount, (i) => _getLevelPosition(i, screenWidth));

          return Stack(
            children: [
              // Background.
              // ROOT CAUSE of the "ghost numbers": the background image is fixed
              // (it does not scroll). The scrolling level map covers/reveals parts
              // of it, and the empty area above level 1 (scrolled to the top) exposes
              // the image's busy top region — which on the Number/Operation islands
              // contains large baked-in numbers, and on the Color island contains
              // panel/light details that read as faint digits.
              // Fix: use a heavily pre-blurred background asset (*_bg_blur.png, blur
              // baked in offline) plus a dim overlay, so the image becomes a soft
              // color wash with no recognizable numbers/shapes. No runtime blur
              // filter is used (that also caused compositing ghosting while scrolling).
              Positioned.fill(
                child: RepaintBoundary(
                  child: Container(
                    decoration: BoxDecoration(
                      image: widget.island.backgroundImagePath.contains('assets')
                         ? DecorationImage(image: AssetImage(_blurredBgPath(widget.island.backgroundImagePath)), fit: BoxFit.cover)
                         : null,
                      gradient: widget.island.backgroundImagePath.contains('assets') ? null : RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [widget.island.primaryColor.withValues(alpha: 0.8), Colors.black],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated Particles
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _bgController,
                            builder: (context, child) => CustomPaint(
                              painter: _BackgroundEffectPainter(particles: _particles),
                            ),
                          ),
                        ),
                        // Dim overlay: pushes the background back so it stays subtle.
                        Positioned.fill(
                          child: Container(color: Colors.black.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                  // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Custom Green Back Button (Capsule/Oval)
                          _BouncingButton(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                  width: 80, height: 50, // Oval shape
                                  decoration: BoxDecoration(
                                      // Orange Gradient
                                      gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Color(0xFFFFAB40), Color(0xFFFF6D00)], // Vivid Orange
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: Colors.black, width: 3),
                                      boxShadow: [
                                          // 3D Depth
                                          BoxShadow(color: Colors.black, offset: const Offset(0, 4), blurRadius: 0),
                                          // Inner shine (simulated)
                                          BoxShadow(color: Colors.white.withValues(alpha: 0.5), offset: const Offset(0, -2), blurRadius: 0, spreadRadius: -2)
                                      ]
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 36)
                                  ),
                              ),
                          ),
                          
                          // 2. 3D Star Badge (Slightly smaller than previous huge one)
                          _buildTopBarBadge(icon: Icons.star_rounded, text: '$starsObtained', color: const Color(0xFFFFD700)),
                        ],
                      ),
                    ),

                    // Level Map
                    // RepaintBoundary isolates the scrolling layer from the animated
                    // background so the two don't share a raster (part of the fix for
                    // the ghost-number trailing under Impeller).
                    Expanded(
                      child: RepaintBoundary(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          height: totalHeight,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_pathAnimationController, ..._floatingControllers]),
                            builder: (context, child) {

                                final currentPositions = List.generate(visibleCount, (i) {
                                    final floatVal = Curves.easeInOut.transform(_floatingControllers[i].value);
                                    final floatOffset = -8.0 + (floatVal * 16.0); 
                                    return basePositions[i].translate(0, floatOffset);
                                });

                                return Stack(
                                  children: [
                                     CustomPaint(
                                       size: Size(screenWidth, totalHeight),
                                       painter: LevelPathPainter(
                                          positions: currentPositions,
                                          color: widget.island.primaryColor,
                                          dashPhase: _pathAnimationController.value,
                                          levels: _levels,
                                       ),
                                      ),
                                     ...List.generate(visibleCount, (index) {
                                         final pos = currentPositions[index];
                                         return Positioned(
                                            left: pos.dx - 40,
                                            top: pos.dy - 40,
                                            // RepaintBoundary caches each node's raster so the
                                            // per-frame floating animation re-blits a cached
                                            // texture instead of re-rasterizing the number text,
                                            // which (under Impeller) leaves faint ghost trails.
                                            child: RepaintBoundary(
                                              child: _buildLevelItemWrapper(_levels[index], index),
                                            ),
                                         );
                                     }),
                                  ],
                                );
                            },
                          ),
                        ),
                      ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildTopBarBadge({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Larger padding
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2), // Thicker border
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)] // Glow
      ),
      child: Row(
          children: [
              Icon(icon, color: color, size: 32), // Larger Icon
              const SizedBox(width: 12), 
              Text(
                  text, 
                  style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 28, // Larger Text
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1,1))]
                  )
              )
          ]
      ),
    );
  }

  Widget _buildLevelButton(LevelModel level, int index) {
      const double size = 80.0;

      // Island-specific color scheme
      final Color themeColor = widget.island.id == "2" || widget.island.name.contains("Number")
          ? const Color(0xFFAB47BC) // Purple for Number Island
          : (widget.island.id == "3" || widget.island.name.contains("Operation")
              ? const Color(0xFF43A047) // Green for Operation Island
              : const Color(0xFF00E5FF)); // Cyan for Color Island
      
      final bool isLocked = level.isLocked;

      return Container(
          width: size, height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Subtle Border
              border: Border.all(
                  color: isLocked ? const Color(0xFF455A64) : Colors.white.withValues(alpha: 0.5), 
                  width: 2
              ),
              boxShadow: [
                  // Deep Shadow
                  BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 10, offset: const Offset(0, 6)),
                  // Glow
                  if (!isLocked)
                     BoxShadow(color: themeColor.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: -2),
              ],
              // COLORED SPHERE GRADIENT
              gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.4),
                  radius: 1.1,
                  colors: isLocked
                  ? [
                      const Color(0xFF90A4AE), 
                      const Color(0xFF546E7A),
                      const Color(0xFF263238), 
                    ]
                  : [
                      // Highlight -> Main -> Deep Shadow
                      Color.lerp(Colors.white, themeColor, 0.4)!, // Very bright highlight
                      themeColor, 
                      Color.lerp(themeColor, Colors.black, 0.7)!, // Dark shadow
                    ],
                  stops: const [0.1, 0.5, 1.0],
              )
          ),
          child: Stack(
              children: [
                  // Top Shine (Glass)
                  Positioned(
                      top: 0, left: 10, right: 10, height: size / 2.5,
                      child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                      Colors.white.withValues(alpha: 0.4),
                                      Colors.white.withValues(alpha: 0.0),
                                  ]
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(size/2))
                          ),
                      ),
                  ),
                  
                  // Content (Level Number)
                  Center(
                    child: isLocked
                      ? const Icon(Icons.lock_outline_rounded, color: Colors.white24, size: 28)
                      : Text(
                          "${level.id}",
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))
                            ]
                          ),
                        ),
                  ),
              ],
          ),
      );
  }

  Widget _buildStars(LevelModel level) {
      // 3D, Larger, Higher
      return SizedBox(
        height: 40, // More height
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start, 
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
             // Arch logic: Mid high, sides low
             double dy = (i == 1) ? 0 : 8.0; 
             return Transform.translate(
                 offset: Offset(0, dy), 
                 child: Stack(
                     children: [
                         // Shadow
                         Positioned(
                           top:2, left:1,
                           child: Icon(Icons.star_rounded, size: 30, color: Colors.black.withValues(alpha: 0.5))
                         ),
                         // Star
                         Icon(
                            Icons.star_rounded,
                            size: 30, 
                            color: i < level.starsEarned ? const Color(0xFFFFD700) : Colors.black.withValues(alpha: 0.3),
                         )
                     ]
                 )
             );
          }),
        ),
      );
  }

  Widget _buildLevelItemWrapper(LevelModel level, int index) {
      return GestureDetector(
          onTapUp: (details) {
              if (level.isLocked) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).levelLocked)));
                   return;
              }
              _handleLevelTap(level, details);
          },
          child: Stack(
             alignment: Alignment.topCenter, // Align stars to TOP center
             clipBehavior: Clip.none,
             children: [
                 _buildLevelButton(level, index),
                 if (!level.isLocked)
                     Positioned(
                         top: -24, // Much higher
                         child: _buildStars(level),
                     ),
             ],
          ),
      );
  }

  Future<void> _handleLevelTap(LevelModel level, TapUpDetails details) async {
       // Generate Level using Generator with island context
       GameLevel gameLevel = LevelGenerator.generate(level.id, islandId: widget.island.id);

       // Calculate Zoom Origin
       final Size screenSize = MediaQuery.of(context).size;
       final double relativeX = (details.globalPosition.dx / screenSize.width) * 2 - 1;
       final double relativeY = (details.globalPosition.dy / screenSize.height) * 2 - 1;
       final Alignment tapAlignment = Alignment(relativeX, relativeY);

       await Navigator.push(
         context, 
         PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            reverseTransitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => GameScreen(
                level: gameLevel, 
                dotAssetPath: widget.island.dotAssetPath,
                islandId: widget.island.id,
                levelId: level.id,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var curve = CurvedAnimation(parent: animation, curve: Curves.easeInOutQuart);
                return ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
                    alignment: tapAlignment,
                    child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
                        child: child
                    ),
                );
            }
         )
       );
       
       _refreshLevels();
  }
}

class LevelPathPainter extends CustomPainter {
    final List<Offset> positions;
    final Color color;
    final double dashPhase;
    final List<LevelModel> levels;
    
    LevelPathPainter({
      required this.positions, 
      required this.color, 
      required this.dashPhase,
      required this.levels,
    });

    @override
    void paint(Canvas canvas, Size size) {
        if (positions.isEmpty) return;
        
        // Base paint for active path
        final activePaint = Paint()
           ..color = color.withValues(alpha: 1.0)
           ..style = PaintingStyle.stroke
           ..strokeWidth = 6.0
           ..strokeCap = StrokeCap.round
           ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3); // Glow effect

        final activeCorePaint = Paint()
           ..color = Colors.white.withValues(alpha: 0.8)
           ..style = PaintingStyle.stroke
           ..strokeWidth = 2.0
           ..strokeCap = StrokeCap.round;

        // Base paint for inactive path
        final inactivePaint = Paint()
           ..color = color.withValues(alpha: 0.3)
           ..style = PaintingStyle.stroke
           ..strokeWidth = 4.0
           ..strokeCap = StrokeCap.round;

        
        for (int i = 0; i < positions.length - 1; i++) {
            final p1 = positions[i];
            final p2 = positions[i+1];
            
            // Logic: Is this segment "active"?
            // A segment from Level i to Level i+1 is active if Level i is COMPLETED (stars > 0).
            bool isActive = false;
            if (i < levels.length) {
                isActive = levels[i].starsEarned > 0;
            }

            final path = Path();
            path.moveTo(p1.dx, p1.dy);
            
            final cp1 = Offset(p1.dx, (p1.dy + p2.dy) / 2);
            final cp2 = Offset(p2.dx, (p1.dy + p2.dy) / 2);
            path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
            
            if (isActive) {
                // Draw Solid + Glow
                canvas.drawPath(path, activePaint); // Glow/Main color
                canvas.drawPath(path, activeCorePaint); // White core
            } else {
                // Draw Dashed + Dim
                _drawDashedPath(canvas, path, 15, 12, inactivePaint, dashPhase * 27.0);
            }
        }
    }
    
    void _drawDashedPath(Canvas canvas, Path path, double dashWidth, double dashSpace, Paint paint, double phaseOffset) {
        final ui.PathMetrics pathMetrics = path.computeMetrics();
        for (ui.PathMetric pathMetric in pathMetrics) {
             double distance = -phaseOffset;
             while (distance < pathMetric.length) {
                 double start = distance < 0 ? 0 : distance;
                 double end = distance + dashWidth;
                 if (end > pathMetric.length) end = pathMetric.length;
                 if (end > start) canvas.drawPath(pathMetric.extractPath(start, end), paint);
                 distance += dashWidth + dashSpace;
             }
        }
    }

    @override
    bool shouldRepaint(covariant LevelPathPainter old) => true; 
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

class _BackgroundParticle {
    double x; 
    double y; 
    double vx;
    double vy;
    double radius;
    double life; // 1.0 to 0.0
    Color color;
    String? text; // NEW: Optional text for Number Island
    
    _BackgroundParticle({
        required this.x, required this.y, 
        required this.vx, required this.vy,
        required this.radius, required this.life, required this.color,
        this.text,
    });
}

class _BackgroundEffectPainter extends CustomPainter {
    final List<_BackgroundParticle> particles;
    
    _BackgroundEffectPainter({required this.particles});

    @override
    void paint(Canvas canvas, Size size) {
        for (var p in particles) {
            Color particleColor = p.color.withValues(alpha: p.color.opacity * p.life);

            if (p.text != null) {
                // DRAW TEXT (NUMBER)
                final textSpan = TextSpan(
                    text: p.text,
                    style: TextStyle(
                        color: particleColor,
                        fontSize: p.radius * 2.5, // Scale text with radius
                        fontWeight: FontWeight.bold,
                        shadows: [
                            Shadow(color: p.color.withValues(alpha: 0.5 * p.life), blurRadius: 10, offset: Offset(0,0))
                        ]
                    ),
                );
                final textPainter = TextPainter(
                    text: textSpan,
                    textDirection: TextDirection.ltr,
                );
                textPainter.layout();
                // Center text at particle position
                textPainter.paint(canvas, Offset((p.x * size.width) - textPainter.width/2, (p.y * size.height) - textPainter.height/2));

            } else {
                // DRAW CIRCLE (Default)
                final paint = Paint()
                    ..color = particleColor
                    ..style = PaintingStyle.fill
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15); 
                
                canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.radius, paint);
            }
        }
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

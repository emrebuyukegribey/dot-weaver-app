import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../models/level_model.dart';
import '../models/game_level_model.dart'; // Ensure DotColor is imported
import '../models/island_model.dart';
import '../services/game_data_manager.dart';
import 'game_screen.dart';
import '../services/level_generator.dart';

class LevelSelectionScreen extends StatefulWidget {
  final IslandModel island;

  const LevelSelectionScreen({
    super.key,
    required this.island,
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> with TickerProviderStateMixin {
  late List<LevelModel> _levels;
  late List<AnimationController> _floatingControllers;
  late AnimationController _pathAnimationController;
  final ScrollController _scrollController = ScrollController();
  


  @override
  void initState() {
    super.initState();
    _levels = widget.island.levels;
    _initAnimations();
    _refreshLevels(); // Load latest stars/unlocks immediately
    
    // Auto-Scroll to latest level after frame build
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
      double offset = levelY - (screenH / 2) + 60; // +60 for half item height approx
      
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
  }

  @override
  void dispose() {
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
              isLocked: false, // TEMPORARY: Unlock all levels for testing
          ));
      });
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
    // Match ySpacing (120.0) + padding
    final double totalHeight = 100 + (_levels.length * 120.0) + 200.0;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final List<Offset> basePositions = List.generate(_levels.length, (i) => _getLevelPosition(i, screenWidth));

          return Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  image: widget.island.backgroundImagePath.contains('assets') 
                     ? DecorationImage(image: AssetImage(widget.island.backgroundImagePath), fit: BoxFit.cover)
                     : null,
                  gradient: widget.island.backgroundImagePath.contains('assets') ? null : RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [widget.island.primaryColor.withOpacity(0.8), Colors.black],
                  ),
                ),
                 child: BackdropFilter(
                     filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                     child: Container(color: Colors.black.withOpacity(0.4)),
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
                                          BoxShadow(color: Colors.white.withOpacity(0.5), offset: const Offset(0, -2), blurRadius: 0, spreadRadius: -2)
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
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          height: totalHeight,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_pathAnimationController, ..._floatingControllers]),
                            builder: (context, child) {
                                final currentPositions = List.generate(_levels.length, (i) {
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
                                       ),
                                     ),
                                     ...List.generate(_levels.length, (index) {
                                         final pos = currentPositions[index];
                                         return Positioned(
                                            left: pos.dx - 40, 
                                            top: pos.dy - 40,
                                            child: _buildLevelItemWrapper(_levels[index], index),
                                         );
                                     }),
                                  ],
                                );
                            },
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
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2), // Thicker border
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)] // Glow
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

  Color _getNeonColor(DotColor color) {
      switch (color) {
          case DotColor.red: return const Color(0xFFFF1744); // Neon Red
          case DotColor.blue: return const Color(0xFF00E5FF); // Neon Cyan/Blue
          case DotColor.green: return const Color(0xFF00E676); // Neon Green
          case DotColor.yellow: return const Color(0xFFFFEA00); // Neon Yellow
          case DotColor.orange: return const Color(0xFFFF9100); // Neon Orange
          case DotColor.purple: return const Color(0xFFD500F9); // Neon Purple
          default: return const Color(0xFF00E5FF);
      }
  }

  Widget _buildLevelButton(LevelModel level, int index) {
      const double size = 80.0;
      
      // Look up colors for this level
      final List<DotColor> dotColors = LevelGenerator.levelConfigs[level.id] ?? [DotColor.red, DotColor.blue];
      
      // COLOR SELECTION LOGIC:
      // Choose a background color that CONSTRASTS with the dots inside.
      // We prefer cool/dark colors for backgrounds if possible, but neon is key.
      const List<DotColor> candidates = [
          DotColor.purple, // Best contrast usually
          DotColor.blue,
          DotColor.green,
          DotColor.orange,
          DotColor.red, 
          DotColor.yellow
      ];
      
      // Uniform Color for all levels (Cyan/Blue feel)
      final Color themeColor = const Color(0xFF00E5FF); // Cyan Accent
      
      final bool isLocked = level.isLocked;

      return Container(
          width: size, height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Subtle Border
              border: Border.all(
                  color: isLocked ? const Color(0xFF455A64) : Colors.white.withOpacity(0.5), 
                  width: 2
              ),
              boxShadow: [
                  // Deep Shadow
                  BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 10, offset: const Offset(0, 6)),
                  // Glow
                  if (!isLocked)
                     BoxShadow(color: themeColor.withOpacity(0.6), blurRadius: 20, spreadRadius: -2),
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
                                      Colors.white.withOpacity(0.4),
                                      Colors.white.withOpacity(0.0),
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
                           child: Icon(Icons.star_rounded, size: 30, color: Colors.black.withOpacity(0.5))
                         ),
                         // Star
                         Icon(
                            Icons.star_rounded,
                            size: 30, 
                            color: i < level.starsEarned ? const Color(0xFFFFD700) : Colors.black.withOpacity(0.3),
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
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Level Locked! Complete previous levels.")));
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
       // Generate Level using Generator
       GameLevel gameLevel = LevelGenerator.generate(level.id);

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

// PAINTER: Draws two specific dots and a connecting line
class _ColorConnectionPainter extends CustomPainter {
    final List<Color> colors;
    
    _ColorConnectionPainter({required this.colors});

    @override
    void paint(Canvas canvas, Size size) {
        if (colors.length == 3) {
            // Triangle Layout for 3 Colors
            final Offset p1 = Offset(size.width * 0.5, size.height * 0.2); // Top
            final Offset p2 = Offset(size.width * 0.2, size.height * 0.8); // Bottom Left
            final Offset p3 = Offset(size.width * 0.8, size.height * 0.8); // Bottom Right
            
            // Draw Connections (Triangle)
            _drawLine(canvas, p1, p2);
            _drawLine(canvas, p2, p3);
            _drawLine(canvas, p3, p1);
            
            // Draw Dots
            _drawDot(canvas, p1, colors[0]);
            _drawDot(canvas, p2, colors[1]);
            _drawDot(canvas, p3, colors[2]);

        } else if (colors.length == 4) {
            // Square/Spiral Layout for 4 Colors
            final Offset p1 = Offset(size.width * 0.25, size.height * 0.25);
            final Offset p2 = Offset(size.width * 0.75, size.height * 0.25);
            final Offset p3 = Offset(size.width * 0.75, size.height * 0.75);
            final Offset p4 = Offset(size.width * 0.25, size.height * 0.75);
            
            // Draw Connections (Square)
            _drawLine(canvas, p1, p2);
            _drawLine(canvas, p2, p3);
            _drawLine(canvas, p3, p4);
            _drawLine(canvas, p4, p1);
            
            // Draw Dots
            _drawDot(canvas, p1, colors[0]);
            _drawDot(canvas, p2, colors[1]);
            _drawDot(canvas, p3, colors[2]);
            _drawDot(canvas, p4, colors[3]);

        } else if (colors.length == 5) {
            // Pentagon Layout for 5 Colors
            final double radius = size.width * 0.35;
            final Offset center = Offset(size.width * 0.5, size.height * 0.5);
            final List<Offset> points = List.generate(5, (i) {
                double angle = (i * 2 * math.pi / 5) - (math.pi / 2); // Start from top
                return Offset(
                    center.dx + radius * math.cos(angle),
                    center.dy + radius * math.sin(angle)
                );
            });
            
            // Draw Connections (Pentagon / Star)
            for (int i = 0; i < 5; i++) {
                _drawLine(canvas, points[i], points[(i + 1) % 5]);
            }
            
            // Draw Dots
            for (int i = 0; i < 5; i++) {
                _drawDot(canvas, points[i], colors[i]);
            }

        } else {
             // Default Line Layout (2 Colors)
            final Offset start = Offset(size.width * 0.2, size.height * 0.8);
            final Offset end = Offset(size.width * 0.8, size.height * 0.2);
            Color c1 = colors.isNotEmpty ? colors[0] : Colors.red;
            Color c2 = colors.length > 1 ? colors[1] : c1;

            _drawLine(canvas, start, end);
            _drawDot(canvas, start, c1);
            _drawDot(canvas, end, c2);
        }
    }
    
    void _drawLine(Canvas canvas, Offset p1, Offset p2) {
        final Paint linePaint = Paint()
            ..shader = LinearGradient(colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.2)]).createShader(Rect.fromPoints(p1, p2))
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke;
        canvas.drawLine(p1, p2, linePaint);
    }

    void _drawDot(Canvas canvas, Offset center, Color color) {
        // White Border for Contrast
         canvas.drawCircle(center, 7.0, Paint()..color = Colors.white);
         
        // Glow
         canvas.drawCircle(center, 8.0, Paint()..color = color.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
         // Core
         canvas.drawCircle(center, 5.0, Paint()..color = color);
         // Shine
         canvas.drawCircle(center + const Offset(-1.5, -1.5), 1.5, Paint()..color = Colors.white.withOpacity(0.8));
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LevelPathPainter extends CustomPainter {
    final List<Offset> positions;
    final Color color;
    final double dashPhase;
    
    LevelPathPainter({required this.positions, required this.color, required this.dashPhase});

    @override
    void paint(Canvas canvas, Size size) {
        if (positions.isEmpty) return;
        
        final paint = Paint()
           ..color = color.withOpacity(0.5)
           ..style = PaintingStyle.stroke
           ..strokeWidth = 6
           ..strokeCap = StrokeCap.round;

        final path = Path();
        path.moveTo(positions[0].dx, positions[0].dy);
        
        for (int i = 0; i < positions.length - 1; i++) {
            final p1 = positions[i];
            final p2 = positions[i+1];
            final cp1 = Offset(p1.dx, (p1.dy + p2.dy) / 2);
            final cp2 = Offset(p2.dx, (p1.dy + p2.dy) / 2);
            path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
        }
        
        _drawDashedPath(canvas, path, 15, 12, paint, dashPhase * 27.0);
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

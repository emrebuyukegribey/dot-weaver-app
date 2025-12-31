import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../models/island_model.dart';
import '../models/level_model.dart';
import '../services/game_data_manager.dart';
import 'level_selection_screen.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> with TickerProviderStateMixin {
  late List<IslandModel> islands;
  final double _nodeHeight = 320.0; // Increased spacing for larger cards
  
  // Animation Controllers
  late List<AnimationController> _islandControllers;
  late AnimationController _pathController;
  late AnimationController _bgController;
  
  final ScrollController _scrollController = ScrollController();
  final List<_BackgroundElement> _elements = [];

  @override
  void initState() {
    super.initState();
    _loadIslands();
    _initAnimations();
    _initBackgroundElements();
    
    // Scroll to bottom (start) initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
       }
    });
  }

  void _initAnimations() {
    // 1. Path Flow Animation
    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), 
    )..repeat();

    // 2. Background Animation
    _bgController = AnimationController(
        vsync: this, duration: const Duration(seconds: 15))..repeat(); // Slower
    _bgController.addListener(_updateBackground);

    // 3. Island Floating Animations
    _islandControllers = List.generate(4, (index) {
      final random = math.Random();
      final durationMs = 3000 + random.nextInt(2000); 
      
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationMs),
      );

      Future.delayed(Duration(milliseconds: random.nextInt(1000)), () {
        if (mounted) controller.repeat(reverse: true);
      });
      
      return controller;
    });
  }

  void _initBackgroundElements() {
      final random = math.Random();
      _elements.clear();
      
      // Palette
      final colors = [
          const Color(0xFF00E5FF), // Cyan
          const Color(0xFFD500F9), // Purple
          const Color(0xFF00E676), // Green
          const Color(0xFFFFEA00), // Yellow
          const Color(0xFFFF1744), // Red
      ];

      for (int i = 0; i < 50; i++) {
         bool isNumber = random.nextBool();
         _elements.add(_BackgroundElement(
             x: random.nextDouble(),
             y: random.nextDouble(),
             speed: 0.05 + random.nextDouble() * 0.1,
             size: isNumber ? 12.0 + random.nextDouble() * 20 : 5.0 + random.nextDouble() * 15,
             opacity: 0.1 + random.nextDouble() * 0.4,
             color: colors[random.nextInt(colors.length)],
             type: isNumber ? _BackgroundElementType.number : _BackgroundElementType.dot,
             text: isNumber ? "${random.nextInt(10)}" : null
         ));
      }
  }

  void _updateBackground() {
      for (var e in _elements) {
          e.y -= e.speed * 0.002; 
          if (e.y < -0.1) {
              e.y = 1.1;
              e.x = math.Random().nextDouble();
          }
      }
  }

  @override
  void dispose() {
    _pathController.dispose();
    _bgController.dispose();
    _scrollController.dispose();
    for (var c in _islandControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadIslands() {
      // 1. Color Island (Bottom)
      final island1 = IslandModel(
          id: "1",
          name: "COLOR REALM",
          backgroundImagePath: "assets/images/islands/color_island_bg.png",
          iconAssetPath: "assets/images/islands/color_island_icon.png",
          primaryColor: const Color(0xFF00E5FF), // Cyan Neon
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("1"),
          levels: List.generate(50, (i) => LevelModel(
              id: i + 1, assetPath: '', starsEarned: GameDataManager().getStars("1", i+1),
              isLocked: !GameDataManager().unlockAllLevels && (i > 0 && GameDataManager().getStars("1", i) == 0),
          )),
      );

      // 2. Number Island
      final island2 = IslandModel(
          id: "2",
          name: "NUMBER NEXUS",
          backgroundImagePath: "assets/images/islands/number_island_bg.png",
          iconAssetPath: "assets/images/islands/number_island_icon.png",
          primaryColor: const Color(0xFFD500F9), // Purple Neon
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("2"),
           levels: List.generate(50, (i) => LevelModel(
              id: i + 1, assetPath: '', starsEarned: GameDataManager().getStars("2", i+1),
              isLocked: GameDataManager().unlockAllLevels ? false : (i == 0 ? false : (GameDataManager().getStars("2", i) == 0)),
          )),
          dotAssetPath: "assets/images/dots/number_dot.png",
      );

      // 3. Operation Island
      final island3 = IslandModel(
          id: "3",
          name: "LOGIC CORE", // Cooler name
          backgroundImagePath: "assets/images/islands/operation_island_bg.png",
          iconAssetPath: "assets/images/islands/operation_island_icon.png",
          primaryColor: const Color(0xFF00E676), // Green Neon
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("3"),
          levels: List.generate(35, (i) => LevelModel( // Corrected to 35
              id: i + 1, assetPath: '', starsEarned: GameDataManager().getStars("3", i+1),
              isLocked: GameDataManager().unlockAllLevels ? false : (i == 0 ? false : (GameDataManager().getStars("3", i) == 0)),
          )),
          dotAssetPath: "assets/images/dots/operation_dot.png",
      );
      
      // 4. Ocean Island
      final island4 = IslandModel(
          id: "4",
          name: "ABYSSAL ZONE",
          backgroundImagePath: "assets/images/islands/ocean_island_bg.png",
          iconAssetPath: "assets/images/islands/ocean_island_icon.png",
          primaryColor: const Color(0xFF2979FF), // Deep Blue Neon
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("4"),
          levels: List.generate(50, (i) => LevelModel(
              id: i + 1, assetPath: '', starsEarned: GameDataManager().getStars("4", i+1),
              isLocked: GameDataManager().unlockAllLevels ? false : (i == 0 ? false : (GameDataManager().getStars("4", i) == 0)),
          )),
          dotAssetPath: "assets/images/dots/water_dot.png",
      );

      setState(() {
          islands = [island1, island2, island3, island4];
      });
  }

  @override
  Widget build(BuildContext context) {
    if (islands.isEmpty) return const SizedBox();

    final double totalContentHeight = (islands.length * _nodeHeight) + 150;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Slightly Lighter Dark for Vibrancy
      body: Stack(
        children: [
          // 1. Dynamic Background
          Positioned.fill(
              child: AnimatedBuilder(
                  animation: _bgController,
                  builder: (context, child) => CustomPaint(
                      painter: _InteractiveBackgroundPainter(elements: _elements),
                  ),
              ),
          ),
          
          // 2. Main Content
          SafeArea(
              child: Column(
                  children: [
                      // Header
                      _buildHeader(),
                      
                      // Scrollable World
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          reverse: true, // Start from bottom
                          child: SizedBox(
                            height: totalContentHeight,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_pathController, ..._islandControllers]),
                              builder: (context, child) {
                                // Calculate offsets for floating effect
                                final List<double> floatOffsets = _islandControllers.map((c) {
                                  final double t = Curves.easeInOutSine.transform(c.value);
                                  return -10.0 + (t * 20.0);
                                }).toList();

                                return Stack(
                                  children: [
                                    // Path Line
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _GlowingPathPainter(
                                          islands: islands,
                                          nodeHeight: _nodeHeight,
                                          verticalOffsets: floatOffsets,
                                          flowPhase: _pathController.value,
                                        ),
                                      ),
                                    ),

                                    // Island Nodes
                                    ...List.generate(islands.length, (index) {
                                      return Positioned(
                                        bottom: 50 + (index * _nodeHeight), // Position from Bottom
                                        left: 0, right: 0,
                                        height: 240, // Card Height
                                        child: Transform.translate(
                                          offset: Offset(0, floatOffsets[index]),
                                          child: _buildIslandPortal(islands[index], index),
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
                  ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
      // Total Stars
      int totalStars = 0;
      for (var island in islands) {
          for (var level in island.levels) {
              totalStars += level.starsEarned;
          }
      }

      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to right
              children: [
                  // Total Star Counter
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                          boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.1), blurRadius: 10)]
                      ),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 28),
                              const SizedBox(width: 8),
                              Text(
                                  "$totalStars",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Orbitron',
                                      shadows: [Shadow(color: Color(0xFFFFD700), blurRadius: 10)]
                                  ),
                              )
                          ],
                      ),
                  )
              ],
          ),
      );
  }

  Widget _buildIslandPortal(IslandModel island, int index) {
      // Zig-Zag Layout
      double alignX = (index % 2 == 0) ? -0.2 : 0.2; 
      
      bool isLocked = island.isLocked;
      int levelsCompleted = island.levels.where((l) => l.starsEarned > 0).length;
      int totalLevels = island.levels.length;
      
      int starsEarnedInIsland = 0;
      for (var l in island.levels) starsEarnedInIsland += l.starsEarned;
      int totalStarsInIsland = totalLevels * 3;

      return Align(
          alignment: Alignment(alignX, 0),
          child: GestureDetector(
            onTap: () {
                 if (isLocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Complete previous islands to unlock ${island.name}"),
                              backgroundColor: Colors.redAccent.withOpacity(0.8),
                              behavior: SnackBarBehavior.floating,
                          )
                      );
                      return;
                 }
                 _navigateToIsland(island);
            },
            child: Container(
                width: 240, // Slightly wider for stats
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                         // Main Glow
                         BoxShadow(
                             color: island.primaryColor.withOpacity(isLocked ? 0.0 : 0.4),
                             blurRadius: 30,
                             offset: const Offset(0, 10),
                         )
                    ]
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFF1A1F2B).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: isLocked 
                                        ? Colors.white.withOpacity(0.1) 
                                        : island.primaryColor.withOpacity(0.5),
                                    width: 1.5
                                ),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.white.withOpacity(0.05),
                                    ]
                                )
                            ),
                            child: Stack(
                                children: [
                                    // 1. Icon / Image
                                    Positioned.fill(
                                        child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Opacity(
                                                opacity: isLocked ? 0.3 : 0.8,
                                                child: Image.asset(island.iconAssetPath, fit: BoxFit.contain)
                                            ),
                                        ),
                                    ),
                                    
                                    // 2. Info Overlay (Bottom)
                                    Positioned(
                                        bottom: 0, left: 0, right: 0,
                                        child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                        Colors.transparent,
                                                        Colors.black.withOpacity(0.95),
                                                    ]
                                                )
                                            ),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Text(
                                                        island.name,
                                                        style: TextStyle(
                                                            color: isLocked ? Colors.grey : Colors.white,
                                                            fontFamily: 'Orbitron', 
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                            letterSpacing: 1.0,
                                                            shadows: isLocked ? [] : [Shadow(color: island.primaryColor, blurRadius: 8)]
                                                        ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // Stats Row
                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                            // Level Progress
                                                            Row(
                                                                children: [
                                                                    Icon(Icons.layers, color: Colors.white70, size: 16),
                                                                    const SizedBox(width: 4),
                                                                    Text(
                                                                        "$levelsCompleted/$totalLevels",
                                                                        style: TextStyle(
                                                                            color: Colors.white.withOpacity(0.9),
                                                                            fontSize: 13,
                                                                            fontWeight: FontWeight.w600
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                            
                                                            // Star Progress
                                                            Row(
                                                                children: [
                                                                    const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                                                                    const SizedBox(width: 4),
                                                                    Text(
                                                                        "$starsEarnedInIsland/$totalStarsInIsland",
                                                                        style: TextStyle(
                                                                            color: const Color(0xFFFFD700),
                                                                            fontSize: 13,
                                                                            fontWeight: FontWeight.w600
                                                                        ),
                                                                    ),
                                                                ],
                                                            )
                                                        ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    // Progress Bar
                                                    ClipRRect(
                                                        borderRadius: BorderRadius.circular(4),
                                                        child: LinearProgressIndicator(
                                                            value: totalLevels > 0 ? levelsCompleted / totalLevels : 0,
                                                            backgroundColor: Colors.white10,
                                                            valueColor: AlwaysStoppedAnimation(
                                                                isLocked ? Colors.grey : island.primaryColor
                                                            ),
                                                            minHeight: 4,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ),

                                    // 3. Lock Icon
                                    if (isLocked)
                                        Center(
                                            child: Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: Colors.white24)
                                                ),
                                                child: const Icon(Icons.lock_rounded, color: Colors.white54, size: 32),
                                            ),
                                        ),
                                ],
                            ),
                        ),
                    ),
                ),
            ),
          ),
      );
  }

  Future<void> _navigateToIsland(IslandModel island) async {
      await Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (_,__,___) => LevelSelectionScreen(island: island),
              transitionsBuilder: (context, anim, secAnim, child) {
                   return FadeTransition(opacity: anim, child: child);
              }
          )
      );
      
      // Refresh data when returning from level selection logic
      if (mounted) {
           _loadIslands();
      }
  }
}


// --- PAINTERS & MODELS ---

enum _BackgroundElementType {
   dot,
   number
}

class _BackgroundElement {
    double x, y, speed, size, opacity;
    Color color;
    _BackgroundElementType type;
    String? text; // For number type

    _BackgroundElement({
        required this.x, 
        required this.y, 
        required this.speed, 
        required this.size, 
        required this.opacity,
        required this.color,
        required this.type,
        this.text
    });
}

class _InteractiveBackgroundPainter extends CustomPainter {
    final List<_BackgroundElement> elements;
    _InteractiveBackgroundPainter({required this.elements});

    @override
    void paint(Canvas canvas, Size size) {
        // Dark but neutral background
        final Rect rect = Offset.zero & size;
        final Paint bgPaint = Paint()
           ..shader = const LinearGradient(
               begin: Alignment.topCenter,
               end: Alignment.bottomCenter,
               colors: [
                   Color(0xFF121212), // Almost black
                   Color(0xFF1E1E2C), // Dark Grey-Blue
               ]
           ).createShader(rect);
        
        canvas.drawRect(rect, bgPaint);

        for (var e in elements) {
             if (e.type == _BackgroundElementType.dot) {
                 // Draw Colored Glow Dot
                 final paint = Paint()
                    ..color = e.color.withOpacity(e.opacity * 0.8) // Slightly more subtle
                    ..style = PaintingStyle.fill
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
                 
                 canvas.drawCircle(
                     Offset(e.x * size.width, e.y * size.height), 
                     e.size, 
                     paint
                 );
             } else {
                 // Draw Number with Glow
                 final textSpan = TextSpan(
                     text: e.text,
                     style: TextStyle(
                         color: e.color.withOpacity(e.opacity),
                         fontSize: e.size,
                         fontWeight: FontWeight.bold,
                         fontFamily: 'Orbitron',
                         shadows: [
                             Shadow(
                                 color: e.color.withOpacity(e.opacity * 0.8),
                                 blurRadius: 15,
                                 offset: const Offset(0, 0)
                             )
                         ]
                     )
                 );
                 final textPainter = TextPainter(
                     text: textSpan,
                     textDirection: TextDirection.ltr,
                 );
                 textPainter.layout();
                 textPainter.paint(
                     canvas, 
                     Offset(
                         (e.x * size.width) - (textPainter.width / 2), 
                         (e.y * size.height) - (textPainter.height / 2)
                     )
                 );
             }
        }
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GlowingPathPainter extends CustomPainter {
  final List<IslandModel> islands;
  final double nodeHeight;
  final List<double> verticalOffsets;
  final double flowPhase;

  _GlowingPathPainter({
    required this.islands,
    required this.nodeHeight,
    required this.verticalOffsets,
    required this.flowPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (islands.isEmpty) return;

    // Helper to get center offset for index (Matches Widget Logic)
    Offset getCenter(int index) {
      double alignX = (index % 2 == 0) ? -0.2 : 0.2; // -1.0 to 1.0 range relative to center
      
      // Map -1..1 to screen coordinates
      // 0 -> size.width/2
      // -0.2 -> size.width/2 - (0.2 * size.width/2)
      double wHalf = size.width / 2;
      double x = wHalf + (alignX * wHalf);

      // Y Position (From Bottom)
      // bottom: 50 + (index * _nodeHeight)
      // center Y is roughly: size.height - (50 + index*_nodeHeight + cardHeight/2)
      double cardH = 240;
      double bottomY = 50 + (index * nodeHeight);
      double y = size.height - (bottomY + cardH / 2);
      
      // Apply float offset
      y -= verticalOffsets.length > index ? verticalOffsets[index] : 0.0;
      
      return Offset(x, y);
    }

    // Paint Styles
    final activeGlowPaint = Paint()
       ..style = PaintingStyle.stroke
       ..strokeWidth = 8.0
       ..strokeCap = StrokeCap.round
       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final linePaint = Paint()
       ..style = PaintingStyle.stroke
       ..strokeWidth = 3.0
       ..strokeCap = StrokeCap.round;

    for (int i = 0; i < islands.length - 1; i++) {
        final p1 = getCenter(i);
        final p2 = getCenter(i + 1);
        final bool isUnlocked = !islands[i+1].isLocked; // Connection is lit if next island is reached

        final path = Path();
        path.moveTo(p1.dx, p1.dy);
        
        double cpY = (p1.dy + p2.dy) / 2;
        path.cubicTo(p1.dx, cpY, p2.dx, cpY, p2.dx, p2.dy);

        // Color
        Color color = isUnlocked ? islands[i+1].primaryColor : Colors.grey.withOpacity(0.3);

        if (isUnlocked) {
           // Glow
           activeGlowPaint.color = color.withOpacity(0.6);
           canvas.drawPath(path, activeGlowPaint);
           
           // Core Line with Flow
           linePaint.shader = ui.Gradient.linear(
               p1, p2,
               [color, Colors.white, color],
               [0.0, flowPhase, 1.0], // Animate gradient
               TileMode.mirror
           );
           canvas.drawPath(path, linePaint);
        } else {
           // Dashed line for locked
           linePaint.shader = null;
           linePaint.color = Colors.white.withOpacity(0.1);
           _drawDashedPath(canvas, path, 10, 10, linePaint);
        }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, double dashWidth, double dashSpace, Paint paint) {
    final ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
         canvas.drawPath(pathMetric.extractPath(distance, distance + dashWidth), paint);
         distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GlowingPathPainter old) => true;
}


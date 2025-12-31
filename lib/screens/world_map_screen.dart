import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/island_model.dart';
import '../models/level_model.dart'; // Ensure LevelModel is imported
import '../services/game_data_manager.dart';
import 'level_selection_screen.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _bgController;
  late AnimationController _pathController;
  final List<AnimationController> _islandControllers = [];

  List<IslandModel> islands = [];
  
  // Background Elements Logic
  final List<_BackgroundElement> _elements = [];
  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Background Animation
    _bgController = AnimationController(
       vsync: this, 
       duration: const Duration(seconds: 20) // Slower animation
    )..repeat();
    _bgController.addListener(_updateBackground);

    // Path Flow Animation
    _pathController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3)
    )..repeat();

    _initBackgroundElements();
    _loadIslands();
  }

  void _initBackgroundElements() {
      for (int i = 0; i < 20; i++) {
          _elements.add(_generateRandomElement());
      }
  }

  _BackgroundElement _generateRandomElement() {
      bool isNumber = _rnd.nextBool();
      return _BackgroundElement(
          x: _rnd.nextDouble(),
          y: _rnd.nextDouble(),
          speed: 0.05 + _rnd.nextDouble() * 0.1, // Slower speed
          size: isNumber ? 12.0 + _rnd.nextDouble() * 20.0 : 2.0 + _rnd.nextDouble() * 4.0,
          opacity: 0.1 + _rnd.nextDouble() * 0.3,
          color: [
             Colors.cyanAccent, 
             Colors.purpleAccent, 
             Colors.greenAccent, 
             Colors.amberAccent,
             Colors.redAccent
          ][_rnd.nextInt(5)],
          type: isNumber ? _BackgroundElementType.number : _BackgroundElementType.dot,
          text: isNumber ? _rnd.nextInt(10).toString() : null
      );
  }

  void _updateBackground() {
      for (var e in _elements) {
          e.y -= e.speed * 0.01;
          e.opacity += (0.5 - _rnd.nextDouble()) * 0.02;
          
          // Clamp opacity
          if (e.opacity < 0.1) e.opacity = 0.1;
          if (e.opacity > 0.6) e.opacity = 0.6;

          // Reset if out of bounds
          if (e.y < -0.1) {
              e.y = 1.1;
              e.x = _rnd.nextDouble();
          }
      }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bgController.dispose();
    _pathController.dispose();
    for (var c in _islandControllers) c.dispose();
    super.dispose();
  }

  void _loadIslands() {
      // Create controllers for floating effect
      for (var c in _islandControllers) c.dispose();
      _islandControllers.clear();

      // We will have 4 islands initially
      for (int i=0; i<4; i++) {
          _islandControllers.add(
              AnimationController(
                  vsync: this,
                  duration: Duration(seconds: 2 + i), // Varied duration
              )..repeat(reverse: true)
          );
      }

      // 1. Color Island
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
      
      /*
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
      */

      setState(() {
          islands = [island1, island2, island3]; // Removed island4
      });
  }

  @override
  Widget build(BuildContext context) {
    if (islands.isEmpty) return const SizedBox();

    final Size screenSize = MediaQuery.of(context).size;
    
    // Responsive Dimensions
    // Card Width: ~45% of width, capped at 220, min 160
    final double cardWidth = math.min(220.0, math.max(160.0, screenSize.width * 0.45));
    final double cardHeight = cardWidth * 1.2; // Aspect ratio
    
    // Vertical Spacing: 30% of height, capped at 400, min 280
    final double nodeHeight = math.min(400.0, math.max(280.0, screenSize.height * 0.3));

    final double totalContentHeight = (islands.length * nodeHeight) + 100;
    
    // Ensure content at least fills screen to allow centering/spacing effects if needed
    // Increase height to accommodate title above card (extra 50px buffer per card)
    final double actualHeight = math.max(totalContentHeight + (islands.length * 50), screenSize.height);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), 
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
                            height: actualHeight,
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
                                          nodeHeight: nodeHeight,
                                          cardWidth: cardWidth,
                                          cardHeight: cardHeight,
                                          verticalOffsets: floatOffsets,
                                          flowPhase: _pathController.value,
                                        ),
                                      ),
                                    ),

                                    // Island Nodes
                                    ...List.generate(islands.length, (index) {
                                      // Vertical center of the "slot"
                                      // Previously: bottom = 50 + index*nodeH
                                      // Let's adjust slightly to center in the nodeHeight slot
                                      final double bottomPos = 40 + (index * nodeHeight);

                                      return Positioned(
                                        bottom: bottomPos, 
                                        left: 0, right: 0,
                                        // Increase height for Column(Title + Card)
                                        height: cardHeight + 50, 
                                        child: Transform.translate(
                                          offset: Offset(0, floatOffsets[index]),
                                          child: _buildIslandPortal(islands[index], index, cardWidth, cardHeight),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alignment for Logo + Stars
              children: [
                  // Game Logo
                  Text(
                      "LUMINA PATH",
                      style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white,
                          shadows: [
                              Shadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 15),
                          ]
                      ),
                  ),

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

  Widget _buildIslandPortal(IslandModel island, int index, double cardWidth, double cardHeight) {
      // Zig-Zag Layout
      // We need more vertical space for the title on top
      double alignX = (index % 2 == 0) ? -0.2 : 0.2; 
      
      bool isLocked = island.isLocked;
      int levelsCompleted = island.levels.where((l) => l.starsEarned > 0).length;
      int totalLevels = island.levels.length;
      
      int starsEarnedInIsland = 0;
      for (var l in island.levels) starsEarnedInIsland += l.starsEarned;
      int totalStarsInIsland = totalLevels * 3;

      return Align(
          alignment: Alignment(alignX, 0),
          child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                 // 1. Island Name (Now Above)
                 Text(
                      island.name,
                      style: TextStyle(
                          color: isLocked ? Colors.grey : Colors.white,
                          fontFamily: 'Orbitron', 
                          fontWeight: FontWeight.bold,
                          fontSize: 16, 
                          letterSpacing: 1.2,
                          shadows: isLocked 
                              ? [] 
                              : [Shadow(color: island.primaryColor, blurRadius: 15)]
                      ),
                  ),
                  const SizedBox(height: 12), // Spacing between title and card

                  // 2. The Card
                  GestureDetector(
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
                        width: cardWidth, 
                        height: cardHeight, 
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
                                        color: const Color(0xFF1A1F2B).withOpacity(0.5), 
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: isLocked 
                                                ? Colors.white.withOpacity(0.1) 
                                                : island.primaryColor.withOpacity(0.5),
                                            width: 1.5
                                        ),
                                        image: DecorationImage(
                                            image: AssetImage(island.backgroundImagePath),
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                                Colors.black.withOpacity(0.6), 
                                                BlendMode.darken
                                            )
                                        ),
                                    ),
                                    child: Stack(
                                        children: [
                                            // Icon / Image
                                            Positioned.fill(
                                                bottom: 50, // Leave room for stats
                                                child: Padding(
                                                    padding: const EdgeInsets.all(20.0),
                                                    child: Opacity(
                                                        opacity: isLocked ? 0.3 : 0.8,
                                                        child: Image.asset(island.iconAssetPath, fit: BoxFit.contain)
                                                    ),
                                                ),
                                            ),
                                            
                                            // Stats Info (Bottom)
                                            Positioned(
                                                bottom: 0, left: 0, right: 0,
                                                child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black.withOpacity(0.6), 
                                                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))
                                                    ),
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                            // Level Stat
                                                            Column(
                                                                children: [
                                                                    Icon(Icons.layers, color: Colors.cyanAccent, size: 20),
                                                                    const SizedBox(height: 4),
                                                                    Text(
                                                                        "$levelsCompleted/$totalLevels",
                                                                        style: const TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize: 14,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontFamily: 'Orbitron'
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                            // Divider
                                                            Container(width: 1, height: 30, color: Colors.white24),
                                                            // Star Stat
                                                            Column(
                                                                children: [
                                                                    Icon(Icons.star, color: Colors.amberAccent, size: 20),
                                                                    const SizedBox(height: 4),
                                                                    Text(
                                                                        "$starsEarnedInIsland/$totalStarsInIsland",
                                                                        style: const TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize: 14,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontFamily: 'Orbitron'
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ],
                                                    ),
                                                )
                                            ),
                                        ],
                                    ),
                                )
                            )
                        )
                    )
                  ),
             ],
          )
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
  final double cardWidth;
  final double cardHeight;
  final List<double> verticalOffsets;
  final double flowPhase;

  _GlowingPathPainter({
    required this.islands,
    required this.nodeHeight,
    required this.cardWidth,
    required this.cardHeight,
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
      // bottom: 40 + (index * nodeHeight)
      // center Y is roughly: size.height - (40 + index*nodeHeight + cardHeight/2)
      double bottomY = 40 + (index * nodeHeight);
      double y = size.height - (bottomY + cardHeight / 2);
      
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

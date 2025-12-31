import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late ScrollController _scrollController;
  late AnimationController _pathController;
  final List<AnimationController> _islandControllers = [];

  List<IslandModel> islands = [];
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Path Flow Animation
    _pathController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3)
    )..repeat();

    _loadIslands();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pathController.dispose();
    for (var c in _islandControllers) c.dispose();
    super.dispose();
  }

  void _loadIslands() {
      for (var c in _islandControllers) c.dispose();
      _islandControllers.clear();

      for (int i=0; i<4; i++) {
          _islandControllers.add(
              AnimationController(
                  vsync: this,
                  duration: Duration(seconds: 2 + i), 
              )..repeat(reverse: true)
          );
      }

      final island1 = IslandModel(
          id: "1",
          name: "COLOR REALM",
          backgroundImagePath: "assets/images/islands/color_island_bg.png",
          iconAssetPath: "assets/images/islands/color_island_icon.png",
          primaryColor: const Color(0xFF00E5FF),
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("1"),
          levels: List.generate(50, (i) => LevelModel(
              id: i + 1, assetPath: '', starsEarned: GameDataManager().getStars("1", i+1),
              isLocked: !GameDataManager().unlockAllLevels && (i > 0 && GameDataManager().getStars("1", i) == 0),
          )),
      );

      final island2 = IslandModel(
          id: "2",
          name: "NUMBER NEXUS",
          backgroundImagePath: "assets/images/islands/number_island_bg.png",
          iconAssetPath: "assets/images/islands/number_island_icon.png",
          primaryColor: const Color(0xFFD500F9),
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("2"),
           levels: List.generate(50, (i) => LevelModel(
              id: i + 1, assetPath: '', starsEarned: GameDataManager().getStars("2", i+1),
              isLocked: GameDataManager().unlockAllLevels ? false : (i == 0 ? false : (GameDataManager().getStars("2", i) == 0)),
          )),
          dotAssetPath: "assets/images/dots/number_dot.png",
      );

      final island3 = IslandModel(
          id: "3",
          name: "LOGIC CORE",
          backgroundImagePath: "assets/images/islands/operation_island_bg.png",
          iconAssetPath: "assets/images/islands/operation_island_icon.png",
          primaryColor: const Color(0xFF00E676),
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("3"),
          levels: List.generate(35, (i) => LevelModel( 
              id: i + 1, assetPath: '', starsEarned: GameDataManager().getStars("3", i+1),
              isLocked: GameDataManager().unlockAllLevels ? false : (i == 0 ? false : (GameDataManager().getStars("3", i) == 0)),
          )),
          dotAssetPath: "assets/images/dots/operation_dot.png",
      );

      setState(() {
          islands = [island1, island2, island3]; 
      });
  }

  @override
  Widget build(BuildContext context) {
    if (islands.isEmpty) return const SizedBox();

    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = math.min(220.0, math.max(160.0, screenSize.width * 0.45));
    final double cardHeight = cardWidth * 1.2; 
    final double nodeHeight = math.min(400.0, math.max(280.0, screenSize.height * 0.3));
    
    // Calculate exact height needed for the highest island
    final double topMostIslandBottom = 40 + ((islands.length - 1) * nodeHeight);
    final double requiredHeight = topMostIslandBottom + cardHeight + 100; // 100 padding at top
    
    final double actualHeight = math.max(requiredHeight, screenSize.height * 0.5);

    return Scaffold(
      backgroundColor: Colors.black, 
      body: Stack(
        children: [
          // 1. Static Image Background
          Positioned.fill(
              child: Image.asset(
                  "assets/images/bg.png",
                  fit: BoxFit.cover,
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
                                      final double bottomPos = 40 + (index * nodeHeight);
                                      return Positioned(
                                        bottom: bottomPos, 
                                        left: 0, right: 0,
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
      int totalStars = 0;
      for (var island in islands) {
          for (var level in island.levels) totalStars += level.starsEarned;
      }

      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                  // Simplified, Premium Look: White Text + Neon Glow
                  Text(
                    "LUMINA PATH",
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.white,
                      shadows: [
                           // Core Glow
                           Shadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 15),
                           // Outer Atmosphere
                           Shadow(color: Colors.blue.withOpacity(0.5), blurRadius: 30),
                      ]
                    ),
                  ),

                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6), 
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                          boxShadow: [
                             BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 10)
                          ]
                      ),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 28),
                              const SizedBox(width: 8),
                              Text(
                                  "$totalStars",
                                  style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
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
                width: cardWidth, 
                height: cardHeight, 
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                         BoxShadow(
                             color: island.primaryColor.withOpacity(isLocked ? 0.0 : 0.3),
                             blurRadius: 20,
                             offset: const Offset(0, 8),
                         )
                    ]
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.transparent, 
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: isLocked 
                                        ? Colors.white.withOpacity(0.1) 
                                        : island.primaryColor.withOpacity(0.5),
                                    width: 1.0
                                ),
                                image: DecorationImage(
                                    image: AssetImage(island.backgroundImagePath),
                                    fit: BoxFit.cover,
                                ),
                            ),
                            child: Stack(
                                children: [
                                    // Icon / Image (Faded behind text)
                                    Positioned.fill(
                                        bottom: 50,
                                        child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Opacity(
                                                opacity: isLocked ? 0.3 : 0.8,
                                                child: Image.asset(island.iconAssetPath, fit: BoxFit.contain)
                                            ),
                                        ),
                                    ),
                                    
                                    // Title (Centered & Prominent)
                                    Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                              island.name.toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.orbitron(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 20, 
                                                  letterSpacing: 1.5,
                                                  height: 1.2,
                                                  shadows: [
                                                      // Thick Outline effect for readability
                                                      Shadow(offset: Offset(-1.5, -1.5), color: Colors.black),
                                                      Shadow(offset: Offset(1.5, -1.5), color: Colors.black),
                                                      Shadow(offset: Offset(1.5, 1.5), color: Colors.black),
                                                      Shadow(offset: Offset(-1.5, 1.5), color: Colors.black),
                                                      // Glow
                                                      Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 10),
                                                  ]
                                              ),
                                          ),
                                        ),
                                    ),

                                    // Stats Info (Bottom)
                                    Positioned(
                                        bottom: 0, left: 0, right: 0,
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5), 
                                                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))
                                            ),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                    Column(
                                                        children: [
                                                            Icon(Icons.layers, color: Colors.cyanAccent, size: 20),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                                "$levelsCompleted/$totalLevels",
                                                                style: GoogleFonts.orbitron(
                                                                    color: Colors.white,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                    Container(width: 1, height: 30, color: Colors.white24),
                                                    Column(
                                                        children: [
                                                            Icon(Icons.star, color: Colors.amberAccent, size: 20),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                                "$starsEarnedInIsland/$totalStarsInIsland",
                                                                style: GoogleFonts.orbitron(
                                                                    color: Colors.white,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
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
      if (mounted) _loadIslands();
  }
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

    Offset getCenter(int index) {
      double alignX = (index % 2 == 0) ? -0.2 : 0.2; 
      double wHalf = size.width / 2;
      double x = wHalf + (alignX * wHalf);
      double bottomY = 40 + (index * nodeHeight);
      double y = size.height - (bottomY + cardHeight / 2);
      y -= verticalOffsets.length > index ? verticalOffsets[index] : 0.0;
      return Offset(x, y);
    }

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
        final bool isUnlocked = !islands[i+1].isLocked; 

        final path = Path();
        path.moveTo(p1.dx, p1.dy);
        
        double cpY = (p1.dy + p2.dy) / 2;
        path.cubicTo(p1.dx, cpY, p2.dx, cpY, p2.dx, p2.dy);

        Color color = isUnlocked ? islands[i+1].primaryColor : Colors.grey.withOpacity(0.3);

        if (isUnlocked) {
           activeGlowPaint.color = color.withOpacity(0.6);
           canvas.drawPath(path, activeGlowPaint);
           
           linePaint.shader = ui.Gradient.linear(
               p1, p2,
               [color, Colors.white, color],
               [0.0, flowPhase, 1.0], 
               TileMode.mirror
           );
           canvas.drawPath(path, linePaint);
        } else {
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

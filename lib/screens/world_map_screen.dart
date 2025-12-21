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
  final double _nodeHeight = 280.0;
  
  // Animation Controllers
  late List<AnimationController> _islandControllers;
  late AnimationController _dashController;
  
  @override
  void initState() {
    super.initState();
    _loadIslands();
    _initAnimations();
  }

  void _initAnimations() {
    // 1. Dash Animation (Marching Ants)
    _dashController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Speed of the dash movement
    )..repeat();

    // 2. Island Floating Animations (Independent & Random)
    _islandControllers = List.generate(4, (index) {
      // Randomize duration slightly for independence and organic look
      final random = math.Random();
      final durationMs = 2000 + random.nextInt(1500); // 2.0s to 3.5s
      
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationMs),
      );

      // Random start phase
      Future.delayed(Duration(milliseconds: random.nextInt(1000)), () {
        if (mounted) controller.repeat(reverse: true);
      });
      
      return controller;
    });
  }

  @override
  void dispose() {
    _dashController.dispose();
    for (var c in _islandControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadIslands() {
      // 1. Color Island (Bottom - Index 0)
      final island1 = IslandModel(
          id: "1",
          name: "Color Island",
          backgroundImagePath: "assets/images/islands/color_island_bg.png",
          iconAssetPath: "assets/images/islands/color_island_icon.png",
          primaryColor: Colors.deepPurpleAccent,
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("1"),
          levels: List.generate(50, (i) => LevelModel(
              id: i + 1,
              assetPath: 'assets/images/levels/color_${i+1}.png',
              starsEarned: GameDataManager().getStars("1", i+1),
              isLocked: !GameDataManager().unlockAllLevels && (i > 0 && GameDataManager().getStars("1", i) == 0),
          )),
          dotAssetPath: null,
      );

      // 2. Number Island (Index 1)
      final island2 = IslandModel(
          id: "2",
          name: "Number Island",
          backgroundImagePath: "assets/images/islands/number_island_bg.png",
          iconAssetPath: "assets/images/islands/number_island_icon.png",
          primaryColor: Colors.blue,
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("2"),
           levels: List.generate(50, (i) => LevelModel(
              id: i + 1,
              assetPath: 'assets/images/levels/number_${i+1}.png',
              starsEarned: GameDataManager().getStars("2", i+1),
              isLocked: GameDataManager().unlockAllLevels ? false : (i == 0 ? false : (GameDataManager().getStars("2", i) == 0)),
          )),
          dotAssetPath: "assets/images/dots/number_dot.png",
      );

      // 3. Jungle Island (Index 2)
      final island3 = IslandModel(
          id: "3",
          name: "Jungle Island",
          backgroundImagePath: "assets/images/islands/jungle_island_bg.png",
          iconAssetPath: "assets/images/islands/jungle_island_icon.png",
          primaryColor: Colors.green,
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("3"),
          levels: List.generate(50, (i) => LevelModel(
              id: i + 1,
              assetPath: 'assets/images/levels/jungle_${i+1}.png',
              starsEarned: GameDataManager().getStars("3", i+1),
              isLocked: GameDataManager().unlockAllLevels ? false : (i == 0 ? false : (GameDataManager().getStars("3", i) == 0)),
          )),
          dotAssetPath: "assets/images/dots/animal_dot.png",
      );
      
      // 4. Ocean Island (Index 3)
      final island4 = IslandModel(
          id: "4",
          name: "Ocean Island",
          backgroundImagePath: "assets/images/islands/ocean_island_bg.png",
          iconAssetPath: "assets/images/islands/ocean_island_icon.png",
          primaryColor: Colors.cyan,
          isLocked: !GameDataManager().unlockAllLevels && !GameDataManager().isIslandUnlocked("4"),
          levels: List.generate(50, (i) => LevelModel(
              id: i + 1,
              assetPath: 'assets/images/levels/ocean_${i+1}.png',
              starsEarned: GameDataManager().getStars("4", i+1),
              isLocked: GameDataManager().unlockAllLevels ? false : (i == 0 ? false : (GameDataManager().getStars("4", i) == 0)),
          )),
          dotAssetPath: "assets/images/dots/water_dot.png",
      );

      setState(() {
          // Internal order: 0=Color ... 3=Ocean
          islands = [island1, island2, island3, island4];
      });
  }

  @override
  Widget build(BuildContext context) {
    if (islands.isEmpty) return const SizedBox(); // Safety check

    final double totalContentHeight = islands.length * _nodeHeight + 100;

    // Create a Listenable that merges all controllers so AnimatedBuilder rebuilds on any change
    final List<Listenable> allAnimations = [_dashController, ..._islandControllers];

    return Scaffold(
      body: Stack(
        children: [
          const _ScrollingBackground(),

          SafeArea(
              child: Column(
                  children: [
                      // Top Bar
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                  ),
                                  const Text(
                                      "WORLD MAP",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontFamily: 'Comic Sans MS',
                                          fontWeight: FontWeight.bold,
                                          shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2,2))]
                                      ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: const Row(
                                          children: [
                                              Icon(Icons.star, color: Colors.amber, size: 20),
                                              SizedBox(width: 4),
                                              Text("0", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                          ],
                                      ),
                                  )
                              ],
                          ),
                      ),
                      
                      Expanded(
                        child: SingleChildScrollView(
                          reverse: true, // Scrolls to bottom initially (Color Island)
                          child: SizedBox(
                            height: totalContentHeight,
                            child: AnimatedBuilder(
                              animation: Listenable.merge(allAnimations),
                              builder: (context, child) {
                                // Calculate current offsets for painting lines
                                final List<double> currentOffsets = _islandControllers.map((c) {
                                  // Map 0.0-1.0 to -15.0 to 15.0
                                  final double t = Curves.easeInOut.transform(c.value);
                                  return -15.0 + (t * 30.0); // Range -15 to +15
                                }).toList();

                                return Stack(
                                  children: [
                                    // 1. Path Painter
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: IslandPathPainter(
                                          islands: islands,
                                          nodeHeight: _nodeHeight,
                                          verticalOffsets: currentOffsets,
                                          dashPhase: _dashController.value,
                                        ),
                                      ),
                                    ),

                                    // 2. Island Nodes
                                    ...List.generate(islands.length, (index) {
                                      return Positioned(
                                        top: totalContentHeight - ((index + 1) * _nodeHeight),
                                        left: 0,
                                        right: 0,
                                        height: _nodeHeight,
                                        child: Transform.translate(
                                          offset: Offset(0, currentOffsets[index]),
                                          child: _buildIslandNode(islands[index], index),
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

  Widget _buildIslandNode(IslandModel island, int index) {
      double alignX = 0;
      if (index % 4 == 1) alignX = 0.6; // Right
      if (index % 4 == 3) alignX = -0.6; // Left
      
      double size = 120.0;
      if (index == 0) size = 140.0; // Start island bigger

      return Align(
          alignment: Alignment(alignX, 0),
          child: GestureDetector(
            // Capture location of tap for zoom origin
            onTapUp: (TapUpDetails details) async {
                if (island.isLocked) return;

                // 1. Get Screen Size
                final Size screenSize = MediaQuery.of(context).size;
                
                // 2. Calculate Alignment relative to center of screen
                // Alignment(0,0) is center. (-1,-1) is top left.
                // Formula: (pos / size) * 2 - 1
                final double relativeX = (details.globalPosition.dx / screenSize.width) * 2 - 1;
                final double relativeY = (details.globalPosition.dy / screenSize.height) * 2 - 1;
                
                final Alignment tapAlignment = Alignment(relativeX, relativeY);

                // 3. Navigate with Custom Transition
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 1000), // Slightly slower for dramatic effect
                    reverseTransitionDuration: const Duration(milliseconds: 800),
                    pageBuilder: (context, animation, secondaryAnimation) => LevelSelectionScreen(island: island),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      // Quartic curve for "accelerating into" the world
                      var curve = CurvedAnimation(parent: animation, curve: Curves.easeInOutQuart);
                      
                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
                        alignment: tapAlignment, // KEY: Scale FROM the tap location
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
                _loadIslands();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
                          ]
                      ),
                      child: Stack(
                          children: [
                              ClipOval(
                                  child: Image.asset(
                                      island.iconAssetPath,
                                      fit: BoxFit.cover,
                                      width: size,
                                      height: size,
                                      errorBuilder: (_,__,___) => Container(
                                          color: island.primaryColor,
                                          child: Icon(Icons.terrain, color: Colors.white, size: size/2),
                                      ),
                                  ),
                              ),
                              if (island.isLocked)
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                          child: Icon(Icons.lock, color: Colors.white70, size: size * 0.4),
                                      ),
                                  ),
                          ],
                      ),
                  ),
              ],
            ),
          ),
      );
  }
}

class IslandPathPainter extends CustomPainter {
  final List<IslandModel> islands;
  final double nodeHeight;
  final List<double> verticalOffsets;
  final double dashPhase;

  IslandPathPainter({
    required this.islands,
    required this.nodeHeight,
    required this.verticalOffsets,
    required this.dashPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (islands.isEmpty) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7) // Increased opacity for visibility
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 // Thicker line
      ..strokeCap = StrokeCap.round;

    // Helper to get center offset for index
    Offset getCenter(int index) {
      // Logic must match _buildIslandNode alignment
      double alignX = 0;
      if (index % 4 == 1) alignX = 0.6; // Right
      if (index % 4 == 3) alignX = -0.6; // Left

      // alignX is -1.0 to 1.0 mapping to 0 to size.width
      // Center (0) -> size.width / 2
      double x = size.width / 2 + (alignX * size.width / 2);

      // Y Position
      // In stack: top = totalContentHeight - ((index + 1) * _nodeHeight)
      // Center of that node block is top + nodeHeight / 2
      double totalH = size.height;
      double top = totalH - ((index + 1) * nodeHeight);
      double y = top + nodeHeight / 2;
      
      // Apply the dynamic animation offset!
      y += verticalOffsets.length > index ? verticalOffsets[index] : 0.0;
      
      return Offset(x, y);
    }

    // Draw paths between i and i+1
    for (int i = 0; i < islands.length - 1; i++) {
      final p1 = getCenter(i);
      final p2 = getCenter(i + 1);

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      // Simple S-curve implementation
      double cpY = (p1.dy + p2.dy) / 2;
      path.cubicTo(p1.dx, cpY, p2.dx, cpY, p2.dx, p2.dy);
      
      // Draw animated dashed line
      // dashPhase is 0.0 to 1.0. We multiply by dash+space (20+15=35) to shift it 1 full cycle
      _drawDashedPath(canvas, path, 20, 15, paint, dashPhase * 35.0);
    }
  }
  
  void _drawDashedPath(Canvas canvas, Path path, double dashWidth, double dashSpace, Paint paint, double phaseOffset) {
    final ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      // Subtract phaseOffset to move 'forward' (or add to move backward)
      // We start at -phaseOffset to ensure the first dash slides in from "outside"
      distance -= phaseOffset; 
      
      while (distance < pathMetric.length) {
        double start = distance;
        double end = distance + dashWidth;
        
        // Handle visible segments only
        if (end > 0 && start < pathMetric.length) {
            // Clamp
            double drawStart = start < 0 ? 0 : start;
            double drawEnd = end > pathMetric.length ? pathMetric.length : end;
            
            // Only draw if valid range
            if (drawEnd > drawStart) {
               canvas.drawPath(pathMetric.extractPath(drawStart, drawEnd), paint);
            }
        }
        
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant IslandPathPainter oldDelegate) {
     return true; // Always repaint as we are animating
  }
}

class _ScrollingBackground extends StatefulWidget {
  const _ScrollingBackground();

  @override
  State<_ScrollingBackground> createState() => _ScrollingBackgroundState();
}

class _ScrollingBackgroundState extends State<_ScrollingBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Very slow continuous scroll (Ping Pong for simplicity and smoothness without seams)
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage("assets/images/general_islands_bg.jpg"),
              fit: BoxFit.cover,
              // Pan from -0.1 to 0.1? Or slightly more.
              // Alignment(0,0) is center. Alignment(1,0) is right edge.
              // We want a slow drift.
              alignment: Alignment(_controller.value * 0.3 - 0.15, 0), 
            ),
          ),
        );
      },
    );
  }
}

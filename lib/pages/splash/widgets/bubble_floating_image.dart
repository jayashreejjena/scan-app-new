import 'dart:math';
import 'package:flutter/material.dart';
 
class BubbleFloatingImages extends StatefulWidget {
  final List<String> imagePaths;
 
  const BubbleFloatingImages({super.key, required this.imagePaths});
 
  @override
  State<BubbleFloatingImages> createState() => _BubbleFloatingImagesState();
}
 
class _BubbleFloatingImagesState extends State<BubbleFloatingImages>
    with TickerProviderStateMixin {
  final Random random = Random();
  List<_BubbleImage> bubbles = [];
 
  double screenWidth = 100; // will be updated in build
 
  @override
  void initState() {
    super.initState();
    _generateBubbles();
  }
 
  void _generateBubbles() {
    for (int i = 0; i < widget.imagePaths.length; i++) {
      var bubble = _BubbleImage(
        imagePath: widget.imagePaths[i],
        controller: AnimationController(
          duration: Duration(seconds: 6 + random.nextInt(25)),
          vsync: this,
        ),
        random: random,
      );
 
      bubbles.add(bubble);
      bubble.controller.repeat();
    }
  }
 
  /// Ensures bubbles do NOT overlap (now using screenWidth passed externally)
  void assignNonOverlappingPosition(_BubbleImage bubble) {
    const int maxAttempts = 20;
 
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      bubble.resetRandom();
 
      bool hasOverlap = false;
 
      for (var other in bubbles) {
        if (other == bubble) continue;
 
        double dx = (bubble.startX - other.startX).abs();
 
        double requiredSpacing = (bubble.size + other.size) / screenWidth;
 
        if (dx < requiredSpacing * 1.2) {
          hasOverlap = true;
          break;
        }
      }
 
      if (!hasOverlap) return;
    }
  }
 
  @override
  void dispose() {
    for (var b in bubbles) {
      b.controller.dispose();
    }
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width; // safe here
 
    // Ensure initial non-overlapping positions (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var bubble in bubbles) {
        assignNonOverlappingPosition(bubble);
      }
    });
 
    return Stack(
      children: [
        ...bubbles.map(
          (bubble) => AnimatedBuilder(
            animation: bubble.controller,
            builder: (_, __) {
              final progress = bubble.controller.value;
 
              final dy = 1 - progress;
              final dx =
                  bubble.startX + sin(progress * 2 * pi) * 0.03; // sway motion
 
              if (progress > 0.98) {
                assignNonOverlappingPosition(bubble);
              }
 
              return Positioned(
                left: dx * screenWidth,
                top: dy * MediaQuery.of(context).size.height,
                child: Opacity(
                  opacity: (1 - progress).clamp(0, 1),
                  child: CircleAvatar(
                    radius: bubble.size,
                    backgroundImage: AssetImage(bubble.imagePath),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
 
class _BubbleImage {
  final String imagePath;
  final AnimationController controller;
  final Random random;
 
  double startX = 0.5;
  double size = 20;
 
  _BubbleImage({
    required this.imagePath,
    required this.controller,
    required this.random,
  });
 
  void resetRandom() {
    startX = random.nextDouble();
    size = 25 + random.nextDouble() * 25;
  }
}
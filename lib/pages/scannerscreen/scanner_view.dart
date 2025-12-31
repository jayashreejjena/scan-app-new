import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odisha_air_map/navigators/routes_management.dart';
import 'package:odisha_air_map/pages/scannerscreen/scanner_controller.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final ScannerController c = Get.put(ScannerController());

  late AnimationController _animationController;

  // Zoom variables
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    ever(c.cameraController, (_) {
      final controller = c.cameraController.value;
      if (controller != null && controller.value.isInitialized) {
        _setupZoom(controller);
      }
    });
  }

  Future<void> _setupZoom(CameraController controller) async {
    _maxAvailableZoom = await controller.getMaxZoomLevel();
    _minAvailableZoom = await controller.getMinZoomLevel();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanWindowSize = size.width * 0.75;

    return WillPopScope(
      onWillPop: () async {
        RouteManagement.goToHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // -----------------------------------------------------------
            // LAYER 1: CAMERA FEED OR SAVED IMAGE
            // -----------------------------------------------------------
            Obx(() {
              // --- STATE: ANALYZING (SHOW CAPTURED CROP) ---
              // Only show this if we actually HAVE an image path
              if (c.savedImagePath.value != null && c.isLoading.value) {
                return Container(
                  color: Colors.black, // Background stays black
                  child: Center(
                    child: Container(
                      width: scanWindowSize,
                      height: scanWindowSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: FileImage(File(c.savedImagePath.value!)),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }

              // --- STATE: LIVE CAMERA FEED ---
              final controller = c.cameraController.value;
              if (controller == null || !controller.value.isInitialized) {
                return Container(color: Colors.black);
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onScaleStart: (details) => _baseZoom = _currentZoom,
                onScaleUpdate: (details) async {
                  if (c.isLoading.value) return;
                  double newZoom = (_baseZoom * details.scale).clamp(
                    _minAvailableZoom,
                    _maxAvailableZoom,
                  );
                  setState(() => _currentZoom = newZoom);
                  await controller.setZoomLevel(newZoom);
                },
                child: CameraPreview(controller),
              );
            }),

            // -----------------------------------------------------------
            // LAYER 2: DARK OVERLAY
            // -----------------------------------------------------------
            Obx(() {
              // FIX: Only hide the overlay if we have an image AND are loading.
              // If we are loading but image is null (First scan), KEEP OVERLAY.
              if (c.isLoading.value && c.savedImagePath.value != null) {
                return const SizedBox.shrink();
              }
              return CustomPaint(
                painter: ModernScannerOverlayPainter(
                  scanWindowSize: scanWindowSize,
                ),
                child: Container(),
              );
            }),

            // -----------------------------------------------------------
            // LAYER 3: LASER ANIMATION
            // -----------------------------------------------------------
            Obx(() {
              // FIX: Keep laser running during first scan processing
              if (c.isLoading.value && c.savedImagePath.value != null) {
                return const SizedBox.shrink();
              }
              return Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(scanWindowSize, scanWindowSize),
                      painter: LaserScannerPainter(
                        animationValue: _animationController.value,
                        color: Colors.cyanAccent,
                      ),
                    );
                  },
                ),
              );
            }),

            // -----------------------------------------------------------
            // LAYER 4: UI CONTROLS
            // -----------------------------------------------------------
            SafeArea(
              child: Column(
                children: [
                  // --- HEADER ---
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          color: Colors.black.withOpacity(0.3),
                          child: Obx(
                            () => Text(
                              c.isLoading.value
                                  ? "Processing Image..."
                                  : "Point at an object to scan",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // --- ZOOM SLIDER ---
                  Obx(() {
                    if (c.isLoading.value) return const SizedBox(height: 40);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.zoom_out,
                            color: Colors.white70,
                            size: 20,
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.cyanAccent,
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8.0,
                                ),
                              ),
                              child: Slider(
                                value: _currentZoom,
                                min: _minAvailableZoom,
                                max: _maxAvailableZoom,
                                onChanged: (value) async {
                                  setState(() => _currentZoom = value);
                                  await c.cameraController.value?.setZoomLevel(
                                    value,
                                  );
                                },
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.zoom_in,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // --- BOTTOM BUTTON / LOADER ---
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Obx(() {
                      if (c.isLoading.value) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(
                                color: Colors.cyanAccent,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Analyzing...",
                              style: TextStyle(
                                color: Colors.cyanAccent.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }

                      return GestureDetector(
                        onTap: () => c.scanImage(),
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 32,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }),
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

// ---------------------------------------------------------------------------
// PAINTERS (Same as before)
// ---------------------------------------------------------------------------

class ModernScannerOverlayPainter extends CustomPainter {
  final double scanWindowSize;
  ModernScannerOverlayPainter({required this.scanWindowSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = scanWindowSize / 2;

    // Dark Background (90% Opacity)
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutoutPath),
      Paint()..color = Colors.black.withOpacity(0.9),
    );

    // White Ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Corner Brackets
    final cornerPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final double bracketLength = 30;
    final double offset = radius + 15;

    // Draw corners (simplified for brevity)
    final corners = [
      [
        Offset(center.dx - offset, center.dy - offset + bracketLength),
        Offset(center.dx - offset, center.dy - offset),
        Offset(center.dx - offset + bracketLength, center.dy - offset),
      ],
      [
        Offset(center.dx + offset - bracketLength, center.dy - offset),
        Offset(center.dx + offset, center.dy - offset),
        Offset(center.dx + offset, center.dy - offset + bracketLength),
      ],
      [
        Offset(center.dx + offset, center.dy + offset - bracketLength),
        Offset(center.dx + offset, center.dy + offset),
        Offset(center.dx + offset - bracketLength, center.dy + offset),
      ],
      [
        Offset(center.dx - offset + bracketLength, center.dy + offset),
        Offset(center.dx - offset, center.dy + offset),
        Offset(center.dx - offset, center.dy + offset - bracketLength),
      ],
    ];

    for (var points in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(points[0].dx, points[0].dy)
          ..lineTo(points[1].dx, points[1].dy)
          ..lineTo(points[2].dx, points[2].dy),
        cornerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LaserScannerPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  LaserScannerPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double yPos = size.height * animationValue;
    canvas.drawRect(
      Rect.fromLTWH(10, yPos, size.width - 20, 3),
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withOpacity(0),
            color.withOpacity(0.8),
            color.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(0, yPos, size.width, 4)),
    );
  }

  @override
  bool shouldRepaint(covariant LaserScannerPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

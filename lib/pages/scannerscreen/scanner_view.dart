import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:odisha_air_map/navigators/routes_management.dart';
import 'package:odisha_air_map/pages/scaninfoscreen/scaninfoscreen_view.dart';
import 'package:odisha_air_map/pages/scannerscreen/scanner_controller.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  final ScannerController c = Get.put(ScannerController());

  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  bool _isFlashOn = false;

  bool _isAmbiguous = false;
  String _instructionText = "Align image within frame";
  Timer? _errorResetTimer;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

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

  Future<void> _toggleFlash() async {
    final controller = c.cameraController.value;
    if (controller == null) return;
    try {
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() => _isFlashOn = !_isFlashOn);
      HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  Future<void> _handleScan() async {
    if (_currentZoom < 1.2) {
      _triggerError("Move closer or Zoom in");
      return;
    }
    if (c.isLoading.value) return;

    HapticFeedback.heavyImpact();
    await c.scanImage();
  }

  void _triggerError(String message) {
    setState(() {
      _isAmbiguous = true;
      _instructionText = message;
    });
    HapticFeedback.mediumImpact();
    _errorResetTimer?.cancel();
    _errorResetTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAmbiguous = false;
          _instructionText = "Align image within frame";
        });
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _errorResetTimer?.cancel();
    c.cameraController.value?.setFlashMode(FlashMode.off);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanWindowSize = size.width * 0.75;

    // The Square Box
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 120),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    final Color activeColor = _isAmbiguous
        ? const Color(0xFFFF5252) // Red when error
        : const Color(0xFF64FFDA); // Teal when normal

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview
          _buildCameraPreview(),

          // 2. Soft Vignette Overlay
          _buildSoftOverlay(cutoutRect),

          // 3. CAPTURED IMAGE OVERLAY
          Obx(() {
            if (c.savedImagePath.value != null && c.isLoading.value) {
              return Positioned.fromRect(
                rect: cutoutRect,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    File(c.savedImagePath.value!),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // 4. Viewfinder Borders
          _buildAnimatedViewfinder(cutoutRect, activeColor),

          // 5. Top Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassButton(
                  icon: Icons.close_rounded,
                  isActive: false,
                  onTap: () => RouteManagement.goToHome(),
                ),
                // Top status bar commented out as per previous code
                // _buildTopStatus(activeColor),
                _glassButton(
                  icon: Icons.info_outline_rounded,
                  isActive: false,
                  onTap: () => Get.to(() => const ScannerInfoScreen()),
                ),
              ],
            ),
          ),

          // 6. Instructions & Error Messages - FIXED HERE
          Positioned(
            top: cutoutRect.bottom + 50,
            left: 0,
            right: 0,
            child: Obx(() {
              if (c.isLoading.value) {
                return const SizedBox.shrink();
              }

              // === SHOW ERROR MESSAGE IF AMBIGUOUS ===
              if (_isAmbiguous) {
                return Center(
                  child: Text(
                    _instructionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFF5252), // Red Color
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                );
              }
             
              // === SHOW NORMAL INSTRUCTIONS ===
              return Column(
                children: [
                  const Text(
                    "Align image within frame",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Then ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                      const Icon(
                        Icons.touch_app,
                        color: Colors.yellowAccent,
                        size: 16,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            " the ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                            shadows: const [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                          const Text(
                            " button",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),

          // 7. Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomDeck(activeColor),
          ),

          // 8. Loading Overlay
          Obx(() {
            if (c.isLoading.value) {
              return Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.85),
                  child: Stack(
                    children: [
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 20,
                        child: _glassButton(
                          icon: Icons.close_rounded,
                          isActive: false,
                          onTap: () {
                            c.cancelScan();
                          },
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF64FFDA),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Analyzing...",
                              style: TextStyle(
                                color: const Color(0xFF64FFDA),
                                fontSize: 18,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF64FFDA,
                                    ).withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
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
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCameraPreview() {
    return Obx(() {
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
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.previewSize!.height,
              height: controller.value.previewSize!.width,
              child: CameraPreview(controller),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSoftOverlay(Rect cutoutRect) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Positioned.fromRect(
            rect: cutoutRect,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedViewfinder(Rect rect, Color color) {
    return Positioned.fromRect(
      rect: rect,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isAmbiguous ? 1.0 : _scaleAnimation.value,
            child: CustomPaint(
              painter: TechCornersPainter(color: color),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: color.withOpacity(0.1), width: 1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _isAmbiguous
                    ? Center(
                        child: Icon(
                          Icons.priority_high_rounded,
                          color: color.withOpacity(0.8),
                          size: 60,
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopStatus(Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isAmbiguous ? Icons.warning_amber_rounded : Icons.auto_awesome,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _instructionText.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomDeck(Color activeColor) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(1.0), Colors.transparent],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _glassButton(
                icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                isActive: _isFlashOn,
                onTap: _toggleFlash,
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 44,
                    width: 285,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "1x",
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: activeColor,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: SliderComponentShape.noOverlay,
                              trackHeight: 10,
                            ),
                            child: Slider(
                              value: _currentZoom,
                              min: _minAvailableZoom,
                              max: _maxAvailableZoom > 8.0
                                  ? 8.0
                                  : _maxAvailableZoom,
                              onChanged: (v) async {
                                setState(() => _currentZoom = v);
                                await c.cameraController.value?.setZoomLevel(v);
                              },
                            ),
                          ),
                        ),
                        const Text(
                          "8x",
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Use this to zoom in and zoom out",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _handleScan,
            child: Container(
              height: 84,
              width: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade300],
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.black.withOpacity(0.8),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.white : Colors.white10,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.amber : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class TechCornersPainter extends CustomPainter {
  final Color color;
  TechCornersPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    double len = 30;
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - len)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - len, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(len, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(TechCornersPainter oldDelegate) =>
      oldDelegate.color != color;
}

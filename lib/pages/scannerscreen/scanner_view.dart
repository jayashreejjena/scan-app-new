import 'dart:async';
import 'dart:io';
import 'dart:ui'; // For ImageFilter

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
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
  final double _scanWindowScale = 0.70;

  // Zoom & Camera State
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  bool _isFlashOn = false;

  // New State for "Multiple Codes" logic
  bool _isAmbiguous = false;
  String _instructionText = "ALIGN CODE TO SCAN";

  // Debouncer for auto-resetting error states
  Timer? _errorResetTimer;

  @override
  void initState() {
    super.initState();
    // Fast laser animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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

  Future<void> _toggleFlash() async {
    final controller = c.cameraController.value;
    if (controller == null) return;
    try {
      if (_isFlashOn) {
        await controller.setFlashMode(FlashMode.off);
      } else {
        await controller.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
      HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  /// Call this function from your Controller if API returns "Multiple codes found"
  void triggerMultipleCodesError() {
    setState(() {
      _isAmbiguous = true;
      _instructionText = "MULTIPLE CODES! ZOOM IN ON ONE";
    });
    HapticFeedback.heavyImpact();

    // Reset error after 3 seconds
    _errorResetTimer?.cancel();
    _errorResetTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAmbiguous = false;
          _instructionText = "ALIGN CODE TO SCAN";
        });
      }
    });
  }

  Future<void> _handleScan() async {
    // 1. Prevent scanning if user is too zoomed out (likely seeing full map)
    if (_currentZoom < 1.2) {
      setState(() {
        _isAmbiguous = true;
        _instructionText = "TOO FAR! ZOOM IN TO FOCUS";
      });
      HapticFeedback.heavyImpact();

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isAmbiguous) {
          setState(() {
            _isAmbiguous = false;
            _instructionText = "ALIGN CODE TO SCAN";
          });
        }
      });
      return;
    }

    // prevent double scans while a scan is in progress
    if (c.isLoading.value) return;

    // 2. Proceed to scan
    HapticFeedback.mediumImpact();
    await c.scanImage();

    // Example: If your controller detects multiple, you would call:
    // triggerMultipleCodesError();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _errorResetTimer?.cancel();
    c.cameraController.value?.setFlashMode(FlashMode.off);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanWindowSize = size.width * _scanWindowScale;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    // Color Logic based on state
    final Color scanColor = _isAmbiguous
        ? Colors
              .orangeAccent // Warning Color
        : Colors.cyanAccent; // Normal Color

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
            // 1. Camera Layer
            _buildCameraPreview(cutoutRect),

            // 2. Dark Overlay
            _buildOverlay(size, cutoutRect),

            // 3. Viewfinder (Border + Laser)
            _buildViewfinder(cutoutRect, scanColor),

            // 4. Status Pill (Top)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 0,
              right: 0,
              child: Center(child: _buildStatusPill(scanColor)),
            ),

            // 5. Controls (Bottom)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildBottomControls(scanColor),
            ),

            // 6. Loading Overlay
            Obx(() {
              if (c.isLoading.value) {
                return Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(Rect rect) {
    return Obx(() {
      final controller = c.cameraController.value;
      if (controller == null || !controller.value.isInitialized) {
        return Container(color: Colors.black);
      }

      if (c.savedImagePath.value != null && c.isLoading.value) {
        return Positioned.fromRect(
          rect: rect,
          child: Image.file(File(c.savedImagePath.value!), fit: BoxFit.cover),
        );
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
        child: SizedBox.expand(child: CameraPreview(controller)),
      );
    });
  }

  Widget _buildOverlay(Size size, Rect cutoutRect) {
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

  Widget _buildViewfinder(Rect rect, Color color) {
    return Positioned.fromRect(
      rect: rect,
      child: Stack(
        children: [
          // Corner Borders
          CustomPaint(
            painter: CornerBorderPainter(color: color),
            child: Container(),
          ),
          // Laser Line (Hidden if ambiguous/error)
          if (!_isAmbiguous)
            Obx(() {
              if (c.isLoading.value) return const SizedBox.shrink();
              return ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: LaserLinePainter(
                        value: _animationController.value,
                        color: color,
                      ),
                      child: Container(),
                    );
                  },
                ),
              );
            }),
          // Warning Icon in center if ambiguous
          if (_isAmbiguous)
            Center(
              child: Icon(
                Icons.warning_amber_rounded,
                color: color.withOpacity(0.5),
                size: 80,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isAmbiguous
                ? Colors.red.withOpacity(0.2) // Red tint for error
                : Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => Icon(
                  c.isLoading.value
                      ? Icons.hourglass_top_rounded
                      : (_isAmbiguous
                            ? Icons.zoom_in
                            : Icons.qr_code_scanner_rounded),
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Obx(
                () => Text(
                  c.isLoading.value ? "ANALYZING..." : _instructionText,
                  style: TextStyle(
                    color: color, // Text changes color too
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom Slider & Flash
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _isFlashOn ? Colors.amber : Colors.white70,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color.withOpacity(0.8),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: color,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    trackHeight: 2,
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _currentZoom,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoom = value;
                        // Clear error if user zooms in
                        if (value > 1.2) {
                          _isAmbiguous = false;
                          _instructionText = "ALIGN CODE TO SCAN";
                        }
                      });
                      await c.cameraController.value?.setZoomLevel(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${_currentZoom.toStringAsFixed(1)}x",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Capture Button
        GestureDetector(
          onTap: _handleScan,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 1),
            ),
            child: Center(
              child: Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------
// PAINTERS
// ------------------------------------------------------------------

class CornerBorderPainter extends CustomPainter {
  final Color color;
  CornerBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final double cornerLen = 30;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLen)
        ..lineTo(0, 0)
        ..lineTo(cornerLen, 0),
      paint,
    );
    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLen, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerLen),
      paint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLen)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - cornerLen, size.height),
      paint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(cornerLen, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, size.height - cornerLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CornerBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

class LaserLinePainter extends CustomPainter {
  final double value;
  final Color color;

  LaserLinePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * value;
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.0), color, color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, y, size.width, 2));

    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);
  }

  @override
  bool shouldRepaint(covariant LaserLinePainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'package:odisha_air_map/navigators/routes_management.dart';
import 'package:odisha_air_map/utils/onboarding_pref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    final seen = await OnboardingPref.isSeen();

    if (seen) {
      RouteManagement.goToHome();
    } else {
      RouteManagement.goToOnboarding();
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Opacity(
              opacity: 0.9,
              child: Image.asset(
                'assets/images/odisha.png',
                width: 340,
                fit: BoxFit.contain,
                color: const Color.fromARGB(255, 152, 255, 255),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ScannerBeamPainter(scanValue: _scanAnimation.value),
                child: Container(),
              );
            },
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  "ODISHA AIR MAP",
                  // "ODISHA AIR MAP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerBeamPainter extends CustomPainter {
  final double scanValue;
  ScannerBeamPainter({required this.scanValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double yPos = size.height * scanValue;

    final Paint linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.cyanAccent.withOpacity(0.6),
          Colors.cyanAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, yPos - 100, size.width, 100));

    canvas.drawRect(
      Rect.fromLTWH(0, yPos - 100, size.width, 100),
      glowPaint..style = PaintingStyle.fill,
    );

    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), linePaint);
  }

  @override
  bool shouldRepaint(covariant ScannerBeamPainter oldDelegate) => true;
}

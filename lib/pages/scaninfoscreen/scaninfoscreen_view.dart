import 'package:flutter/material.dart';

class ScannerInfoScreen extends StatelessWidget {
  const ScannerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("How to Scan", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Scanning Guide",
                style: TextStyle(
                  color: Color(0xFF64FFDA),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "1. Hold your device steady.\n"
                "2. Ensure good lighting.\n"
                "3. Align only ONE image within the brackets.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/scan_correct.png',
                          height: 200,
                          fit: BoxFit.fill,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Correct",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/scan_wrong.png',
                          height: 200,
                          fit: BoxFit.fill,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Wrong",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "4. Use the drag line to zoom in and zoom out.\n"
                "5. Use flashlight if needed.\n"
                "6. Tap on the camera button.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

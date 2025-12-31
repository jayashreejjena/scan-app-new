import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odisha_air_map/navigators/routes_management.dart';
import 'package:odisha_air_map/pages/home/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: HomeController(),
      id: 'homepage-view',
      builder: (controller) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xff0A3D62),
                  const Color(0xff2475B0),
                  const Color(0xffDFF6FF),
                ],
              ),
            ),

            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Odisha Explorer',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Scan • Discover • Explore',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // MAIN CONTENT
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Image.asset("assets/images/odisha.png"),
                              ),
                            ),

                            const SizedBox(height: 48),

                            // HEADING
                            Text(
                              "Odisha AIR Map",
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 16),

                            // SUB TEXT
                            Text(
                              "Point your camera at the Odisha map to explore\nfamous tourist destinations in immersive 3D.",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 60),

                            // MAIN BUTTON
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  RouteManagement.goToScanner();
                                },
                                icon: const Icon(Icons.camera_alt, size: 24),
                                label: const Text(
                                  "Start AR Scan",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xff0A3D62),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Obx(() {
                            //   // ✅ OFFLINE READY UI
                            //   if (controller.isFullyDownloaded.value) {
                            //     return Column(
                            //       children: const [
                            //         Icon(
                            //           Icons.offline_pin,
                            //           color: Color(0xff0A3D62),
                            //           size: 42,
                            //         ),
                            //         SizedBox(height: 12),
                            //         Text(
                            //           "All content available offline",
                            //           style: TextStyle(
                            //             fontSize: 16,
                            //             fontWeight: FontWeight.w600,
                            //             color: Color(0xff0A3D62),
                            //           ),
                            //         ),
                            //       ],
                            //     );
                            //   }
                            //   if (controller.patterns.isNotEmpty) {
                            //     return const Text(
                            //       "New content available. Download to update.",
                            //     );
                            //   }

                            //   return Column(
                            //     children: [
                            //       OutlinedButton.icon(
                            //         onPressed: controller.isLoading.value
                            //             ? null
                            //             : () {
                            //                 controller.getAllContent();
                            //               },
                            //         icon: const Icon(
                            //           Icons.download_for_offline,
                            //           size: 20,
                            //         ),
                            //         label: const Text(
                            //           "Download All Content",
                            //           style: TextStyle(
                            //             fontSize: 15,
                            //             fontWeight: FontWeight.w500,
                            //           ),
                            //         ),
                            //         style: OutlinedButton.styleFrom(
                            //           foregroundColor: const Color(0xff0A3D62),
                            //           side: const BorderSide(
                            //             color: Color(0xff0A3D62),
                            //           ),
                            //           padding: const EdgeInsets.symmetric(
                            //             horizontal: 32,
                            //             vertical: 14,
                            //           ),
                            //           shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(32),
                            //           ),
                            //         ),
                            //       ),
                            //       const SizedBox(height: 12),
                            //       if (controller.isLoading.value)
                            //         Text(
                            //           "Downloading ${(controller.downloadProgress.value * 100).toStringAsFixed(0)}%",
                            //           style: const TextStyle(
                            //             fontSize: 14,
                            //             color: Color(0xff0A3D62),
                            //           ),
                            //         ),
                            //     ],
                            //   );
                            // }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

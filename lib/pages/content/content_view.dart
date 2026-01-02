import 'dart:developer';
import 'dart:io';
import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // For ScrollDirection
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:odisha_air_map/pages/home/home_controller.dart';
import 'package:odisha_air_map/pages/objectdetected/object_detected_controller.dart';
import 'package:odisha_air_map/pages/video_player_screen.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final ObjectDetectedController c;
  final HomeController homeController = Get.put(HomeController());

  bool isPlaying = false;
  bool isOpeningVideo = false;

  // Controls are initially shown
  bool showControls = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    c = Get.find<ObjectDetectedController>();

    if (c.locationDetails.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar("Error", "No location data available");
      });
      return;
    }

    _autoPlayAudio();
  }

  Future<void> _autoPlayAudio() async {
    final String? audioUrl = c.locationDetails.value?.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      log("No audio available");
      return;
    }

    final resolvedUrl = audioUrl.startsWith('http')
        ? audioUrl
        : "${ObjectDetectedController.baseUrl}$audioUrl";

    try {
      await _audioPlayer.setUrl(resolvedUrl);
      await _audioPlayer.play();
      if (mounted) setState(() => isPlaying = true);
    } catch (e) {
      log("Audio playback error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double heroHeight = size.height * 0.45;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // 1. Hero / 3D Model Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: _buildHeroSection(),
          ),

          // 2. Scrollable Content
          Positioned.fill(
            top: heroHeight - 40,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  // Hide controls when scrolling DOWN (reading)
                  if (notification.direction == ScrollDirection.reverse) {
                    if (showControls) setState(() => showControls = false);
                  }
                  // Show controls when scrolling UP
                  else if (notification.direction == ScrollDirection.forward) {
                    if (!showControls) setState(() => showControls = true);
                  }
                }
                return false;
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    // Increased top padding so text is visible under the button initially
                    padding: const EdgeInsets.fromLTRB(24, 85, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildDescription(),
                        const SizedBox(height: 32),
                        _buildFactsSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Floating Controls (Redesigned Pill Shape)
          Positioned(
            top:
                heroHeight - 40, // Aligned slightly overlapping the header area
            left: 0,
            right: 0,
            child: Center(child: _buildFloatingControls()),
          ),

          // 4. App Bar (Back Button)
          Positioned(top: 0, left: 0, right: 0, child: _buildAppBar()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _glassIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final String? localPath = c.localModelPath.value;
    String? modelSrc;
    if (localPath != null && File(localPath).existsSync()) {
      modelSrc = 'file://$localPath';
      log("🚀 Using Local Model: $modelSrc");
    } else {
      modelSrc = c.getResolvedModelUrl();
      log("🌐 Using Remote Model: $modelSrc");
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (modelSrc != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ModelViewer(
                src: modelSrc,
                alt: "3D Model",
                autoRotate: true,
                cameraControls: true,
                backgroundColor: Colors.transparent,
                loading: Loading.eager,
              ),
            )
          else
            const Text(
              "3D Model not available",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final details = c.locationDetails.value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "HISTORICAL",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6C63FF),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          details.name,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final description = c.locationDetails.value!.description;
    return Text(
      description,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: const Color(0xFF4A5568),
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildFactsSection() {
    final facts = c.locationDetails.value!.facts;
    if (facts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFFFA726),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              "Did You Know?",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...facts.map((fact) => _buildFactCard(fact.toString())).toList(),
      ],
    );
  }

  Widget _buildFactCard(String fact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF6C63FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fact,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4A5568),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW FLOATING CONTROLS DESIGN ---

  Widget _buildFloatingControls() {
    return AnimatedSlide(
      offset: showControls ? Offset.zero : const Offset(0, 2.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: 80,
          width:
              MediaQuery.of(context).size.width * 0.85, // Max width constraint
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(40), // Fully rounded pill
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.25),
                blurRadius: 25,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Replay Button
              _controlButton(
                icon: Icons.replay_rounded,
                label: "Replay",
                color: Colors.grey.shade600,
                bgColor: Colors.grey.shade100,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await _audioPlayer.seek(Duration.zero);
                  if (isPlaying) await _audioPlayer.play();
                },
              ),

              // Vertical Divider
              Container(width: 1, height: 24, color: Colors.grey.shade200),

              // Main Play/Pause Button
              _mainPlayButton(),

              // Vertical Divider
              Container(width: 1, height: 24, color: Colors.grey.shade200),

              // Video Button
              _controlButton(
                icon: Icons.videocam_rounded,
                label: "Video",
                color: const Color(0xFFFF6584),
                bgColor: const Color(0xFFFF6584).withOpacity(0.1),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _openVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainPlayButton() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;

        return GestureDetector(
          onTap: () async {
            HapticFeedback.selectionClick();
            if (_audioPlayer.playing) {
              await _audioPlayer.pause();
            } else {
              await _audioPlayer.play();
            }
            if (mounted) setState(() => isPlaying = _audioPlayer.playing);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: playing
                    ? [const Color(0xFF4834D4), const Color(0xFF6C63FF)]
                    : [const Color(0xFF6C63FF), const Color(0xFF8C84FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: playing ? 2 : 4,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        );
      },
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openVideo() async {
    final String? videoUrl = c.locationDetails.value?.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video will be available soon.")),
      );
      return;
    }

    final resolvedUrl = videoUrl.startsWith('http')
        ? videoUrl
        : "${ObjectDetectedController.baseUrl}$videoUrl";

    setState(() => isOpeningVideo = true);
    await _audioPlayer.pause();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(videoPath: resolvedUrl),
      ),
    );

    setState(() => isOpeningVideo = false);
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

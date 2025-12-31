import 'dart:developer';
import 'dart:io'; // Import dart:io
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

class _ContentScreenState extends State<ContentScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final ObjectDetectedController c;
  final HomeController homeController = Get.put(HomeController());

  bool isPlaying = false;
  bool isOpeningVideo = false;
  bool showControls = true;

  final ScrollController _scrollController = ScrollController();

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _setupAnimations();
    _autoPlayAudio();
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _entranceController.forward();
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
    _entranceController.dispose();
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: _buildHeroSection(),
          ),
          Positioned.fill(
            top: heroHeight - 40,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  if (notification.direction == ScrollDirection.reverse) {
                    if (showControls) setState(() => showControls = false);
                  } else if (notification.direction ==
                      ScrollDirection.forward) {
                    if (_scrollController.hasClients &&
                        _scrollController.position.pixels <= 20) {
                      if (!showControls) setState(() => showControls = true);
                    }
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
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
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
            ),
          ),
          Positioned(
            top: heroHeight - 35,
            left: 40,
            right: 40,
            child: _buildFloatingControls(),
          ),
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

  // UPDATED HERO SECTION TO USE LOCAL FILE
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

  Widget _buildFloatingControls() {
    return AnimatedScale(
      scale: showControls ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !showControls,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton(
                  icon: Icons.restart_alt_rounded,
                  color: Colors.grey,
                  onTap: () async {
                    await _audioPlayer.seek(Duration.zero);
                    if (isPlaying) await _audioPlayer.play();
                  },
                ),
                _mainPlayButton(),
                _controlButton(
                  icon: Icons.videocam_rounded,
                  color: const Color(0xFFFF6584),
                  onTap: _openVideo,
                ),
              ],
            ),
          ),
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

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _mainPlayButton() {
    return GestureDetector(
      onTap: () async {
        if (_audioPlayer.playing) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play();
        }
        if (mounted) setState(() => isPlaying = _audioPlayer.playing);
      },
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: StreamBuilder<PlayerState>(
          stream: _audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            return Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            );
          },
        ),
      ),
    );
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

import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // 1. Determine Source (File vs Network)
      if (widget.videoPath.startsWith('http')) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoPath),
        );
      } else {
        // Assume local file for offline support
        _videoPlayerController = VideoPlayerController.file(
          File(widget.videoPath),
        );
      }

      await _videoPlayerController.initialize();

      // 2. Configure Chewie (YouTube-like UI)
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,

        // UI Customization
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red, // YouTube red
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white24,
        ),
        placeholder: const Center(child: CircularProgressIndicator()),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              "Video Error: $errorMessage",
              style: const TextStyle(color: Colors.white),
            ),
          );
        },

        // Fullscreen Logic
        allowedScreenSleep: false,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        // Customize the route page builder for smooth transitions
        routePageBuilder: (context, animation, secondaryAnimation, provider) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Scaffold(
                backgroundColor: Colors.black,
                resizeToAvoidBottomInset: false,
                body: Container(
                  alignment: Alignment.center,
                  color: Colors.black,
                  child: provider,
                ),
              );
            },
          );
        },
      );

      setState(() {});
    } catch (e) {
      debugPrint("Error initializing video: $e");
      setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();

    // Reset orientation and UI overlays when leaving
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar is only shown when NOT in fullscreen (Chewie handles fullscreen internally)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Video", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: _isError
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 10),
                    Text(
                      "Could not play video",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              : _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : const CircularProgressIndicator(color: Colors.red),
        ),
      ),
    );
  }
}

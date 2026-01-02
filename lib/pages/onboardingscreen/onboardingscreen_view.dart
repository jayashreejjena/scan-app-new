import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:odisha_air_map/navigators/navigators.dart';
import 'package:odisha_air_map/utils/onboarding_pref.dart';

const Color kDarkBackground = Color(0xFF0F111A);
const Color kCardBackground = Color(0xFF1E2432);
const Color kAccentColor = Color(0xFF6C63FF);
const Color kGlowColor = Color(0x666C63FF);

class OnboardingItem {
  final String imagePath;
  final String title;
  final String subtitle;
  final String description;

  OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _contents = [
    OnboardingItem(
      imagePath: 'assets/images/onboarding1.jpg',
      title: "Explore",
      subtitle: "Odisha's Heritage",
      description:
          "Scan famous places district-wise and explore iconic temples, monuments, and historic landmarks across Odisha",
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding2.jpg',
      title: "Listen",
      subtitle: "To The Legends",
      description:
          "View famous places in an interactive 3D format and explore every detail like never before.",
    ),
    OnboardingItem(
      imagePath: 'assets/images/onboarding3.jpg',
      title: "Experience",
      subtitle: "The Divine Culture",
      description:
          "From Odissi dance to sacred rituals, navigate the spiritual journey with just a tap.",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      RouteManagement.goToHome();
      log("Navigate to Home");
    }
  }

  void _skipOnboarding() async {
    await OnboardingPref.markSeen();
    RouteManagement.goToHome();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kDarkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentIndex != _contents.length - 1)
                    GestureDetector(
                      onTap: _skipOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 38,
                    ), // Placeholder to keep layout stable
                ],
              ),
            ),
            // 2. MIDDLE: PageView with Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contents.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildUniquePage(_contents[index], size);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _contents.length,
                      (index) => _buildAnimatedDot(index),
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: kAccentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kAccentColor.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _currentIndex == _contents.length - 1
                            ? Icons.check
                            : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
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

  Widget _buildUniquePage(OnboardingItem item, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size.width * 0.75,
                  height: size.height * 0.45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: const [
                      BoxShadow(
                        color: kGlowColor,
                        blurRadius: 60,
                        offset: Offset(0, 20),
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                ),
                // The Image Container
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width:
                        size.width * 0.85, // Image is slightly wider than glow
                    height: size.height * 0.48,
                    decoration: BoxDecoration(
                      color: kCardBackground,
                      image: DecorationImage(
                        image: AssetImage(item.imagePath),
                        fit: BoxFit.fill,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    // Add a subtle gradient overlay on the image itself
                    // to make sure it looks integrated
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 2. The Main Title (Two tones)
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${item.title}\n",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25, // Huge font
                    fontWeight: FontWeight.w300, // Light weight
                    height: 1.0,
                    fontFamily: 'Courier', // Or use your custom font
                  ),
                ),
                TextSpan(
                  text: item.subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800, // Bold weight
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. The Description
          Text(
            item.description,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              height: 1.6,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    bool isActive = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 6,
      width: isActive ? 30 : 6,
      decoration: BoxDecoration(
        color: isActive ? kAccentColor : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

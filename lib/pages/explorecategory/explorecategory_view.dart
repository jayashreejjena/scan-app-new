import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odisha_air_map/pages/explorecategory/explorecategory_controller.dart';

class ExploreCategoriesScreen extends StatelessWidget {
  const ExploreCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExplorecategoryController c = Get.put(ExplorecategoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF1A1C1E),
                size: 24,
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          int crossAxisCount = 2;
          double childAspectRatio = 0.85;
          double horizontalPadding = 24.0;

          if (width >= 1200) {
            crossAxisCount = 5;
            childAspectRatio = 0.95;
            horizontalPadding = 80.0;
          } else if (width >= 900) {
            crossAxisCount = 4;
            childAspectRatio = 0.9;
            horizontalPadding = 40.0;
          } else if (width >= 600) {
            crossAxisCount = 3;
            childAspectRatio = 0.88;
            horizontalPadding = 32.0;
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "EXPLORE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey.withOpacity(0.6),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Our Categories",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101828),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // --- Location Indicator ---
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              color: Color(0xFF667085),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              c.districtName.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF344054),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // --- Grid ---
                    Obx(
                      () => GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 60),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: c.categories.length,
                        itemBuilder: (context, index) {
                          final cat = c.categories[index];
                          final palette = _palettes[index % _palettes.length];
                          return _ClassyCategoryCard(
                            category: cat,
                            palette: palette,
                            onTap: () => c.openCategoryItems(cat),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClassyCategoryCard extends StatelessWidget {
  final dynamic category;
  final _CategoryPalette palette;
  final VoidCallback onTap;

  const _ClassyCategoryCard({
    required this.category,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Subtle background gradient for "depth"
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        palette.accent.withOpacity(0.08),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Container
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: palette.accent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: palette.accent.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(category.icon, color: Colors.white, size: 26),
                    ),
                    const Spacer(),
                    // Category Name
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101828),
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Professional Link
                    Row(
                      children: [
                        Text(
                          "Explore",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: palette.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: palette.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Artistic large faded icon background
              Positioned(
                bottom: -20,
                right: -15,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    category.icon,
                    size: 100,
                    color: palette.accent.withOpacity(0.04),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPalette {
  final Color background;
  final Color accent;

  const _CategoryPalette(this.background, this.accent);
}

final List<_CategoryPalette> _palettes = [
  const _CategoryPalette(Color(0xFFEFF6FF), Color(0xFF2563EB)), // Classic Blue
  const _CategoryPalette(Color(0xFFFFF1F2), Color(0xFFE11D48)), // Rose
  const _CategoryPalette(Color(0xFFF5F3FF), Color(0xFF7C3AED)), // Violet
  const _CategoryPalette(Color(0xFFECFDF5), Color(0xFF059669)), // Emerald
  const _CategoryPalette(Color(0xFFFFF7ED), Color(0xFFEA580C)), // Orange
  const _CategoryPalette(Color(0xFFF0FDFA), Color(0xFF0D9488)), // Teal
];

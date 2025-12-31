import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odisha_air_map/pages/explorecategory/explorecategory_controller.dart';

class ExploreCategoriesSheet extends StatelessWidget {
  const ExploreCategoriesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ExplorecategoryController c = Get.put(ExplorecategoryController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int crossAxisCount = 2;
        double childAspectRatio = 0.95;
        double horizontalPadding = 24.0;

        if (width >= 1200) {
          crossAxisCount = 5;
          childAspectRatio = 1.1;
          horizontalPadding = 100.0;
        } else if (width >= 900) {
          crossAxisCount = 4;
          childAspectRatio = 1.0;
          horizontalPadding = 60.0;
        } else if (width >= 600) {
          crossAxisCount = 3;
          childAspectRatio = 0.95;
          horizontalPadding = 40.0;
        }

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 50,
                spreadRadius: 5,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Discover",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF263238),
                        height: 1.1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFFFF6B6B),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Obx(
                              () => Text(
                                c.districtName.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF2D3436),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Responsive Grid of API Categories
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Obx(
                    () => GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 40),
                      physics: const ClampingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: c.categories.length,
                      itemBuilder: (context, index) {
                        final cat = c.categories[index];
                        final palette = _palettes[index % _palettes.length];

                        return _DesignerCategoryCard(
                          category: cat,
                          palette: palette,
                          onTap: () => c.openCategoryItems(cat),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesignerCategoryCard extends StatelessWidget {
  final dynamic category;
  final _CategoryPalette palette;
  final VoidCallback onTap;

  const _DesignerCategoryCard({
    required this.category,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: palette.accent.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Transform.rotate(
                  angle: -pi / 6,
                  child: Icon(
                    category.icon,
                    size: 110,
                    color: palette.accent.withOpacity(0.15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        category.icon,
                        color: palette.accent,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey[900],
                        letterSpacing: 0.5,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Explore",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey[600],
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: palette.accent,
                        ),
                      ],
                    ),
                  ],
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
  const _CategoryPalette(Color(0xFFE3F2FD), Color(0xFF2196F3)),
  const _CategoryPalette(Color(0xFFFBE9E7), Color(0xFFFF7043)),
  const _CategoryPalette(Color(0xFFF3E5F5), Color(0xFFAB47BC)),
  const _CategoryPalette(Color(0xFFE0F2F1), Color(0xFF26A69A)),
  const _CategoryPalette(Color(0xFFFFF3E0), Color(0xFFFFA726)),
  const _CategoryPalette(Color(0xFFFFEBEE), Color(0xFFEF5350)),
];

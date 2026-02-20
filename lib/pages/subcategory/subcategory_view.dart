import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odisha_air_map/navigators/routes_management.dart';
import 'package:odisha_air_map/pages/subcategory/subcategory_controller.dart';

class SubCategoryItemsScreen extends StatelessWidget {
  const SubCategoryItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SubcategoryController c = Get.put(SubcategoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF8F9FB),
            leadingWidth: 60,
            leading: UnconstrainedBox(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            title: Text(
              c.categoryName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.8,
              ),
            ),
          ),
          Obx(() {
            if (c.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              );
            }
            if (c.errorMessage.value != null) {
              return SliverFillRemaining(
                child: Center(child: Text(c.errorMessage.value!)),
              );
            }
            if (c.items.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: Text("No spots found here yet.")),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _CinematicItemCard(
                    item: c.items[index],
                    index: index,
                    onTap: () {
                      RouteManagement.goToObjectDetected(
                        int.parse(c.items[index].id),
                      );
                    },
                  );
                }, childCount: c.items.length),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CinematicItemCard extends StatelessWidget {
  final dynamic item; // Replace with ExploreItem
  final int index;
  final VoidCallback onTap;

  const _CinematicItemCard({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280, // Increased height for better visual impact
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Background Image with Zoom Effect
                Hero(
                  tag: "img_${item.id}",
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.darken,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover, // Cover is more professional than fill
                      errorBuilder: (context, error, stackTrace) =>
                          _StylishPlaceholder(index: index),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Action Bar
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    "View Details",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StylishPlaceholder extends StatelessWidget {
  final int index;
  const _StylishPlaceholder({required this.index});

  @override
  Widget build(BuildContext context) {
    final palettes = [
      [const Color(0xFF1e3c72), const Color(0xFF2a5298)],
      [const Color(0xFFe94057), const Color(0xFFf27121)],
      [const Color(0xFF0ba360), const Color(0xFF3cba92)],
    ];
    final colors = palettes[index % palettes.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white54,
          size: 40,
        ),
      ),
    );
  }
}

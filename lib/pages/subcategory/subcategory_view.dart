import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odisha_air_map/navigators/navigators.dart';
import 'package:odisha_air_map/pages/explorecategory/explorecategory_controller.dart';
import 'package:odisha_air_map/pages/subcategory/subcategory_controller.dart';

class SubCategoryItemsScreen extends StatelessWidget {
  const SubCategoryItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SubcategoryController c = Get.put(SubcategoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: const Color(0xFFF2F2F7),
            toolbarHeight: 56,
            titleSpacing: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                c.categoryName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          Obx(() {
            if (c.isLoading.value) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (c.errorMessage.value != null) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    c.errorMessage.value!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (c.items.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No spots found here yet.",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = c.items[index];
                  return _CinematicItemCard(
                    item: item,
                    index: index, // Pass index for random color generation
                    onTap: () {
                      RouteManagement.goToObjectDetected(int.parse(item.id));
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
  final ExploreItem item;
  final int index;
  final VoidCallback onTap;

  const _CinematicItemCard({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if image is valid
    final bool hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Container(
      height: 240,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Hero(
                    tag: "img_${item.id}",
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.fill,

                      // 🔹 SHOW LOADING WHILE IMAGE IS FETCHING
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // image fully loaded
                        }

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Your stylish placeholder in background
                            _StylishPlaceholder(index: index),

                            // Loader on top
                            Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.black,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ],
                        );
                      },
                      errorBuilder: (_, __, ___) =>
                          _StylishPlaceholder(index: index),
                    ),
                  )
                else
                  _StylishPlaceholder(index: index),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Tap to view",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
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
      // 0: Ocean Blue (Classic)
      [const Color(0xFF2E3192), const Color(0xFF1BFFFF)],
      // 1: Sunset Orange (Warmth)
      [const Color(0xFFFF512F), const Color(0xFFDD2476)],
      // 2: Lush Green (Nature)
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      // 3: Royal Purple (Mystery)
      [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
      // 4: Midnight (Night Life)
      [const Color(0xFF0f2027), const Color(0xFF2c5364)],
    ];

    final colors = palettes[index % palettes.length];

    return Stack(
      children: [
        // 1. Base Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        ),

        // 2. Artistic Background Shape (Watermark effect)
        Positioned(
          right: -40,
          top: -40,
          child: Opacity(
            opacity: 0.15,
            child: Icon(
              // Vary icons based on index too
              index % 2 == 0 ? Icons.location_on_rounded : Icons.map_rounded,
              size: 200,
              color: Colors.white,
            ),
          ),
        ),

        // 3. Central Icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.landscape_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}

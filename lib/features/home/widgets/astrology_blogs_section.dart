import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import 'package:intl/intl.dart';
import '../screens/blog_detail_screen.dart';
import '../controllers/blog_controller.dart';
import '../domain/models/blog_model.dart';
import '../screens/blog_list_screen.dart';

class AstrologyBlogsSection extends StatelessWidget {
  const AstrologyBlogsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blogController = Get.find<BlogController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 72) / 2;

    return Obx(() {
      if (blogController.isLoading.value) {
        return const SizedBox(
          height: 150,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (blogController.blogs.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F2), // Light peach background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Color(0xFFB57E2F), size: 20), // Book icon
                      const SizedBox(width: 8),
                      AppText(
                        'Latest Blogs',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D1E2D), // Deep burgundy color
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const BlogListScreen());
                    },
                    child: Row(
                      children: [
                        AppText(
                          'View All',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D1E2D),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF5D1E2D)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Grid
            SizedBox(
              height: 165,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: blogController.blogs.length,
                itemBuilder: (context, index) {
                  final blog = blogController.blogs[index];
                  final imageUrl = blog.blogImage != null && blog.blogImage!.isNotEmpty
                      ? "${AppUrls.baseImageUrl}${blog.blogImage}"
                      : "";
                  
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => BlogDetailScreen(
                        blogId: blog.id,
                        blogColor: AppColors.primaryColor,
                        imageUrl: imageUrl,
                      ));
                    },
                    child: Container(
                      width: cardWidth,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Hero(
                              tag: 'blog_image_${blog.id}',
                              child: CustomImageWidget(
                                imagePath: imageUrl,
                                height: 85,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  blog.title,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2E1A47),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  height: 1.2,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 10, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    AppText(
                                      blog.createdAt != null 
                                          ? DateFormat('dd MMM yyyy').format(blog.createdAt!) 
                                          : 'Recently',
                                      fontSize: 9,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }
}

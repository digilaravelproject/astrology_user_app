import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import '../screens/blog_detail_screen.dart';
import '../controllers/blog_controller.dart';
import '../domain/models/blog_model.dart';

class AstrologyBlogsSection extends StatelessWidget {
  const AstrologyBlogsSection({Key? key}) : super(key: key);

  static const List<Color> _blogColors = [
    Color(0xFFD32F2F),
    Color(0xFFD84315),
    Color(0xFFC2185B),
  ];

  @override
  Widget build(BuildContext context) {
    final blogController = Get.find<BlogController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF2E1A47),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  AppStrings.interestingAstrologyBlogs,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E1A47),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Blog Grid - Horizontal Scroll with 2 Rows
        Obx(() {
          if (blogController.isLoading.value) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.deepPink,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (blogController.blogs.isEmpty) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: AppText(
                  'No blogs available',
                  fontSize: 14,
                  color: Colors.black45,
                ),
              ),
            );
          }

          final bool isSingleItem = blogController.blogs.length == 1;
          final double dynamicHeight = isSingleItem ? 160 : 300;

          return SizedBox(
            height: dynamicHeight,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSingleItem ? 1 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isSingleItem ? 0.65 : 0.75,
              ),
              itemCount: blogController.blogs.length,
              itemBuilder: (context, index) {
                final blog = blogController.blogs[index];
                final color = _blogColors[index % _blogColors.length];
                final icon = blogController.getBlogImage(index);
                
                return GestureDetector(
                  onTap: () {
                    Get.to(() => BlogDetailScreen(
                      blogId: blog.id,
                      blogColor: color,
                      icon: icon,
                    ));
                  },
                  child: _buildBlogCard(blog, color, icon),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBlogCard(BlogModel blog, Color color, String icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.12),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Hero(
                    tag: 'blog_icon_${blog.id}',
                    child: Image.network(
                      icon,
                      width: 24,
                      height: 24,
                      color: color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.article_rounded,
                          color: color,
                          size: 22,
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                Expanded(
                  child: AppText(
                    blog.title,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E1A47),
                    height: 1.2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Expanded(
              child: AppText(
                blog.subtitle,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                height: 1.4,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: color.withOpacity(0.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

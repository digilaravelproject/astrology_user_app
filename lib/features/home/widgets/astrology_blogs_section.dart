import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import '../../../../core/constants/app_urls.dart';
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
            return SizedBox(
              height: 360,
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
              height: 360,
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
          final double dynamicHeight = isSingleItem ? 180 : 360;

          return SizedBox(
            height: dynamicHeight,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSingleItem ? 1 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isSingleItem ? 0.6 : 0.58,
              ),
              itemCount: blogController.blogs.length,
              itemBuilder: (context, index) {
                final blog = blogController.blogs[index];
                final color = _blogColors[index % _blogColors.length];
                final imageUrl = blog.blogImage != null && blog.blogImage!.isNotEmpty
                    ? "${AppUrls.baseImageUrl}${blog.blogImage}"
                    : "";
                
                return GestureDetector(
                  onTap: () {
                    Get.to(() => BlogDetailScreen(
                      blogId: blog.id,
                      blogColor: color,
                      imageUrl: imageUrl,
                    ));
                  },
                  child: _buildBlogCard(blog, color, imageUrl),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBlogCard(BlogModel blog, Color color, String imageUrl) {
    String formattedDate = DateFormat('MMM dd, yyyy').format(blog.createdAt);
    
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Hero(
                    tag: 'blog_image_${blog.id}',
                    child: CustomImageWidget(
                      imagePath: imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(width: 15),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (blog.type != null && blog.type!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: AppText(
                            blog.type!.toUpperCase(),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      AppText(
                        blog.title,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E1A47),
                        height: 1.2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (blog.subtitle.isNotEmpty)
              AppText(
                blog.subtitle,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            else
              const Spacer(),
            
            const Spacer(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 60,
                      child: AppText(
                        blog.author,
                        fontSize: 9,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppText(
                  formattedDate,
                  fontSize: 9,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

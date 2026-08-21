import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/constants/app_urls.dart';
import '../../home/controllers/blog_controller.dart';
import 'blog_detail_screen.dart';

class BlogListScreen extends StatelessWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blogController = Get.find<BlogController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText('All Blogs'.tr, color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (blogController.isLoading.value && blogController.blogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (blogController.blogs.isEmpty) {
          return Center(child: AppText('No blogs available.'.tr));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Hero(
                        tag: 'blog_image_list_${blog.id}',
                        child: CustomImageWidget(
                          imagePath: imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            blog.title,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            height: 1.3,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  AppText(
                                    blog.createdAt != null 
                                      ? DateFormat('dd MMM yyyy').format(blog.createdAt!) 
                                      : 'Recently',
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  AppText(
                                    'Read more'.tr,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primaryColor),
                                ],
                              )
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
        );
      }),
    );
  }
}

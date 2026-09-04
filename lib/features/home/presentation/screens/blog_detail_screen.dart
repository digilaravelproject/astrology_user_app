import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:astro_user/features/home/presentation/controllers/blog_controller.dart';
import 'package:astro_user/features/home/data/models/blog_model.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;
  final Color blogColor;
  final String imageUrl;

  const BlogDetailScreen({
    Key? key,
    required this.blogId,
    required this.blogColor,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  BlogModel? _blog;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBlogDetail();
  }

  Future<void> _fetchBlogDetail() async {
    final controller = Get.find<BlogController>();
    final result = await controller.fetchBlogById(widget.blogId);
    if (mounted) {
      setState(() {
        _blog = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Blog Details".tr,
        backgroundColor: Colors.white,
        iconColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: widget.blogColor,
                strokeWidth: 2,
              ),
            )
          : _blog == null
              ? const Center(
                  child: AppText('Could not load blog detail.'.tr,
                    fontSize: 15,
                    color: Colors.black45,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Simple Large Image Hero
                      Hero(
                        tag: 'blog_image_${_blog!.id}',
                        child: CustomImageWidget(
                          imagePath: widget.imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category/Type Chip
                            if (_blog!.type != null && _blog!.type!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.blogColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: AppText(
                                  _blog!.type!.toUpperCase().tr,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: widget.blogColor,
                                ),
                              ),

                            const SizedBox(height: 12),

                            // Title
                            AppText(
                              _blog!.title,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2E1A47),
                              height: 1.3,
                            ),

                            const SizedBox(height: 12),

                            // Metadata (Author & Date)
                            Row(
                              children: [
                                Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                AppText(
                                  _blog!.author,
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                const SizedBox(width: 15),
                                Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                AppText(
                                  DateFormat('MMM dd, yyyy').format(_blog!.createdAt),
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            const Divider(height: 1),
                            const SizedBox(height: 20),

                            // Subtitle if available
                            if (_blog!.subtitle.isNotEmpty) ...[
                              AppText(
                                _blog!.subtitle,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              const SizedBox(height: 15),
                            ],

                            // Main Content
                            AppText(
                              _blog!.content,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                              height: 1.6,
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

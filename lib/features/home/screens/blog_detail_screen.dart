import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../controllers/blog_controller.dart';
import '../domain/models/blog_model.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;
  final Color blogColor;
  final String icon;

  const BlogDetailScreen({
    Key? key,
    required this.blogId,
    required this.blogColor,
    required this.icon,
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
    final Color blogColor = widget.blogColor;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: "",
        backgroundColor: Colors.transparent,
        iconColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: blogColor,
                strokeWidth: 2,
              ),
            )
          : _blog == null
              ? const Center(
                  child: AppText(
                    'Could not load blog detail.',
                    fontSize: 15,
                    color: Colors.black45,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Premium Header with Gradient
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Gradient Background
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  blogColor,
                                  blogColor.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: -50,
                                  right: -50,
                                  child: CircleAvatar(
                                    radius: 100,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                Positioned(
                                  bottom: 50,
                                  left: -30,
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Floating Hero Icon
                          Positioned(
                            bottom: -50,
                            child: Hero(
                              tag: 'blog_icon_${_blog!.id}',
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.network(
                                  widget.icon,
                                  width: 70,
                                  height: 70,
                                  color: blogColor,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.article_rounded,
                                      size: 70,
                                      color: blogColor,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 70),

                      // Content Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: blogColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: AppText(
                                "ASTROLOGY INSIGHTS",
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: blogColor,
                                letterSpacing: 1.2,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Title
                            AppText(
                              _blog!.title,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.center,
                              color: const Color(0xFF2E1A47),
                              height: 1.3,
                            ),

                            const SizedBox(height: 16),
                            
                            if (_blog!.subtitle.isNotEmpty) ...[
                              AppText(
                                _blog!.subtitle,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                textAlign: TextAlign.center,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Metadata
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildMetaItem(Icons.person_rounded, _blog!.author),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 15),
                                  height: 4,
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                _buildMetaItem(Icons.calendar_today_rounded, "Today"),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Blog Content
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildBodyText(_blog!.content),
                                  const SizedBox(height: 30),
                                  
                                  // Disclaimer Box
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: AppText(
                                            "For personalized advice, please consult a certified astrologer.",
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
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

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        AppText(
          text,
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildBodyText(String text) {
    return AppText(
      text,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
      height: 1.7,
    );
  }
}

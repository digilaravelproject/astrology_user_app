import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class BlogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> blog;

  const BlogDetailScreen({Key? key, required this.blog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color blogColor = blog['color'] as Color;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // Allow body to go behind app bar
      appBar: CustomAppBar(
        title: "", // No title in app bar, clear view
        backgroundColor: Colors.transparent,
        iconColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                    tag: 'blog_icon_${blog['title']}',
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
                        blog['icon'],
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

            const SizedBox(height: 70), // Space for the floating icon

            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Categories / Tags
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
                    blog['title'],
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.center,
                    color: const Color(0xFF2E1A47),
                    height: 1.3,
                  ),

                  const SizedBox(height: 16),

                  // Metadata Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMetaItem(Icons.access_time_rounded, "5 min read"),
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
                        _buildDropCapContent(blog['description']),
                        
                        const SizedBox(height: 20),
                        
                        _buildSectionHeading("Why is this significant?"),
                        const SizedBox(height: 10),
                        _buildBodyText(
                          "Astrology serves as a cosmic blueprint, offering insights into personality traits, relationships, and life cycles. Understanding the specific energies of ${blog['title'].split('\n').first} can help you navigate upcoming challenges with grace and awareness.",
                        ),

                         const SizedBox(height: 20),
                        
                        _buildSectionHeading("Expert Recommendations"),
                         const SizedBox(height: 10),
                        _buildBodyText(
                          "•  Meditate daily to align your inner energy.\n•  Consult your birth chart for personalized timing.\n•  Use gemstones or colors associated with favorable planets.",
                        ),

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

  Widget _buildSectionHeading(String text) {
    return AppText(
      text,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF2E1A47),
    );
  }

  Widget _buildBodyText(String text) {
    return AppText(
      text,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
      height: 1.7,
    );
  }

  Widget _buildDropCapContent(String text) {
    return AppText(
      text,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
      height: 1.7,
    );
  }
}

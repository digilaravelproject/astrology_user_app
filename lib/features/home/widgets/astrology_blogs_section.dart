import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import 'package:get/get.dart';
import '../screens/blog_detail_screen.dart';

class AstrologyBlogsSection extends StatelessWidget {
  const AstrologyBlogsSection({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> blogs = const [
    {
      "title": "Rahu-Ketu Axis:\nLife Turning Points",
      "description": "Nundi ge besones mme Hoge astrologhts ppn gou in tte sars.",
      "icon": "https://cdn-icons-png.flaticon.com/512/2917/2917995.png",
      "color": Color(0xFFD32F2F),
    },
    {
      "title": "Pomnali\nDelay\nMon Nazar",
      "description": "Nundi hoteolog e tha, honas at asstrologs.",
      "icon": "https://cdn-icons-png.flaticon.com/512/3094/3094651.png",
      "color": Color(0xFFD84315),
    },
    {
      "title": "Kundli Me Love\nDelay Kyun Hotahi?",
      "description": "Nundi hooc it norrohg alog up hie kundit ammogy for mezan hae Caa.",
      "icon": "https://cdn-icons-png.flaticon.com/512/2917/2917999.png",
      "color": Color(0xFFC2185B),
    },
    {
      "title": "Business Success\n& Astrology\nSecret ✨✨",
      "description": "Nandi t Nelcyoor diog the sks, astrologhe bowre hao, Caa.",
      "icon": "https://cdn-icons-png.flaticon.com/512/3094/3094673.png",
      "color": Color(0xFFD32F2F),
    },
    {
      "title": "Nazar &\nAstrology\nConnection",
      "description": "Nandi bou toaec made wit thse ttoghts heore.",
      "icon": "https://cdn-icons-png.flaticon.com/512/2917/2917995.png",
      "color": Color(0xFFD32F2F),
    },
    {
      "title": "Destiny Change\nKab Hoti Hai?",
      "description": "Bere gor guonts, aumeees mids, stragy tio dose a the start.",
      "icon": "https://cdn-icons-png.flaticon.com/512/3094/3094679.png",
      "color": Color(0xFFD84315),
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Blog Grid - Horizontal Scroll with 2 Rows
        SizedBox(
          height: 300, // Adjusted height
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75, // Wide cards (ratio < 1) for horizontal scroll
            ),
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => BlogDetailScreen(blog: blogs[index]));
                },
                child: _buildBlogCard(blogs[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBlogCard(Map<String, dynamic> blog) {
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
          color: (blog['color'] as Color).withOpacity(0.12),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title in one Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (blog['color'] as Color).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Hero(
                    tag: 'blog_icon_${blog['title']}',
                    child: Image.network(
                      blog['icon'] as String,
                      width: 24,
                      height: 24,
                      color: blog['color'] as Color,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.article_rounded,
                          color: blog['color'] as Color,
                          size: 22,
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Title
                Expanded(
                  child: AppText(
                    blog['title'] as String,
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

            // Description
            Expanded(
              child: AppText(
                blog['description'] as String,
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
                  color: (blog['color'] as Color).withOpacity(0.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({super.key});

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      "image": "https://astromanch.com/public/storage/images/blog_1191728388807.webp",
    },
    {
      "image": "https://previews.123rf.com/images/nastasijamal/nastasijamal2107/nastasijamal210700063/171748454-your-personal-horoscope-chart-and-glow-zodiac-sign-astrology-prediction-banner-poster-with-shiny.jpg",
    },
    {
      "image": "https://astromanch.com/public/storage/images/blog_1221728391750.webp",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _slides.length,
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.85,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentPage = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
          itemBuilder: (context, index, realIndex) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomImageWidget(
                  imagePath: _slides[index]['image'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _slides.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF2E1A47))
                    .withValues(alpha: _currentPage == entry.key ? 0.9 : 0.2),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

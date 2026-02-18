import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class RemedyDetailScreen extends StatelessWidget {
  final Map<String, dynamic> remedy;

  const RemedyDetailScreen({
    Key? key,
    required this.remedy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color planetColor = remedy['color'] as Color;
    final List<String> points = List<String>.from(remedy['points']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "${AppStrings.powerfulRemedyFor} ${remedy['planet']}",
        backgroundColor: planetColor.withOpacity(0.05),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    planetColor.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Hero(
                tag: 'remedy_${remedy['planet']}_${remedy['image']}',
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: planetColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: planetColor.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.network(
                      remedy['image'],
                      width: 120,
                      height: 120,
                      color: planetColor,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.brightness_7,
                        size: 120,
                        color: planetColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "${AppStrings.powerfulRemedyFor} ${remedy['planet']}",
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepPink,
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    "This remedy is specifically designed to harmonize the energies of ${remedy['planet']} in your life. Follow these points carefully for best results.",
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  const SizedBox(height: 32),
                  
                  // Detailed Points
                  AppText(
                    "Recommended Actions",
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 16),
                  
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: points.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: planetColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: planetColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppText(
                              points[index],
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Disclaimer/Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blueGrey, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: AppText(
                            "Consult with an expert astrologer for personalized remedies based on your birth chart.",
                            fontSize: 12,
                            color: Colors.blueGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';

class ServiceSectionRow extends StatelessWidget {
  const ServiceSectionRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDE7EF), // Light pink
            Color(0xFFFCE4EC), // Soft pink
            Color(0xFFF8D7E3), // Medium pink
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative stars
          Positioned(top: 15, left: 20, child: _buildStar(9, const Color(0xFFFFE082))),
          Positioned(top: 30, right: 22, child: _buildStar(7, const Color(0xFFF48FB1))),
          Positioned(bottom: 160, left: 18, child: _buildStar(6, const Color(0xFFFFD54F))),
          Positioned(bottom: 170, right: 20, child: _buildStar(8, const Color(0xFFFFAB40))),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildBanner(),
                const SizedBox(height: 16),
                _buildServiceButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStar(double size, Color color) {
    return Icon(Icons.auto_awesome, size: size, color: color);
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE082).withOpacity(0.25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFFFFB74D)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: AppText(
            AppStrings.kundaliMilanMatchMaking,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5D4037),
            letterSpacing: -0.5,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 12),
        const AppText("❤️", fontSize: 22),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF0F5).withOpacity(0.5),
            const Color(0xFFFDE7EF).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: Stack(
        children: [
          // Sparkle effects
          Positioned(top: 15, left: 25, child: _buildStar(7, Colors.white.withOpacity(0.8))),
          Positioned(top: 40, right: 35, child: _buildStar(5, Colors.white.withOpacity(0.7))),
          Positioned(bottom: 25, left: 45, child: _buildStar(6, Colors.white.withOpacity(0.9))),
          Positioned(bottom: 50, right: 55, child: _buildStar(4, Colors.white.withOpacity(0.6))),
          
          // Images - side by side
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Kundali Chart
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/kundali_birth_chart.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            "https://www.prokerala.com/astrology/images/kundli-chart-north.png",
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Zodiac Cards
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/zodiac_tarot_cards.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            "https://cdn-icons-png.flaticon.com/512/2917/2917995.png",
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildServiceButton(
            AppStrings.kundaliMilan,
            Icons.grid_on_rounded,
            const Color(0xFFFFF0F5),
            const Color(0xFFD84315),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildServiceButton(
            AppStrings.kundali,
            Icons.auto_awesome,
            const Color(0xFFFFFBE6),
            const Color(0xFFFF8F00),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildServiceButton(
            AppStrings.matchMaking,
            Icons.favorite,
            const Color(0xFFFFF0F5),
            const Color(0xFFE91E63),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceButton(String title, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          AppText(
            title,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5D4037),
            height: 1.2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

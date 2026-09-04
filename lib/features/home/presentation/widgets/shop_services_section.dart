import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/widgets/app_text.dart';

class ShopServicesSection extends StatelessWidget {
  const ShopServicesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFCE4EC), // Light pink
            Color(0xFFFDE7EF), // Soft pink
            Color(0xFFF8D7E3), // Medium pink
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative stars positioned absolutely
          Positioned(top: 18, left: 22, child: _buildStar(10, const Color(0xFFFFB74D))),
          Positioned(top: 35, right: 24, child: _buildStar(8, const Color(0xFFF48FB1))),
          Positioned(bottom: 95, left: 16, child: _buildStar(7, const Color(0xFFFFD54F))),
          Positioned(bottom: 115, right: 20, child: _buildStar(11, const Color(0xFFFFAB40))),
          Positioned(top: 75, left: 28, child: _buildStar(5, const Color(0xFFFCE4EC))),
          Positioned(top: 185, right: 28, child: _buildStar(7, const Color(0xFFFFE082))),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSectionHeader(),
                const SizedBox(height: 18),
                _buildPromoBanner(),
                const SizedBox(height: 14),
                _buildShopGrid(),
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

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppText("✨".tr, fontSize: 18),
        const SizedBox(width: 8),
        Flexible(
          child: AppText(
            AppStrings.exploreRemedyBlogsServices,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5D4037),
            letterSpacing: -0.3,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
        const AppText("✨".tr, fontSize: 18),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFE5CC),
                Color(0xFFFFD9B3),
                Color(0xFFFFCFA0),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      AppStrings.freePaidRemedies,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF5D4037),
                      height: 1.2,
                      letterSpacing: -0.6,
                    ),
                    const SizedBox(height: 14),
                    _buildCheckItem("✓ ${AppStrings.freeSignificanceRemedies}"),
                    const SizedBox(height: 7),
                    _buildCheckItem("✓ ${AppStrings.bookLiveRemedySession}"),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFFF8F00)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8F00).withOpacity(0.48),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: AppText(
                        AppStrings.checkRemedies,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 45,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/remedy_chest.png',
                    height: 145,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        "https://placehold.co/300x300/png?text=Remedy+Chest", // Pooja Thali
                        height: 145,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // Enhanced sparkles
        Positioned(
          top: 12,
          left: 16,
          child: AppText("✨".tr, fontSize: 13, color: Colors.white.withOpacity(0.75)),
        ),
        Positioned(
          top: 24,
          right: 22,
          child: AppText("✨".tr, fontSize: 11, color: Colors.white.withOpacity(0.65)),
        ),
        Positioned(
          bottom: 16,
          left: 24,
          child: AppText("✨".tr, fontSize: 9, color: Colors.white.withOpacity(0.55)),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    return AppText(
      text,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF5D4037),
      height: 1.4,
    );
  }

  Widget _buildShopGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildShopCard(
            AppStrings.gemstones,
            "assets/images/gemstones_plate.png",
            "https://placehold.co/300x300/png?text=Gemstones", // Rudraksha
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildShopCard(
            AppStrings.bracelets,
            "assets/images/healing_bracelets.png",
            "https://placehold.co/300x300/png?text=Bracelets", // Pooja Items
          ),
        ),
      ],
    );
  }

  Widget _buildShopCard(String title, String imageUrl, String fallbackUrl) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFDE7EF),
                Color(0xFFFCE4EC),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              AppText(
                title,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF6D1B4D),
                letterSpacing: -0.2,
              ),
              const SizedBox(height: 12),
              Container(
                height: 80,
                child: imageUrl.startsWith('assets/')
                    ? Image.asset(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            fallbackUrl,
                            height: 80,
                            fit: BoxFit.contain,
                          );
                        },
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            fallbackUrl,
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error2, stackTrace2) {
                              return Image.network(
                                title == "Gemstones"
                                    ? "https://cdn-icons-png.flaticon.com/512/616/616554.png"
                                    : "https://cdn-icons-png.flaticon.com/512/865/865860.png",
                                height: 80,
                                fit: BoxFit.contain,
                              );
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFCA28), Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8F00).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppText(
                  AppStrings.shopNow,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        // Enhanced star decorations
        Positioned(
          bottom: 10,
          left: 10,
          child: AppText("✨".tr, fontSize: 9, color: Colors.orange.shade200),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: AppText("✨".tr, fontSize: 7, color: Colors.pink.shade100),
        ),
      ],
    );
  }
}

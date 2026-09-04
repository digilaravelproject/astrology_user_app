import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:astro_user/core/constants/image_constants.dart';
import 'package:astro_user/routes/route_helper.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _rotationController;
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: AppStrings.introTitle1,
      subtitle: AppStrings.introSubtitle1,
      description: AppStrings.introDesc1,
      image: ImageConstants.zodiacWheel,
    ),
    OnboardingData(
      title: AppStrings.introTitle2,
      subtitle: AppStrings.introSubtitle2,
      description: AppStrings.introDesc2,
      image: ImageConstants.zodiacWheel,
    ),
    OnboardingData(
      title: AppStrings.introTitle3,
      subtitle: AppStrings.introSubtitle3,
      description: AppStrings.introDesc3,
      image: ImageConstants.zodiacWheel,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Onboarding Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // 3. Navigation Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Dynamic Button (Diamond Arrow -> GET STARTED)
                GestureDetector(
                  onTap: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutQuart,
                      );
                    } else {
                      Get.offAllNamed(RouteHelper.getLoginRoute());
                    }
                  },
                  child: Transform.rotate(
                    angle: (_currentPage == _pages.length - 1 ? 0 : 45) * 3.14159 / 180,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: _currentPage == _pages.length - 1 ? 160 : 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(_currentPage == _pages.length - 1 ? 25 : 12),
                        border: Border.all(color: AppColors.primaryColor, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _currentPage == _pages.length - 1
                            ? Text(
                                AppStrings.getStarted,
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  letterSpacing: 1.2,
                                ),
                              )
                            : Transform.rotate(
                                angle: -45 * 3.14159 / 180,
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.primaryColor,
                                  size: 28,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? AppColors.primaryColor 
                            : AppColors.primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // SKIP Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: TextButton(
              onPressed: () => Get.offAllNamed(RouteHelper.getLoginRoute()),
              child: Text('SKIP'.tr,
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPage(OnboardingData data) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        // Top Arched Section (Enlarged)
        SizedBox(
          height: size.height * 0.6,
          width: double.infinity,
          child: Stack(
            children: [
              // Navy Arched Box (REVERTED)
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 70, 25, 0),
                child: ClipPath(
                  clipper: FullArchClipper(),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF030A29),
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: DualArchBorderPainter(),
                          size: Size.infinite,
                        ),
                        
                        // Rotating Zodiac Wheel (With Bhagwa-Red Gradient)
                        Positioned(
                          top: 30,
                          left: 0,
                          right: 0,
                          child: RotationTransition(
                            turns: _rotationController,
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: ShaderMask(
                                shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                                blendMode: BlendMode.srcIn,
                                child: CustomImageWidget(
                                  imagePath: data.image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom art visual depth
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.transparent,
                                  AppColors.primaryColor.withOpacity(0.05),
                                  AppColors.primaryColor.withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.05), size: 40),
                                Icon(Icons.auto_awesome_rounded, color: Colors.white.withValues(alpha: 0.1), size: 60),
                                Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.05), size: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // DEEP Concave transition (The semi-circle white cutout pushing UP)
              Positioned(
                bottom: -1,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(size.width, 150), // Increased height for deeper curve
                  painter: ConcaveCutoutPainter(),
                ),
              ),
            ],
          ),
        ),

        // Bottom Content Section (Typography centered in white arch area)
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -95), // Pull text UP into the circular cutout
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text("KNOW YOUR\nFUTURE FROM".tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppColors.black.withOpacity(0.35),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FullArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 160);
    path.quadraticBezierTo(0, 0, size.width / 2, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 160);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DualArchBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 160);
    path.quadraticBezierTo(0, 0, size.width / 2, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 160);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, Paint()..color = AppColors.primaryColor..style = PaintingStyle.stroke..strokeWidth = 6);
    canvas.drawPath(path, Paint()..color = const Color(0xFF030A29)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawPath(path, Paint()..color = AppColors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ConcaveCutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = AppColors.white;
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    // Draw a more circular/elliptical arch
    path.arcToPoint(
      Offset(size.width, size.height * 0.5),
      radius: Radius.circular(size.width * 0.6),
      clockwise: true,
    );
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
  });
}

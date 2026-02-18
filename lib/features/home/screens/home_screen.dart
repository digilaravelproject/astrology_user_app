import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../widgets/animated_zodiac_wheel.dart';
import '../widgets/home_greeting.dart';
import '../widgets/horoscope_pill.dart';
import '../widgets/founder_message_banner.dart';
import '../widgets/remedy_grid.dart';
import '../widgets/service_section_row.dart';
import '../widgets/shop_services_section.dart';
import '../widgets/astrology_blogs_section.dart';
import '../widgets/astrologers_preview_section.dart';
import '../widgets/live_session_section.dart';
import '../../matrimony/widgets/matrimony_section.dart';
import '../widgets/remedy_services_section.dart';
import '../../wallet/screens/wallet_screen.dart';
import '../../notification/screens/notification_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  String selectedFilter = 'All';
  
  final List<String> filters = [AppStrings.homeFilter, AppStrings.homeAll, AppStrings.homeFavourite, AppStrings.homeNew];

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,

            titleSpacing: 0,

            // Top Bar (Pinned)
            title: Container(

              alignment: Alignment.center,
              child: _buildStickyTopBar(authController),
            ),


            // Scrollable Content (Scrolls behind pinned headers)
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: Colors.white,
              ),
            ),
          ),
          
          // Astrologers List
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildScrollableGreeting(authController),
                  ),
                  const SizedBox(height: 25),
                  const FounderMessageBanner(),
                  const SizedBox(height: 25),
                  const RemedyGrid(),
                  const SizedBox(height: 15),
                  const AstrologyBlogsSection(),
                  const SizedBox(height: 25),
                  
                  // Talk to Astrologer Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0).withOpacity(0.1), // Purple tint
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Color(0xFF9C27B0),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AppText(
                          AppStrings.talkToAstrologer,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E1A47),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterBarDelegate(
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: _buildFilterBarUI(),
              ),
            ),
          ),
          // Astrologers List
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: const AstrologersPreviewSection(),
            ),
          ),


          SliverToBoxAdapter(
            child: Container(
                child: Column(
                  children: [
                    const SizedBox(height: 35),
                    const LiveSessionSection(),
                    const SizedBox(height: 35),
                    const RemedyServicesSection(),
                    const SizedBox(height: 150),
                  ],
                )
            ),
          ),
          
          // // Remaining content
          // SliverToBoxAdapter(
          //   child: Column(
          //     children: [
          //       const ShopServicesSection(),
          //       const SizedBox(height: 35),
          //       const ServiceSectionRow(),
          //       const SizedBox(height: 35),
          //       const MatrimonySection(),
          //       const SizedBox(height: 40),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }



  Widget _buildStickyTopBar(AuthController authController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const ProfileScreen()),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(
                      authController.currentUser.value?.name.isNotEmpty == true
                          ? authController.currentUser.value!.name[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                      ),
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
                child: _buildCoinWalletChip(),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Get.to(() => const NotificationScreen()),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF2E1A47)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBarUI() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            bool isSelected = selectedFilter == filter;
            bool isFilter = filter == AppStrings.homeFilter;

            
            return Container(
              padding:  EdgeInsets.only(right: 10 , left: isFilter? 12:0),
              child: GestureDetector(
                onTap: () {
                  if (filter == AppStrings.homeFilter) {
                    _showFilterBottomSheet(context);
                  } else {
                    setState(() {
                      if (selectedFilter == filter && filter != AppStrings.homeAll) {
                        selectedFilter = AppStrings.homeAll;
                      } else {
                        selectedFilter = filter;
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isFilter || isSelected
                        ? const LinearGradient(
                            colors: [AppColors.deepPink, Color(0xFFD81B60)], // Deep Pink Gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isFilter || isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isFilter || isSelected ? Colors.transparent : AppColors.deepPink.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      if (isFilter || isSelected)
                        BoxShadow(
                          color: AppColors.deepPink.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      else
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFilter) ...[
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AppText(
                              '1',
                              color: AppColors.deepPink,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (filter == AppStrings.homeAll) ...[
                        Icon(
                          Icons.apps,
                          color: isSelected ? Colors.white : AppColors.deepPink,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                      ],
                      if (filter == AppStrings.homeFavourite) ...[
                        Icon(
                          Icons.star_outline,
                          color: isSelected ? Colors.white : AppColors.deepPink,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                      ],
                      if (filter == AppStrings.homeNew) ...[
                        Icon(
                          Icons.auto_awesome,
                          color: isSelected ? Colors.white : AppColors.deepPink,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                      ],
                      AppText(
                        filter == AppStrings.homeFilter ? AppStrings.homeFilter : (filter == AppStrings.homeAll ? AppStrings.homeAll : (filter == AppStrings.homeFavourite ? AppStrings.homeFavourite : (filter == AppStrings.homeNew ? AppStrings.homeNew : filter))),
                        color: isFilter || isSelected ? Colors.white : AppColors.deepPink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScrollableGreeting(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              AppStrings.hello,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(width: 8),
            Obx(() => AppText(
              authController.currentUser.value?.name ?? AppStrings.guest,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.deepPink,
              height: 1.1,
              letterSpacing: -0.5,
            )),
            const SizedBox(width: 4),
            const WavingEmoji(),
          ],
        ),

      ],
    );
  }

  Widget _buildCoinWalletChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD1D1), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 10),
          ),
          const SizedBox(width: 6),
          AppText(
            "100",
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E1A47),
            letterSpacing: 0.5,
          ),
        ],
      ),
    );
  }


  void _showFilterBottomSheet(BuildContext context) {
    int selectedCategoryIndex = 0;
    Set<String> selectedSkills = {};
    Set<String> selectedLanguages = {};
    String? selectedExperience;
    String? selectedPriceRange;
    String? selectedRating;

    final List<Map<String, dynamic>> filterCategories = [
      {
        'title': AppStrings.skills,
        'type': 'checkbox',
        'options': [AppStrings.filterVedic, AppStrings.filterNumerology, AppStrings.filterTarot, AppStrings.filterPsychic, AppStrings.filterLifeCoach, AppStrings.filterPalmistry, AppStrings.filterVastu]
      },
      {
        'title': AppStrings.languages,
        'type': 'checkbox',
        'options': [AppStrings.filterEnglish, AppStrings.filterHindi, AppStrings.filterMarathi, AppStrings.filterSanskrit, AppStrings.filterBengali, AppStrings.filterTamil, AppStrings.filterTelugu]
      },
      {
        'title': AppStrings.experience,
        'type': 'radio',
        'options': [AppStrings.filter0_2Years, AppStrings.filter3_5Years, AppStrings.filter6_10Years, AppStrings.filter10PlusYears]
      },
      {
        'title': AppStrings.priceRange,
        'type': 'radio',
        'options': [AppStrings.filterPrice0_200, AppStrings.filterPrice200_400, AppStrings.filterPrice400_600, AppStrings.filterPrice600Plus]
      },
      {
        'title': AppStrings.rating,
        'type': 'radio',
        'options': [AppStrings.filter5Stars, AppStrings.filter4PlusStars, AppStrings.filter3PlusStars, AppStrings.filterAllRatings]
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75, // Increased height slightly
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), // Sharper corners for modern look
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        AppStrings.filtersTitle,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                // Content (Split Layout)
                Expanded(
                  child: Row(
                    children: [
                      // Left Side: Categories
                      Container(
                        width: 140,
                        color: const Color(0xFFF5F5F5), // Light grey background
                        child: ListView.builder(
                          itemCount: filterCategories.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedCategoryIndex == index;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedCategoryIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
                                  border: isSelected
                                      ? const Border(left: BorderSide(color: AppColors.deepPink, width: 4))
                                      : null,
                                ),
                                child: AppText(
                                  filterCategories[index]['title'],
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.black : Colors.black54,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Right Side: Options
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            itemCount: (filterCategories[selectedCategoryIndex]['options'] as List).length,
                            itemBuilder: (context, index) {
                              String option = filterCategories[selectedCategoryIndex]['options'][index];
                              String type = filterCategories[selectedCategoryIndex]['type'];
                              String categoryTitle = filterCategories[selectedCategoryIndex]['title'];

                              if (type == 'checkbox') {
                                bool isChecked = categoryTitle == 'Skills'
                                    ? selectedSkills.contains(option)
                                    : selectedLanguages.contains(option);

                                return CheckboxListTile(
                                  value: isChecked,
                                  activeColor: AppColors.deepPink,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  title: AppText(
                                    option,
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  onChanged: (bool? value) {
                                    setModalState(() {
                                      if (categoryTitle == 'Skills') {
                                        if (value == true) {
                                          selectedSkills.add(option);
                                        } else {
                                          selectedSkills.remove(option);
                                        }
                                      } else {
                                        if (value == true) {
                                          selectedLanguages.add(option);
                                        } else {
                                          selectedLanguages.remove(option);
                                        }
                                      }
                                    });
                                  },
                                );
                              } else {
                                // Radio
                                String? groupValue;
                                if (categoryTitle == 'Experience') groupValue = selectedExperience;
                                else if (categoryTitle == 'Price') groupValue = selectedPriceRange;
                                else if (categoryTitle == 'Rating') groupValue = selectedRating;

                                Widget titleWidget;

                                if (categoryTitle == 'Rating') {
                                  int ratingValue = 0;
                                  if (option.contains('5')) ratingValue = 5;
                                  else if (option.contains('4')) ratingValue = 4;
                                  else if (option.contains('3')) ratingValue = 3;

                                  if (option == 'All Ratings') {
                                    titleWidget = AppText(
                                      option,
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    );
                                  } else {
                                    titleWidget = Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          Icons.star,
                                          color: index < ratingValue ? Colors.amber : Colors.grey.withOpacity(0.3),
                                          size: 18,
                                        );
                                      }),
                                    );
                                  }
                                } else {
                                  titleWidget = AppText(
                                    option,
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  );
                                }

                                return RadioListTile<String>(
                                  value: option,
                                  groupValue: groupValue,
                                  activeColor: AppColors.deepPink,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  title: titleWidget,
                                  onChanged: (String? value) {
                                    setModalState(() {
                                      if (categoryTitle == 'Experience') selectedExperience = value;
                                      else if (categoryTitle == 'Price') selectedPriceRange = value;
                                      else if (categoryTitle == 'Rating') selectedRating = value;
                                    });
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              selectedSkills.clear();
                              selectedLanguages.clear();
                              selectedExperience = null;
                              selectedPriceRange = null;
                              selectedRating = null;
                            });
                          },
                          child: AppText(
                            AppStrings.clearAll,
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Apply filters logic here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.deepPink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: AppText(
                              AppStrings.applyFilters,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }
}
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterBarDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 60,
      child: Container(
        color: Colors.white,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterBarDelegate oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../widgets/matrimony_section.dart';
import '../../matrimony/screens/matrimony_registration_screen.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';

import '../../matrimony/controllers/matrimony_controller.dart';
import '../../../core/widgets/custom_image_widget.dart';

class MatrimonyScreen extends StatefulWidget {
  const MatrimonyScreen({super.key});

  @override
  State<MatrimonyScreen> createState() => _MatrimonyScreenState();
}

class _MatrimonyScreenState extends State<MatrimonyScreen> {
  final MatrimonyController _controller = Get.find<MatrimonyController>();
  final TextEditingController _searchController = TextEditingController();
  final RxBool _isSearching = false.obs;
  
  // Filter state
  String _selectedAgeRange = 'All';
  String _selectedReligion = 'All';
  String _selectedEducation = 'All';
  String _selectedMaritalStatus = 'All';
  String _selectedLocation = 'All';

  @override
  void initState() {
    super.initState();
    // Refresh registration status from server when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.refreshRegistrationStatusFromServer();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context) {
    String selectedCategory = 'Age Range';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      'Filters',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedAgeRange = 'All';
                              _selectedReligion = 'All';
                              _selectedEducation = 'All';
                              _selectedMaritalStatus = 'All';
                              _selectedLocation = 'All';
                            });
                            _controller.getMatrimonyProfile();

                          },
                          child: const AppText(
                            'CLEAR ALL',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 22),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Body with sidebar and content
              Expanded(
                child: Row(
                  children: [
                    // Left Sidebar - Categories
                    Container(
                      width: 120,
                      color: const Color(0xFFF5F5F5),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildCategoryItem(
                            'Age Range',
                            selectedCategory,
                            () => setModalState(() => selectedCategory = 'Age Range'),
                          ),
                          _buildCategoryItem(
                            'Religion',
                            selectedCategory,
                            () => setModalState(() => selectedCategory = 'Religion'),
                          ),
                          _buildCategoryItem(
                            'Education',
                            selectedCategory,
                            () => setModalState(() => selectedCategory = 'Education'),
                          ),
                          _buildCategoryItem(
                            'Marital Status',
                            selectedCategory,
                            () => setModalState(() => selectedCategory = 'Marital Status'),
                          ),
                          _buildCategoryItem(
                            'Location',
                            selectedCategory,
                            () => setModalState(() => selectedCategory = 'Location'),
                          ),
                        ],
                      ),
                    ),
                    
                    // Right Content - Options
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: _buildFilterOptions(selectedCategory, setModalState),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Apply Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFE91E63)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const AppText(
                          'CLOSE',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          
                          // Construct query string
                          List<String> queries = [];
                          if (_selectedAgeRange != 'All') queries.add(_selectedAgeRange);
                          if (_selectedReligion != 'All') queries.add(_selectedReligion);
                          if (_selectedEducation != 'All') queries.add(_selectedEducation);
                          if (_selectedMaritalStatus != 'All') queries.add(_selectedMaritalStatus);
                          if (_selectedLocation != 'All') queries.add(_selectedLocation);
                          
                          String queryString = queries.join(' ');
                          if (queryString.isEmpty) {
                            _controller.getMatrimonyProfile();
                          } else {
                            _controller.searchMatrimonyProfiles(queryString);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Filters applied successfully!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(20),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const AppText(
                          'APPLY',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, String selectedCategory, VoidCallback onTap) {
    final isSelected = selectedCategory == title;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFFE91E63) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: AppText(
          title,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.black87 : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildFilterOptions(String category, StateSetter setModalState) {
    Map<String, List<String>> options = {
      'Age Range': ['All', '21-25', '26-30', '31-35', '36-40', '40+'],
      'Religion': ['All', 'Hindu', 'Muslim', 'Christian', 'Sikh', 'Buddhist', 'Jain', 'Other'],
      'Education': ['All', 'Graduate', 'Post Graduate', 'Doctorate', 'Diploma', 'High School'],
      'Marital Status': ['All', 'Never Married', 'Divorced', 'Widowed', 'Separated'],
      'Location': ['All', 'Mumbai', 'Delhi', 'Bangalore', 'Pune', 'Hyderabad', 'Chennai'],
    };

    String selectedValue = '';
    Function(String) onSelect = (value) {};

    switch (category) {
      case 'Age Range':
        selectedValue = _selectedAgeRange;
        onSelect = (value) => setModalState(() => _selectedAgeRange = value);
        break;
      case 'Religion':
        selectedValue = _selectedReligion;
        onSelect = (value) => setModalState(() => _selectedReligion = value);
        break;
      case 'Education':
        selectedValue = _selectedEducation;
        onSelect = (value) => setModalState(() => _selectedEducation = value);
        break;
      case 'Marital Status':
        selectedValue = _selectedMaritalStatus;
        onSelect = (value) => setModalState(() => _selectedMaritalStatus = value);
        break;
      case 'Location':
        selectedValue = _selectedLocation;
        onSelect = (value) => setModalState(() => _selectedLocation = value);
        break;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: options[category]!.map((option) {
        final isSelected = selectedValue == option;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF0F5) : Colors.transparent,
              border: Border.all(
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey[300]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? const Color(0xFFE91E63) : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    option,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.black87 : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // isRegistered is now set based on plan_id and isMatrimony from shared preferences
      debugPrint("MatrimonyScreen: isRegistered = ${_controller.isRegistered.value}");
      debugPrint("MatrimonyScreen: pref isMatrimony = ${SharedPrefs.getBool("isMatrimony")}");
      debugPrint("MatrimonyScreen: pref plan_id = ${SharedPrefs.getInt("plan_id")}");

      if (!_controller.isRegistered.value) {
        return _buildLandingUI();
      }

      if (!_controller.hasPlan.value) {
        return _buildPurchaseUI();
      }



      // If both plan and matrimony registration are complete, show data screen
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 70, // Slightly taller for better spacing
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFFFFF0F5), Colors.white], // Soft Pink to White
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: _isSearching.value
              ? Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFFFD1DC).withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: AppStrings.findYourSoulmatch,
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFE91E63), size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (value) {
                      _controller.updateSearchQuery(value);
                      if (value.length > 2) {
                        _controller.searchMatrimonyProfiles(value);
                      } else if (value.isEmpty) {
                        _controller.getMatrimonyProfile();
                      }
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _controller.searchMatrimonyProfiles(value);
                      } else {
                        _controller.getMatrimonyProfile();
                      }
                    },

                  ),
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFFF5E9D)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText(
                        AppStrings.matrimony,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D3142),
                        letterSpacing: -0.5,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: const Color(0xFFE91E63),
                  size: 26,
                ),
                onPressed: () => _showFilterBottomSheet(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  _isSearching.value ? Icons.close_rounded : Icons.search_rounded,
                  color: const Color(0xFFE91E63),
                  size: 26,
                ),
                onPressed: () {
                  _isSearching.value = !_isSearching.value;
                  if (!_isSearching.value) {
                    _searchController.clear();
                    _controller.updateSearchQuery('');
                    _controller.getMatrimonyProfile();
                  }

                },
              ),
            ),
          ],
        ),
        body: const SingleChildScrollView(
          child: MatrimonySection(),
        ),
      );
    });
  }

  Widget _buildLandingUI() {
    return Container(
      color: const Color(0xFF1A0A2E), // Ensure container background is same as theme
      child: Stack(
        children: [
          // Full-screen background color
          Positioned.fill(
            child: Container(color: const Color(0xFF1A0A2E)),
          ),
          
          // Background Floral Pattern
          Positioned(
            top: -50,
            right: -50,
            child: Icon(
              Icons.filter_vintage,
              size: 300,
              color: Colors.purple.withOpacity(0.05),
            ),
          ),
          Positioned(
            top: 100,
            left: -20,
            child: Icon(
              Icons.filter_vintage,
              size: 200,
              color: Colors.pink.withOpacity(0.05),
            ),
          ),
          
          // Content
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 100), // Top spacing instead of Spacer for consistency
                        
                        // Overlapping Profile Images
                        SizedBox(
                          height: 220,
                          width: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: _buildCircularProfile('https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: _buildCircularProfile('https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        AppText(
                          AppStrings.soulMatesTitle,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF5E9D),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Gradient "Get Started" Button
                        GestureDetector(
                          onTap: () {
                            Get.to(() => MatrimonyRegistrationScreen(
                              onComplete: () {
                                _controller.checkRegistrationStatus(); // Refresh status properly
                                Get.back();
                              },
                            ));
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE940BE),
                                  Color(0xFFFF5E5E),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF5E5E).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: AppText(
                                AppStrings.getStartedNormal,
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 150), // Increased space for floating bottom nav
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseUI() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF0F5), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 80,
                  color: Color(0xFFE91E63),
                ),
              ),
              const SizedBox(height: 40),
              const AppText(
                'Unlock Premium Access',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D3142),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppText(
                'Unlock the power of Matrimony! Purchase a membership plan to view detailed profiles and find your perfect life partner today.',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.subscriptionScreen);
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFFF5E9D)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        AppText(
                          'Buy Membership Now',
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  _controller.refreshRegistrationStatusFromServer();
                },
                child: AppText(
                  'Already purchased? Refresh',
                  color: const Color(0xFFE91E63).withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProfile(String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.amber, // Golden border
        shape: BoxShape.circle,
      ),
      child: CustomImageWidget(
        imagePath: imageUrl,
        height: 90,
        width: 90,
        radius: BorderRadius.circular(45),
        fit: BoxFit.cover,
      ),
    );
  }
}

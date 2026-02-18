import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../core/utils/image_picker_helper.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';

class MatrimonyRegistrationScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const MatrimonyRegistrationScreen({super.key, required this.onComplete});

  @override
  State<MatrimonyRegistrationScreen> createState() => _MatrimonyRegistrationScreenState();
}

class _MatrimonyRegistrationScreenState extends State<MatrimonyRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form Data
  String? _selectedProfileFor;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String _countryCode = "+91";
  File? _matrimonyPhoto;

  final List<String> _profileForOptions = [
    AppStrings.myself, AppStrings.mySon, AppStrings.myDaughter, 
    AppStrings.myBrother, AppStrings.mySister, AppStrings.myFriend, 
    AppStrings.myRelative
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final Submit
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8), // Soft pink background from screenshots
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A1010)),
          onPressed: () {
            if (_currentStep > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          if (_currentStep == 2 || _currentStep == 3)
            TextButton(
              onPressed: _nextStep,
              child: AppText(
                AppStrings.skip,
                color: AppColors.deepPink,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepPink),
              borderRadius: BorderRadius.circular(10),
              minHeight: 4,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.startWithIntro,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A1010),
          ),
          const SizedBox(height: 24),
          AppText(
            AppStrings.creatingProfileFor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4A1010),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _profileForOptions.map((option) {
              final isSelected = _selectedProfileFor == option;
              return GestureDetector(
                onTap: () => setState(() => _selectedProfileFor = option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.deepPink.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? AppColors.deepPink : Colors.grey.shade200,
                    ),
                  ),
                  child: AppText(
                    option,
                    color: isSelected ? AppColors.deepPink : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildTextField(AppStrings.firstNameReq, _firstNameController)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(AppStrings.lastNameReq, _lastNameController)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.emailReq, _emailController),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButton<String>(
                  value: _countryCode,
                  underline: const SizedBox(),
                  onChanged: (val) => setState(() => _countryCode = val!),
                  items: ["+91", "+1", "+44"].map((code) {
                    return DropdownMenuItem(value: code, child: Text(code));
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(AppStrings.mobileReq, _mobileController)),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            AppStrings.matchesContactInfo,
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 32),
          _buildSafetyBanner(),
          const SizedBox(height: 40),
          CustomButton(
            text: AppStrings.next,
            onTap: _nextStep,
            backgroundColor: const Color(0xFFB01D53), // Darker pink from screenshot
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.buildYourProfile,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A1010),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildTextField(AppStrings.day, TextEditingController())),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(AppStrings.month, TextEditingController())),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(AppStrings.year, TextEditingController())),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdownField(AppStrings.heightReq),
          const SizedBox(height: 16),
          _buildDropdownField(AppStrings.maritalStatusReq),
          const SizedBox(height: 16),
          _buildDropdownField(AppStrings.currentLocationReq),
          const SizedBox(height: 16),
          _buildDropdownField(AppStrings.highestEducationReq),
          const SizedBox(height: 16),
          _buildDropdownField(AppStrings.jobTitleReq),
          const SizedBox(height: 16),
          _buildDropdownField(AppStrings.annualIncomeReq),
          const SizedBox(height: 40),
          CustomButton(
            text: AppStrings.next,
            onTap: _nextStep,
            backgroundColor: const Color(0xFFB01D53),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              AppText(
                AppStrings.verifyYourProfile,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4A1010),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            AppStrings.verificationMsg,
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildSimpleChip(AppStrings.panCard, true),
              const SizedBox(width: 12),
              _buildSimpleChip(AppStrings.drivingLicence, false),
            ],
          ),
          const SizedBox(height: 12),
          _buildSimpleChip(AppStrings.aadhaarCard, false),
          const SizedBox(height: 32),
          _buildTextField(AppStrings.panNumber, TextEditingController()),
          const Spacer(),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                AppText(AppStrings.infoSafePrivate, fontSize: 12, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: AppStrings.verifyNow,
            onTap: _nextStep,
            backgroundColor: const Color(0xFFB01D53),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.profilesWithPhotosMsg,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A1010),
          ),
          const SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: () async {
                final file = await ImagePickerHelper.showImagePickerSheet(context);
                if (file != null) {
                  setState(() => _matrimonyPhoto = file);
                }
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                  image: _matrimonyPhoto != null
                      ? DecorationImage(
                          image: FileImage(_matrimonyPhoto!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _matrimonyPhoto == null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.person, size: 60, color: Colors.grey.shade300),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: AppText(AppStrings.addPhoto, fontWeight: FontWeight.w700, fontSize: 18)),
          const Spacer(),
          Center(child: AppText(AppStrings.photosSafeMsg, color: Colors.pink.shade200, fontSize: 14)),
          Center(child: AppText(AppStrings.photoPrivacyMsg, color: Colors.pink.shade200, fontSize: 12)),
          const SizedBox(height: 32),
          CustomButton(
            text: AppStrings.uploadPhotos,
            onTap: _nextStep,
            backgroundColor: const Color(0xFFB01D53),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: AppText(label, color: Colors.grey),
          items: [],
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildSimpleChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFB01D53) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
      ),
      child: AppText(
        label,
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade100.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, color: Color(0xFFB01D53), size: 16),
              const SizedBox(width: 8),
              AppText(AppStrings.safetyFirst, fontWeight: FontWeight.w700, color: const Color(0xFFB01D53)),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            AppStrings.sangamSafetyMsg,
            fontSize: 12,
            textAlign: TextAlign.center,
            color: const Color(0xFFB01D53),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/utils/image_picker_helper.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/matrimony_controller.dart';
import '../domain/models/matrimony_profile_model.dart';
import '../widgets/matrimony_section.dart';
import 'matrimony_profile_screen.dart';
import 'matrimony_screen.dart';

class MatrimonyRegistrationScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const MatrimonyRegistrationScreen({super.key, required this.onComplete});

  @override
  State<MatrimonyRegistrationScreen> createState() => _MatrimonyRegistrationScreenState();
}

class _MatrimonyRegistrationScreenState extends State<MatrimonyRegistrationScreen> {
  final PageController _pageController = PageController();
  final MatrimonyController _controller = Get.find<MatrimonyController>();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form Data
  String? _selectedProfileFor;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  
  final TextEditingController _heightController = TextEditingController();
  String? _selectedMaritalStatus;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  String _selectedGender = "Female";

  String _countryCode = "+91";
  XFile? _matrimonyPhoto;

  final List<String> _profileForOptions = [
    AppStrings.myself, AppStrings.mySon, AppStrings.myDaughter, 
    AppStrings.myBrother, AppStrings.mySister, AppStrings.myFriend, 
    AppStrings.myRelative
  ];

  final List<String> _maritalStatusOptions = [
    'Never married', 'Divorced', 'Widowed', 'Awaiting Divorce', 'Annulled'
  ];

  void _nextStep() async {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final Submit
      final dob = "${_yearController.text}-${_monthController.text.padLeft(2, '0')}-${_dayController.text.padLeft(2, '0')}";
      
      final profile = MatrimonyProfileModel(
        createdFor: _selectedProfileFor ?? 'Myself',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _mobileController.text,
        dateOfBirth: dob,
        gender: _selectedGender,
        height: _heightController.text,
        maritalStatus: _selectedMaritalStatus ?? 'Never married',
        location: _locationController.text,
        education: _educationController.text,
        jobTitle: _jobTitleController.text,
        annualIncome: _incomeController.text,
        about: _aboutController.text,
      );

      final success = await _controller.saveProfile(profile, _matrimonyPhoto);
      if (success) {
        widget.onComplete();
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _heightController.dispose();
    _locationController.dispose();
    _educationController.dispose();
    _jobTitleController.dispose();
    _incomeController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8),
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
      body: Obx(() => Stack(
        children: [
          Column(
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
          if (_controller.isLoading.value)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.deepPink),
              ),
            ),
        ],
      )),
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
              Expanded(child: _buildTextField(AppStrings.mobileReq, _mobileController, keyboardType: TextInputType.phone)),
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
            backgroundColor: const Color(0xFFB01D53),
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
          AppText("Date of Birth", fontWeight: FontWeight.bold, fontSize: 16),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(AppStrings.day, _dayController, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(AppStrings.month, _monthController, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(AppStrings.year, _yearController, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 16),
          _buildGenderSelection(),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.heightReq, _heightController),
          const SizedBox(height: 16),
          _buildDropdownField(AppStrings.maritalStatusReq, _maritalStatusOptions, (val) => setState(() => _selectedMaritalStatus = val), _selectedMaritalStatus),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.currentLocationReq, _locationController),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.highestEducationReq, _educationController),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.jobTitleReq, _jobTitleController),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.annualIncomeReq, _incomeController),
          const SizedBox(height: 16),
          _buildTextField("About Myself", _aboutController, maxLines: 3),
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

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText("Gender", fontWeight: FontWeight.bold, fontSize: 16),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderChip("Female"),
            const SizedBox(width: 12),
            _buildGenderChip("Male"),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(String gender) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepPink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
        child: AppText(
          gender,
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
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
                  setState(() => _matrimonyPhoto = XFile(file.path));
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
                          image: FileImage(File(_matrimonyPhoto!.path)),
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
            onTap: (){
              Get.to(() => MatrimonySection());
            },
           // onTap: _nextStep,
            backgroundColor: const Color(0xFFB01D53),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, Function(String?) onChanged, String? selectedValue) {
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
          hint: AppText(label, color: Colors.grey, fontSize: 14),
          value: selectedValue,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option, style: GoogleFonts.inter(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
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

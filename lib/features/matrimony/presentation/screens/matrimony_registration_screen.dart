import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:astro_user/core/utils/image_picker_helper.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_button.dart';
import 'package:astro_user/features/matrimony/presentation/controllers/matrimony_controller.dart';
import 'package:astro_user/features/matrimony/data/models/matrimony_profile_model.dart';
import 'package:astro_user/features/matrimony/presentation/widgets/matrimony_section.dart';
import 'matrimony_profile_screen.dart';
import 'package:flutter/services.dart';
import 'matrimony_screen.dart';
import 'package:astro_user/features/profile/presentation/controllers/profile_controller.dart';

class MatrimonyRegistrationScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final MatrimonyProfileModel? existingProfile; // For edit mode
  final bool isEditMode;
  
  const MatrimonyRegistrationScreen({
    super.key, 
    required this.onComplete,
    this.existingProfile,
    this.isEditMode = false,
  });

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
  
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();
  
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
  
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _drivingLicenceController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  
  bool _isPanSelected = false;
  bool _isDrivingLicenceSelected = false;
  bool _isAadhaarSelected = false;
  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing data
    if (widget.isEditMode && widget.existingProfile != null) {
      _populateFieldsForEdit(widget.existingProfile!);
    }
  }

  void _populateFieldsForEdit(MatrimonyProfileModel profile) {
    _selectedProfileFor = profile.createdFor;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _emailController.text = profile.email;
    _mobileController.text = profile.phone;
    
    // Parse date of birth
    if (profile.dateOfBirth.isNotEmpty) {
      try {
        final dob = DateTime.parse(profile.dateOfBirth);
        _dayController.text = dob.day.toString().padLeft(2, '0');
        _monthController.text = dob.month.toString().padLeft(2, '0');
        _yearController.text = dob.year.toString();
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    
    _selectedGender = profile.gender;
    _heightController.text = profile.height;
    _selectedMaritalStatus = profile.maritalStatus;
    _locationController.text = profile.location;
    _educationController.text = profile.education;
    _jobTitleController.text = profile.jobTitle;
    _incomeController.text = profile.annualIncome;
    _aboutController.text = profile.about;
    
    // Document details
    if (profile.panCardNumber != null && profile.panCardNumber!.isNotEmpty) {
      _panController.text = profile.panCardNumber!;
      _isPanSelected = true;
    }
    if (profile.drivingLicenceNumber != null && profile.drivingLicenceNumber!.isNotEmpty) {
      _drivingLicenceController.text = profile.drivingLicenceNumber!;
      _isDrivingLicenceSelected = true;
    }
    if (profile.aadhaarCardNumber != null && profile.aadhaarCardNumber!.isNotEmpty) {
      _aadhaarController.text = profile.aadhaarCardNumber!;
      _isAadhaarSelected = true;
    }
    
    setState(() {});
  }

  final List<String> _profileForOptions = [
    AppStrings.myself, AppStrings.mySon, AppStrings.myDaughter, 
    AppStrings.myBrother, AppStrings.mySister, AppStrings.myFriend, 
    AppStrings.myRelative
  ];

  final List<String> _maritalStatusOptions = [
    'Never married', 'Divorced', 'Widowed', 'Awaiting Divorce', 'Annulled'
  ];

  bool _validateCurrentStep() {
    setState(() {
      _errors.clear();
    });
    bool isValid = true;
    
    if (_currentStep == 0) {
      if (_selectedProfileFor == null) {
        _errors['profileFor'] = "Please select who you are creating the profile for";
        isValid = false;
      }
      if (_firstNameController.text.isEmpty) {
        _errors['firstName'] = "First name is required";
        isValid = false;
      }
      if (_lastNameController.text.isEmpty) {
        _errors['lastName'] = "Last name is required";
        isValid = false;
      }
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        _errors['email'] = "Please enter a valid email address";
        isValid = false;
      }
      if (_mobileController.text.isEmpty || _mobileController.text.length < 10) {
        _errors['mobile'] = "Please enter a valid mobile number";
        isValid = false;
      }
    } else if (_currentStep == 1) {
      if (_dayController.text.isEmpty || _monthController.text.isEmpty || _yearController.text.isEmpty) {
        _errors['dob'] = "Please enter complete date of birth";
        isValid = false;
      }
      if (_heightController.text.isEmpty) {
        _errors['height'] = "Please enter height";
        isValid = false;
      }
      if (_selectedMaritalStatus == null) {
        _errors['maritalStatus'] = "Please select marital status";
        isValid = false;
      }
      if (_locationController.text.isEmpty) {
        _errors['location'] = "Please enter current location";
        isValid = false;
      }
      if (_educationController.text.isEmpty) {
        _errors['education'] = "Please enter highest education";
        isValid = false;
      }
      if (_jobTitleController.text.isEmpty) {
        _errors['jobTitle'] = "Please enter job title";
        isValid = false;
      }
      if (_incomeController.text.isEmpty) {
        _errors['income'] = "Please enter annual income";
        isValid = false;
      }
    } else if (_currentStep == 2) {
      bool isDocSelected = _isPanSelected || _isDrivingLicenceSelected || _isAadhaarSelected;
      if (!isDocSelected) {
        _errors['documents'] = "Please select and provide at least one identity document";
        isValid = false;
      }
      if (_isPanSelected) {
        if (_panController.text.isEmpty) {
          _errors['pan'] = "Please enter PAN number";
          isValid = false;
        } else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(_panController.text.toUpperCase())) {
          _errors['pan'] = "Invalid PAN format (e.g. ABCDE1234F)";
          isValid = false;
        }
      }
      if (_isDrivingLicenceSelected) {
        if (_drivingLicenceController.text.isEmpty) {
          _errors['driving'] = "Please enter Driving Licence number";
          isValid = false;
        } else if (_drivingLicenceController.text.length < 10) {
          _errors['driving'] = "Invalid Driving Licence number";
          isValid = false;
        }
      }
      if (_isAadhaarSelected) {
        if (_aadhaarController.text.isEmpty) {
          _errors['aadhaar'] = "Please enter Aadhaar number";
          isValid = false;
        } else if (!RegExp(r'^[0-9]{12}$').hasMatch(_aadhaarController.text)) {
          _errors['aadhaar'] = "Invalid Aadhaar format (12 digits)";
          isValid = false;
        }
      }
    } else if (_currentStep == 3) {
      if (_matrimonyPhoto == null) {
        _errors['photo'] = "Please upload a profile photo";
        isValid = false;
      }
    }
    
    if (!isValid) {
      setState(() {});
      return false;
    }
    return true;
  }

  void _nextStep() async {
    if (!_validateCurrentStep()) return;

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final Submit or Update
      final dob = "${_yearController.text}-${_monthController.text.padLeft(2, '0')}-${_dayController.text.padLeft(2, '0')}";
      
      final profile = MatrimonyProfileModel(
        createdFor: _selectedProfileFor ?? 'Myself',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: "$_countryCode${_mobileController.text}",
        dateOfBirth: dob,
        gender: _selectedGender,
        height: _heightController.text,
        maritalStatus: _selectedMaritalStatus ?? 'Never married',
        location: _locationController.text,
        education: _educationController.text,
        jobTitle: _jobTitleController.text,
        annualIncome: _incomeController.text,
        about: _aboutController.text,
        panCardNumber: _isPanSelected ? _panController.text : null,
        drivingLicenceNumber: _isDrivingLicenceSelected ? _drivingLicenceController.text : null,
        aadhaarCardNumber: _isAadhaarSelected ? _aadhaarController.text : null,
      );

      bool success;
      if (widget.isEditMode) {
        // Update existing profile
        success = await _controller.updateProfile(profile, _matrimonyPhoto);
      } else {
        // Create new profile
        success = await _controller.saveProfile(profile, _matrimonyPhoto);
        if (success) {
          // Refresh profile if controller exists
          if (Get.isRegistered<ProfileController>()) {
            final profileController = Get.find<ProfileController>();
            await profileController.refreshProfile();
          }
          
          // Set isRegistered to true after successful registration
          _controller.setRegistered(true);
        }
      }
      
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
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    _heightController.dispose();
    _locationController.dispose();
    _educationController.dispose();
    _jobTitleController.dispose();
    _incomeController.dispose();
    _aboutController.dispose();
    _panController.dispose();
    _drivingLicenceController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentStep > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: const [],
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
            color: Colors.black,
          ),
          const SizedBox(height: 24),
          AppText(
            AppStrings.creatingProfileFor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _profileForOptions.map((option) {
              final isSelected = _selectedProfileFor == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProfileFor = option;
                    _errors.remove('profileFor');
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.deepPink : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _errors['profileFor'] != null ? Colors.red : (isSelected ? AppColors.deepPink : Colors.black.withOpacity(0.1)),
                    ),
                  ),
                  child: AppText(
                    option,
                    color: isSelected ? AppColors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          if (_errors['profileFor'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: AppText(_errors['profileFor']!, color: Colors.red, fontSize: 12),
            ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTextField(AppStrings.firstNameReq, _firstNameController, errorKey: 'firstName')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(AppStrings.lastNameReq, _lastNameController, errorKey: 'lastName')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.emailReq, _emailController, errorKey: 'email'),
          const SizedBox(height: 16),
          _buildTextField(
            AppStrings.mobileReq,
            _mobileController,
            keyboardType: TextInputType.phone,
            errorKey: 'mobile',
            inputFormatters: [LengthLimitingTextInputFormatter(10)],
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.only(left: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _countryCode,
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.arrow_drop_down, color: Colors.black54, size: 20),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  onChanged: (val) => setState(() => _countryCode = val!),
                  items: ["+91", "+1", "+44"].map((code) {
                    return DropdownMenuItem(value: code, child: Text(code));
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            AppStrings.matchesContactInfo,
            fontSize: 12,
            color: Colors.black54,
          ),
         // const SizedBox(height: 32),
          //_buildSafetyBanner(),
          const SizedBox(height: 40),
          CustomButton(
            text: AppStrings.next,
            onTap: _nextStep,
            backgroundColor: AppColors.primaryColor,
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
            color: Colors.black,
          ),
          const SizedBox(height: 32),
          AppText("Date of Birth", fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(AppStrings.day, _dayController, keyboardType: TextInputType.number, errorKey: 'dob', showErrorText: false, focusNode: _dayFocus, inputFormatters: [LengthLimitingTextInputFormatter(2)], onChangedCustom: (val) {
                  if (val.isNotEmpty) {
                    final intVal = int.tryParse(val);
                    if (intVal != null && intVal > 31) {
                      _dayController.text = '31';
                      _dayController.selection = TextSelection.fromPosition(TextPosition(offset: _dayController.text.length));
                    }
                    if (val.length == 2 || (intVal != null && intVal > 3)) {
                      FocusScope.of(context).requestFocus(_monthFocus);
                    }
                  }
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(AppStrings.month, _monthController, keyboardType: TextInputType.number, errorKey: 'dob', showErrorText: false, focusNode: _monthFocus, inputFormatters: [LengthLimitingTextInputFormatter(2)], onChangedCustom: (val) {
                  if (val.isNotEmpty) {
                    final intVal = int.tryParse(val);
                    if (intVal != null && intVal > 12) {
                      _monthController.text = '12';
                      _monthController.selection = TextSelection.fromPosition(TextPosition(offset: _monthController.text.length));
                    }
                    if (val.length == 2 || (intVal != null && intVal > 1)) {
                      FocusScope.of(context).requestFocus(_yearFocus);
                    }
                  }
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(AppStrings.year, _yearController, keyboardType: TextInputType.number, errorKey: 'dob', showErrorText: false, focusNode: _yearFocus, inputFormatters: [LengthLimitingTextInputFormatter(4)]),
              ),
            ],
          ),
          if (_errors['dob'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: AppText(_errors['dob']!, color: Colors.red, fontSize: 12),
            ),
          const SizedBox(height: 16),
          _buildGenderSelection(),
          const SizedBox(height: 16),
          _buildTextField(
            AppStrings.heightReq, 
            _heightController, 
            errorKey: 'height',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            onChangedCustom: (val) {
              if (val.isEmpty) return;
              String digits = val.replaceAll(RegExp(r'[^0-9]'), '');
              if (digits.isEmpty) {
                _heightController.clear();
                return;
              }
              int feet = int.parse(digits.substring(0, 1));
              if (feet > 8) feet = 8;
              if (feet < 3 && digits.length > 1) { } // Optional: could limit minimum feet too
              
              String inchesStr = '';
              if (digits.length > 1) {
                inchesStr = digits.substring(1);
                if (inchesStr.length > 2) inchesStr = inchesStr.substring(0, 2);
                int inches = int.parse(inchesStr);
                if (inches > 11) {
                  inchesStr = '11';
                }
              }

              String formatted = feet.toString();
              if (digits.length > 1 || val.contains('.')) {
                formatted = '$feet.';
                if (inchesStr.isNotEmpty) formatted += inchesStr;
              }

              if (val != formatted) {
                _heightController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(AppStrings.maritalStatusReq, _maritalStatusOptions, (val) => setState(() => _selectedMaritalStatus = val), _selectedMaritalStatus, errorKey: 'maritalStatus'),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.currentLocationReq, _locationController, errorKey: 'location'),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.highestEducationReq, _educationController, errorKey: 'education'),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.jobTitleReq, _jobTitleController, errorKey: 'jobTitle'),
          const SizedBox(height: 16),
          _buildTextField(AppStrings.annualIncomeReq, _incomeController, errorKey: 'income'),
          const SizedBox(height: 16),
          _buildTextField("About Myself", _aboutController, maxLines: 3),
          const SizedBox(height: 40),
          CustomButton(
            text: AppStrings.next,
            onTap: _nextStep,
            backgroundColor: AppColors.primaryColor,
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
        AppText("Gender", fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
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
          color: isSelected ? AppColors.deepPink : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.black.withOpacity(0.1)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         /* Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              AppText(
                AppStrings.verifyYourProfile,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),*/
          // AppText(
          //   AppStrings.verificationMsg,
          //   fontSize: 14,
          //   color: Colors.black54,
          // ),
           const SizedBox(height: 20),
          Row(
            children: [
              _buildVerificationChip(AppStrings.panCard, _isPanSelected, () {
                setState(() {
                  _isPanSelected = !_isPanSelected;
                  _errors.remove('documents');
                  if (!_isPanSelected) _errors.remove('pan');
                });
              }),
              const SizedBox(width: 12),
              _buildVerificationChip(AppStrings.drivingLicence, _isDrivingLicenceSelected, () {
                setState(() {
                  _isDrivingLicenceSelected = !_isDrivingLicenceSelected;
                  _errors.remove('documents');
                  if (!_isDrivingLicenceSelected) _errors.remove('driving');
                });
              }),
            ],
          ),
          const SizedBox(height: 12),
          _buildVerificationChip(AppStrings.aadhaarCard, _isAadhaarSelected, () {
            setState(() {
              _isAadhaarSelected = !_isAadhaarSelected;
              _errors.remove('documents');
              if (!_isAadhaarSelected) _errors.remove('aadhaar');
            });
          }),
          if (_errors['documents'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: AppText(_errors['documents']!, color: Colors.red, fontSize: 12),
            ),
          const SizedBox(height: 32),
          if (_isPanSelected) Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildTextField(AppStrings.panNumber, _panController, errorKey: 'pan', helperText: "Example: ABCDE1234F")),
          if (_isDrivingLicenceSelected) Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildTextField(AppStrings.drivingLicenceNumber, _drivingLicenceController, errorKey: 'driving', helperText: "Example: DL-1420110012345")),
          if (_isAadhaarSelected) Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildTextField(AppStrings.aadhaarCardNumber, _aadhaarController, errorKey: 'aadhaar', keyboardType: TextInputType.number, inputFormatters: [LengthLimitingTextInputFormatter(12)], helperText: "Example: 123456789012")),
          const SizedBox(height: 32),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: Colors.black54),
                const SizedBox(width: 8),
                AppText(AppStrings.infoSafePrivate, fontSize: 12, color: Colors.black54),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: AppStrings.verifyNow,
            onTap: _nextStep,
            backgroundColor: AppColors.primaryColor,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              AppStrings.profilesWithPhotosMsg,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
          const SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: () async {
                final file = await ImagePickerHelper.showImagePickerSheet(context);
                if (file != null) {
                  setState(() {
                    _matrimonyPhoto = XFile(file.path);
                    _errors.remove('photo');
                  });
                }
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: _errors['photo'] != null ? Colors.red : Colors.black.withOpacity(0.1)),
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
                          Icon(Icons.person, size: 60, color: _errors['photo'] != null ? Colors.red.withOpacity(0.5) : Colors.black.withOpacity(0.2)),
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
          if (_errors['photo'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(child: AppText(_errors['photo']!, color: Colors.red, fontSize: 12)),
            ),
          const SizedBox(height: 16),
          Center(child: AppText(AppStrings.addPhoto, fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
          const SizedBox(height: 32),
          Center(child: AppText(AppStrings.photosSafeMsg, color: Colors.black54, fontSize: 14)),
          Center(child: AppText(AppStrings.photoPrivacyMsg, color: Colors.black45, fontSize: 12)),
          const SizedBox(height: 32),
          CustomButton(
            text: widget.isEditMode ? 'Update Profile' : AppStrings.uploadPhotos,
            onTap: _nextStep,
            backgroundColor: AppColors.primaryColor,
            textColor: Colors.white,
          ),
        ],
      ),
      )
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1, String? errorKey, Widget? prefixIcon, bool showErrorText = true, String? helperText, List<TextInputFormatter>? inputFormatters, Function(String)? onChangedCustom, FocusNode? focusNode}) {
    final errorText = errorKey != null ? _errors[errorKey] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.red : Colors.black.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.black),
            onChanged: (val) {
              if (onChangedCustom != null) onChangedCustom(val);
              if (errorKey != null && _errors.containsKey(errorKey)) {
                setState(() => _errors.remove(errorKey));
              }
            },
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              labelText: label,
              labelStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        if (helperText != null && errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: AppText(helperText, color: Colors.black38, fontSize: 11),
          ),
        if (showErrorText && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: AppText(errorText, color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, Function(String?) onChanged, String? selectedValue, {String? errorKey}) {
    final errorText = errorKey != null ? _errors[errorKey] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.red : Colors.black.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: Colors.white,
              hint: AppText(label, color: Colors.black54, fontSize: 14),
              value: selectedValue,
              style: const TextStyle(color: Colors.black),
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option, style: GoogleFonts.inter(fontSize: 14, color: Colors.black)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  onChanged(val);
                  if (errorKey != null && _errors.containsKey(errorKey)) {
                    setState(() => _errors.remove(errorKey));
                  }
                }
              },
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: AppText(errorText, color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildVerificationChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
        child: AppText(
          label,
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
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
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, color: Colors.black87, size: 16),
              const SizedBox(width: 8),
              AppText(AppStrings.safetyFirst, fontWeight: FontWeight.w700, color: Colors.black87),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            AppStrings.sangamSafetyMsg,
            fontSize: 12,
            textAlign: TextAlign.center,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:io';
import 'package:astro_user/core/utils/image_picker_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_button.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/features/auth/presentation/controllers/auth_controller.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:image_picker/image_picker.dart';
import 'package:astro_user/features/profile/presentation/controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController _authController = Get.find<AuthController>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _placeController;
  
  String? _selectedGender;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final user = _authController.currentUser.value;
    
    _nameController = TextEditingController(text: user?.name ?? AppStrings.guest);
    _phoneController = TextEditingController(text: user?.mobile ?? "+91 9876543210");
    _placeController = TextEditingController(text: user?.placeOfBirth ?? "New Delhi, India"); 
    
    _selectedGender = _parseGender(user?.gender);
    
    if (user?.dateOfBirth != null && user!.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(user.dateOfBirth!).toLocal();
      } catch (_) {
        _selectedDate = DateTime(1995, 8, 15);
      }
    } else {
      _selectedDate = DateTime(1995, 8, 15);
    }
    
    if (user?.timeOfBirth != null && user!.timeOfBirth!.isNotEmpty) {
      final parts = user.timeOfBirth!.split(':');
      if (parts.length >= 2) {
        _selectedTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 10, minute: int.tryParse(parts[1]) ?? 30);
      } else {
        _selectedTime = const TimeOfDay(hour: 10, minute: 30);
      }
    } else {
      _selectedTime = const TimeOfDay(hour: 10, minute: 30);
    }

    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = _authController.currentUser.value;
    if (user != null) {
      final profileController = Get.find<ProfileController>();
      final freshUser = await profileController.getProfileData(user.id);
      if (freshUser != null) {
        _authController.currentUser.value = freshUser;
        if (mounted) {
          setState(() {
            _nameController.text = freshUser.name.isNotEmpty ? freshUser.name : _nameController.text;
            _phoneController.text = freshUser.mobile.isNotEmpty ? freshUser.mobile : _phoneController.text;
            _placeController.text = (freshUser.placeOfBirth != null && freshUser.placeOfBirth!.isNotEmpty) ? freshUser.placeOfBirth! : _placeController.text;
            _selectedGender = _parseGender(freshUser.gender);
            
            if (freshUser.dateOfBirth != null && freshUser.dateOfBirth!.isNotEmpty) {
              try {
                _selectedDate = DateTime.parse(freshUser.dateOfBirth!).toLocal();
              } catch (_) {}
            }
            if (freshUser.timeOfBirth != null && freshUser.timeOfBirth!.isNotEmpty) {
              final parts = freshUser.timeOfBirth!.split(':');
              if (parts.length >= 2) {
                _selectedTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 10, minute: int.tryParse(parts[1]) ?? 30);
              }
            }
          });
        }
      }
    }
  }

  String _parseGender(String? genderValue) {
    if (genderValue == null || genderValue.isEmpty) return AppStrings.male;
    final lower = genderValue.toLowerCase();
    if (lower == 'male') return AppStrings.male;
    if (lower == 'female') return AppStrings.female;
    if (lower == 'other' || lower == 'others') return AppStrings.other;
    return AppStrings.male; // fallback
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime tempDate = _selectedDate ?? now.subtract(const Duration(days: 365 * 20));
    if (tempDate.isAfter(now)) {
      tempDate = now;
    }
    final result = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final formattedHeader = "${_getDayName(tempDate.weekday)}, ${_getMonthShort(tempDate.month)} ${tempDate.day}, ${tempDate.year}";
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Text(
                        formattedHeader,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepPink,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.deepPink, thickness: 1.5),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 180,
                      child: Theme(
                        data: ThemeData.light().copyWith(
                          cupertinoOverrideTheme: const CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: tempDate,
                          minimumDate: DateTime(1900),
                          maximumDate: DateTime.now(),
                          onDateTimeChanged: (DateTime newDate) {
                            setModalState(() {
                              tempDate = newDate;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Colors.black12),
                    InkWell(
                      onTap: () {
                        if (tempDate.isAfter(DateTime.now())) {
                          tempDate = DateTime.now();
                        }
                        Navigator.of(context).pop(tempDate);
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Done'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    final bool isSelectedDateToday = _selectedDate != null &&
        _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;

    DateTime tempTime = DateTime(
      _selectedDate?.year ?? now.year,
      _selectedDate?.month ?? now.month,
      _selectedDate?.day ?? now.day,
      _selectedTime?.hour ?? now.hour,
      _selectedTime?.minute ?? now.minute,
    );

    if (isSelectedDateToday && tempTime.isAfter(now)) {
      tempTime = now;
    }

    final result = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final hour = tempTime.hour == 0 ? 12 : (tempTime.hour > 12 ? tempTime.hour - 12 : tempTime.hour);
            final minute = tempTime.minute.toString().padLeft(2, '0');
            final period = tempTime.hour >= 12 ? 'PM' : 'AM';
            final formattedHeader = "$hour:$minute $period";
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Text(
                        formattedHeader,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepPink,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.deepPink, thickness: 1.5),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 180,
                      child: Theme(
                        data: ThemeData.light().copyWith(
                          cupertinoOverrideTheme: const CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: tempTime,
                          maximumDate: isSelectedDateToday ? DateTime.now() : null,
                          onDateTimeChanged: (DateTime newTime) {
                            setModalState(() {
                              if (isSelectedDateToday && newTime.isAfter(DateTime.now())) {
                                tempTime = DateTime.now();
                              } else {
                                tempTime = newTime;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Colors.black12),
                    InkWell(
                      onTap: () {
                        final currentNow = DateTime.now();
                        if (isSelectedDateToday && tempTime.isAfter(currentNow)) {
                          tempTime = currentNow;
                        }
                        Navigator.of(context).pop(tempTime);
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Done'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() => _selectedTime = TimeOfDay(hour: result.hour, minute: result.minute));
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  String _getMonthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.editProfile,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 30),
            _buildTextField(AppStrings.nameLabel, _nameController, Iconsax.user_copy),
            const SizedBox(height: 20),
            _buildTextField(AppStrings.mobileNumber, _phoneController, Iconsax.call_copy, readOnly: true),
            const SizedBox(height: 20),
            _buildDropdown(AppStrings.gender, [AppStrings.male, AppStrings.female, AppStrings.other], _selectedGender, (val) {
              setState(() => _selectedGender = val);
            }),
            const SizedBox(height: 20),
             _buildReadOnlyField(
              label: AppStrings.dobLabel,
              value: _selectedDate != null
                  ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                  : AppStrings.selectDate,
              icon: Iconsax.calendar_1_copy,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            _buildReadOnlyField(
              label: AppStrings.tobLabel,
              value: _selectedTime != null
                  ? _selectedTime!.format(context)
                  : AppStrings.selectTime,
              icon: Iconsax.clock_copy,
              onTap: () => _selectTime(context),
            ),
             const SizedBox(height: 20),
            _buildTextField(AppStrings.pobLabel, _placeController, Iconsax.location_copy),

            const SizedBox(height: 40),
            Obx(() {
              final profileController = Get.find<ProfileController>();
              return CustomButton(
                text: AppStrings.saveChanges,
                isLoading: profileController.isLoading.value,
                onTap: () async {
                  final genderLower = _selectedGender?.toLowerCase() ?? 'male';
                  final dobString = _selectedDate != null
                      ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                      : '';
                  final tobString = _selectedTime != null
                      ? "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}"
                      : '';

                  final data = {
                    "name": _nameController.text.trim(),
                    "phone": _phoneController.text.trim(),
                    "gender": genderLower,
                    "date_of_birth": dobString,
                    "time_of_birth": tobString,
                    "place_of_birth": _placeController.text.trim(),
                    "languages": ["English"],
                  };

                  final success = await profileController.updateProfileInApp(data);
                  if (success) Get.back();
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Obx(() {
              final user = _authController.currentUser.value;
              return Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage("${AppUrls.baseImageUrl}${user.profilePhoto!}"),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/300?u=a042581f4e29026704d'),
                              fit: BoxFit.cover,
                            ),
                  border: Border.all(color: AppColors.deepPink.withOpacity(0.2), width: 1),
                ),
              );
            }),
          ),
          GestureDetector(
            onTap: () async {
              final file = await ImagePickerHelper.showImagePickerSheet(context);
              if (file != null) {
                setState(() => _imageFile = file);
                final profileController = Get.find<ProfileController>();
                await profileController.updateProfilePhoto(XFile(file.path));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.deepPink,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Obx(() {
                final profileController = Get.find<ProfileController>();
                if (profileController.isLoading.value) {
                  return const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                }
                return const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]!),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
             color: readOnly ? Colors.grey[100] : Colors.white,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]!),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[500], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    value,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]!),
         const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.black54),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(Iconsax.user_copy, color: Colors.grey[500], size: 20),
                      const SizedBox(width: 12),
                      AppText(value, fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

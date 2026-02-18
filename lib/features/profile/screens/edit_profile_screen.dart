import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:io';
import '../../../core/utils/image_picker_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../auth/controllers/auth_controller.dart';

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
    final user = _authController.currentUser.value;
    
    _nameController = TextEditingController(text: user?.name ?? AppStrings.guest);
    _phoneController = TextEditingController(text: user?.mobile ?? "+91 9876543210");
    _placeController = TextEditingController(text: "New Delhi, India"); // Dummy default
    
    // Initialize other fields if available in user model, else defaults
    _selectedGender = AppStrings.male; 
    _selectedDate = DateTime(1995, 8, 15);
    _selectedTime = const TimeOfDay(hour: 10, minute: 30);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepPink,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepPink,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
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
            CustomButton(
              text: AppStrings.saveChanges,
              onTap: () {
                // Simulate save
                Get.back();
                Get.snackbar(AppStrings.success, AppStrings.profileUpdated, 
                  backgroundColor: Colors.green.withOpacity(0.1),
                  colorText: Colors.green,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(20),
                );
              },
            ),
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
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: _imageFile != null
                    ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/300?u=a042581f4e29026704d'),
                        fit: BoxFit.cover,
                      ),
                border: Border.all(color: AppColors.deepPink.withOpacity(0.2), width: 1),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final file = await ImagePickerHelper.showImagePickerSheet(context);
              if (file != null) {
                setState(() => _imageFile = file);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.deepPink,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
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

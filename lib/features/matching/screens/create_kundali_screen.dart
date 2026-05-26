import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart' as sax;

class CreateKundaliScreen extends StatefulWidget {
  const CreateKundaliScreen({super.key});

  @override
  State<CreateKundaliScreen> createState() => _CreateKundaliScreenState();
}

class _CreateKundaliScreenState extends State<CreateKundaliScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _tobController = TextEditingController();
  final TextEditingController _pobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2D3142),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          'Create Kundali',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D3142),
        ),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top:0),
                child: _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField("Name", "Please enter your name", sax.Iconsax.user_copy, controller: _nameController),
                      _buildField("Gender", "Select gender", sax.Iconsax.user_tag_copy, controller: _genderController, isPicker: true, onTap: () => _showGenderSelection(_genderController)),
                      _buildField("Birth Date", "Select date", sax.Iconsax.calendar_copy, controller: _dobController, isPicker: true, onTap: () => _selectDate(_dobController)),
                      _buildField("Birth Time", "Select time", sax.Iconsax.clock_copy, controller: _tobController, isPicker: true, onTap: () => _selectTime(_tobController)),
                      _buildField("Birth Place", "Enter birth place", sax.Iconsax.location_copy, controller: _pobController),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: GestureDetector(
                //onTap: () => Get.to(() => KundliScreen()),
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: AppText(
                          "Generate Horoscope",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      // Positioned(
                      //   right: 20,
                      //   top: 0,
                      //   bottom: 0,
                      //   child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.5), size: 14),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }


  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day.toString().padLeft(2, '0')} ${[
          "January", "February", "March", "April", "May", "June",
          "July", "August", "September", "October", "November", "December"
        ][picked.month - 1]} ${picked.year}";
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final period = picked.period == DayPeriod.am ? "AM" : "PM";
        controller.text = "${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period";
      });
    }
  }

  void _showGenderSelection(TextEditingController controller) {
    _showSelectionSheet("Select Gender", ["Male", "Female", "Other"], (val) {
      setState(() => controller.text = val);
    });
  }


  void _showSelectionSheet(String title, List<String> items, Function(String) onSelect) {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final List<String> filteredItems = searchQuery.isEmpty
              ? items
              : items.where((item) => item.toLowerCase().contains(searchQuery.toLowerCase())).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      AppText(title, fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textColorPrimary),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.softPink.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
                    ),
                    child: TextField(
                      onChanged: (val) => setSheetState(() => searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: AppColors.primaryColor, size: 20),
                        title: AppText(filteredItems[index], fontSize: 16),
                        onTap: () {
                          onSelect(filteredItems[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildSectionCard({String? title, IconData? titleIcon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (titleIcon != null) ...[
                  Icon(titleIcon, size: 20, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                ],
                Text(title, style: TextStyle(fontSize: 16, color: AppColors.textColorPrimary.withOpacity(0.8))),
              ],
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: AppColors.primaryColor.withOpacity(0.05)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, {required TextEditingController controller, bool isPicker = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 8),
          child: AppText(label, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary.withOpacity(0.6)),
        ),
        GestureDetector(
          onTap: isPicker ? (onTap ?? () {}) : null,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.fieldBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primaryColor.withOpacity(0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    cursorColor: AppColors.primaryColor,
                    readOnly: isPicker,
                    enabled: !isPicker,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textColorPrimary),
                    onTap: isPicker ? (onTap ?? () {}) : null,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: AppColors.textColorHint.withOpacity(0.6), fontSize: 16),
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (isPicker) Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primaryColor.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

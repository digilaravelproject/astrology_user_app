import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/route_helper.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/picker_tile.dart';
import '../../../core/constants/app_strings.dart';

class BirthDetailsScreen extends StatefulWidget {
  const BirthDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends State<BirthDetailsScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _placeController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF8F00),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E1A47),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF8F00),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E1A47),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackgroundPattern(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF9933).withOpacity(0.05),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF2E1A47)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    AppStrings.birthDetailsTitle,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E1A47),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.birthDetailsSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // DOB Input
                  _buildInputLabel(AppStrings.dateOfBirth),
                  _buildReadOnlyField(
                    hint: selectedDate != null
                        ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                        : AppStrings.selectDate,
                    icon: Icons.calendar_today_rounded,
                    onTap: () => _selectDate(context),
                  ),

                  const SizedBox(height: 25),

                  // TOB Input
                  _buildInputLabel(AppStrings.timeOfBirth),
                  _buildReadOnlyField(
                    hint: selectedTime != null
                        ? selectedTime!.format(context)
                        : AppStrings.selectTime,
                    icon: Icons.access_time_rounded,
                    onTap: () => _selectTime(context),
                  ),

                  const SizedBox(height: 25),

                  // POB Input
                  _buildInputLabel(AppStrings.placeOfBirth),
                  _buildPlaceField(),

                  const SizedBox(height: 60),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GradientButton(
                      text: AppStrings.finish,
                      onTap: () => Get.toNamed(RouteHelper.getLanguageSelectionRoute()),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2E1A47),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String hint, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8F00).withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF2E1A47), fontWeight: FontWeight.w600, fontSize: 16),
            prefixIcon: Icon(icon, color: const Color(0xFFFF8F00)),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8F00).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _placeController,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: AppStrings.enterCity,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.2)),
          prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFFFF8F00)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFFF8F00), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(BuildContext context) {
    final iconColor = const Color(0xFFFF9933).withOpacity(0.06);

    return Stack(
      children: [
        Positioned(top: 100, left: 40, child: Icon(Icons.brightness_5_outlined, size: 35, color: iconColor)),
        Positioned(top: 250, right: 60, child: Icon(Icons.nightlight_round_outlined, size: 28, color: iconColor)),
        Positioned(top: 500, left: 80, child: Icon(Icons.auto_awesome_outlined, size: 32, color: iconColor)),
        Positioned(bottom: 200, right: 40, child: Icon(Icons.star_border_rounded, size: 40, color: iconColor)),
        Positioned(bottom: 350, left: 30, child: Icon(Icons.wb_twilight_rounded, size: 24, color: iconColor)),
        Positioned(top: 150, right: 120, child: Icon(Icons.flare_rounded, size: 20, color: iconColor)),
        Positioned(bottom: 100, left: 150, child: Icon(Icons.blur_on_rounded, size: 45, color: iconColor)),
      ],
    );
  }
}

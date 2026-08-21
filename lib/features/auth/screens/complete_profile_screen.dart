import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/route_helper.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/gender_selection_card.dart';
import '../controllers/auth_controller.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  String selectedGender = "";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late TextEditingController _placeController;

  @override
  void initState() {
    super.initState();
    _placeController = TextEditingController();
  }

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime tempDate = selectedDate ?? now.subtract(const Duration(days: 365 * 20));
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
                        child: const Text(
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
      setState(() => selectedDate = result);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    final bool isSelectedDateToday = selectedDate != null &&
        selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;

    DateTime tempTime = DateTime(
      selectedDate?.year ?? now.year,
      selectedDate?.month ?? now.month,
      selectedDate?.day ?? now.day,
      selectedTime?.hour ?? now.hour,
      selectedTime?.minute ?? now.minute,
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
                        child: const Text(
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
      setState(() => selectedTime = TimeOfDay(hour: result.hour, minute: result.minute));
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
    final authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildHeader(),
              const SizedBox(height: 35),
              
              _buildLabel(AppStrings.fullNameLabel),
              const SizedBox(height: 8),
              _buildTextField(
                controller: authController.nameController,
                hint: AppStrings.nameHint,
                icon: Icons.person_outline_rounded,
              ),
              
              const SizedBox(height: 25),
              
              _buildLabel(AppStrings.genderLabel),
              const SizedBox(height: 10),
              Row(
                children: [
                   Expanded(
                    child: GenderSelectionCard(
                      label: AppStrings.male,
                      icon: Icons.male_rounded,
                      isSelected: selectedGender == "male",
                      onTap: () => setState(() => selectedGender = "male"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GenderSelectionCard(
                      label: AppStrings.female,
                      icon: Icons.female_rounded,
                      isSelected: selectedGender == "female",
                      onTap: () => setState(() => selectedGender = "female"),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              _buildLabel(AppStrings.birthDetailsLabel),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildReadOnlyField(
                      hint: selectedDate != null
                          ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                          : AppStrings.dateOfBirth,
                      icon: Icons.calendar_today_rounded,
                      isFilled: selectedDate != null,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildReadOnlyField(
                      hint: selectedTime != null
                          ? selectedTime!.format(context)
                          : AppStrings.timeOfBirth,
                      icon: Icons.access_time_rounded,
                      isFilled: selectedTime != null,
                      onTap: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _placeController,
                hint: AppStrings.placeOfBirth,
                icon: Icons.location_on_outlined,
              ),
              
              const SizedBox(height: 50),

              CustomButton(
                text: AppStrings.finish,
                onTap: () {
                  Get.toNamed(RouteHelper.getLanguageSelectionRoute());
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: AppColors.primaryColor),
        ),
        const SizedBox(height: 25),
        AppText(
          AppStrings.profileDetails,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 38,
            fontWeight: FontWeight.w400,
            color: AppColors.deepPink,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        AppText(
          AppStrings.tellUsAboutYourself,
          fontSize: 15,
          color: AppColors.textColorSecondary,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    final bool isFilled = controller.text.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isFilled ? AppColors.deepPink : AppColors.borderColor.withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) => setState(() {}),
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 15, fontWeight: FontWeight.w400),
          prefixIcon: Icon(icon, color: isFilled ? AppColors.deepPink : AppColors.black.withOpacity(0.26), size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String hint, required IconData icon, required VoidCallback onTap, bool isFilled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isFilled ? AppColors.deepPink : AppColors.borderColor.withOpacity(0.5),
            width: 1.2,
          ),
        ),
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: isFilled ? AppColors.textColorPrimary : AppColors.black.withOpacity(0.38), 
                fontWeight: isFilled ? FontWeight.w600 : FontWeight.w500, 
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon, 
                color: isFilled ? AppColors.deepPink : AppColors.black.withOpacity(0.26), 
                size: 18,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: AppText(
        text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textColorPrimary.withOpacity(0.8),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textColorSecondary,
        letterSpacing: 0.5,
      ),
    );
  }


}

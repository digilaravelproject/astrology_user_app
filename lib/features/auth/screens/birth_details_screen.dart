import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/route_helper.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/picker_tile.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widgets/location_search_screen.dart';
import '../controllers/auth_controller.dart';

class BirthDetailsScreen extends StatefulWidget {
  const BirthDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends State<BirthDetailsScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double? _latitude;
  double? _longitude;
  final TextEditingController _placeController = TextEditingController();

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
                        child: Text(
                          'Done'.tr,
                          style: const TextStyle(
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
                        child: Text(
                          'Done'.tr,
                          style: const TextStyle(
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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.fieldBackground,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.primaryColor),
                ),
              ),
              const SizedBox(height: 30),
              AppText(
                AppStrings.birthDetailsTitle,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                  color: AppColors.deepPink,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              AppText(
                AppStrings.birthDetailsSubtitle,
                fontSize: 16,
                color: AppColors.black.withOpacity(0.4),
                fontWeight: FontWeight.w400,
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
                child: Obx(() {
                  final authController = Get.find<AuthController>();
                  return CustomButton(
                    text: AppStrings.finish,
                    isLoading: authController.isLoading.value,
                    onTap: () {
                      if (selectedDate == null) {
                        CustomSnackbar.showError('Please select Date of Birth');
                        return;
                      }
                      if (selectedTime == null) {
                        CustomSnackbar.showError('Please select Time of Birth');
                        return;
                      }
                      if (_placeController.text.trim().isEmpty) {
                        CustomSnackbar.showError('Please enter Place of Birth');
                        return;
                      }
                      
                      authController.updateProfile(
                        dob: selectedDate!,
                        tob: selectedTime!,
                        placeOfBirth: _placeController.text.trim(),
                        latitude: _latitude,
                        longitude: _longitude,
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: AppText(
        label,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.deepPink,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildReadOnlyField({required String hint, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textColorPrimary, fontWeight: FontWeight.w600, fontSize: 16),
            prefixIcon: Icon(icon, color: AppColors.deepPink),
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
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context, rootNavigator: true).push<LocationResult>(
          MaterialPageRoute(
            builder: (_) => const LocationSearchScreen(title: "Select Place of Birth"),
            fullscreenDialog: true,
          ),
        );
        if (result != null) {
          setState(() {
            _placeController.text = result.displayName;
            _latitude = result.latitude;
            _longitude = result.longitude;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: _placeController,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: AppStrings.enterCity,
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.2)),
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.deepPink),
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
                borderSide: const BorderSide(color: AppColors.deepPink, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(BuildContext context) {
    final iconColor = AppColors.primaryColor.withOpacity(0.06);

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

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/theme/app_colors.dart';

class KundliMatchingScreen extends StatefulWidget {
  const KundliMatchingScreen({super.key});

  @override
  State<KundliMatchingScreen> createState() => _KundliMatchingScreenState();
}

class _KundliMatchingScreenState extends State<KundliMatchingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Boy's Details
  final TextEditingController _boyNameController = TextEditingController();
  final TextEditingController _boyDateController = TextEditingController();
  final TextEditingController _boyTimeController = TextEditingController();
  final TextEditingController _boyPlaceController = TextEditingController();

  // Girl's Details
  final TextEditingController _girlNameController = TextEditingController();
  final TextEditingController _girlDateController = TextEditingController();
  final TextEditingController _girlTimeController = TextEditingController();
  final TextEditingController _girlPlaceController = TextEditingController();

  bool _saveDetails = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _boyNameController.dispose();
    _boyDateController.dispose();
    _boyTimeController.dispose();
    _boyPlaceController.dispose();
    _girlNameController.dispose();
    _girlDateController.dispose();
    _girlTimeController.dispose();
    _girlPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFD81B60),
              indicatorWeight: 3,
              labelColor: const Color(0xFFD81B60),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              tabs: [Tab(text: 'OPEN KUNDLI'.tr), Tab(text: 'NEW MATCHING'.tr)],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOpenKundliTab(), _buildNewMatchingTab()],
      ),
    );
  }

  Widget _buildOpenKundliTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            "BOY'S DETAILS".tr,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD81B60),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            icon: Icons.person_outline,
            hint: "Boy's Name".tr,
            controller: _boyNameController,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  icon: Icons.calendar_today_outlined,
                  hint: "15-Feb-2026",
                  controller: _boyDateController,
                  onTap: () => _selectDate(context, _boyDateController),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputField(
                  icon: Icons.access_time_outlined,
                  hint: "06:19 PM",
                  controller: _boyTimeController,
                  onTap: () => _selectTime(context, _boyTimeController),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInputField(
            icon: Icons.location_on_outlined,
            hint: "Agra\n(027N09, 078E00 +5.5)",
            controller: _boyPlaceController,
            maxLines: 2,
          ),
          const SizedBox(height: 30),

          AppText(
            "GIRL'S DETAILS".tr,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD81B60),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            icon: Icons.person_outline,
            hint: "Girl's Name",
            controller: _girlNameController,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  icon: Icons.calendar_today_outlined,
                  hint: "15-Feb-2026",
                  controller: _girlDateController,
                  onTap: () => _selectDate(context, _girlDateController),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputField(
                  icon: Icons.access_time_outlined,
                  hint: "06:19 PM",
                  controller: _girlTimeController,
                  onTap: () => _selectTime(context, _girlTimeController),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInputField(
            icon: Icons.location_on_outlined,
            hint: "Agra\n(027N09, 078E00 +5.5)",
            controller: _girlPlaceController,
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          // Save Checkbox
          Row(
            children: [
              Checkbox(
                value: _saveDetails,
                onChanged: (value) {
                  setState(() {
                    _saveDetails = value ?? false;
                  });
                },
                activeColor: const Color(0xFFD81B60),
              ),
              const AppText(
                'Save',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD81B60),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Type or Paste Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFD81B60).withOpacity(0.3),
              ),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    'Type or Paste Birth Details',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD81B60),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.add, color: Color(0xFFD81B60), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Show Match Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Handle show match
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD81B60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const AppText(
                'SHOW MATCH',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNewMatchingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            "BOY'S DETAILS",
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD81B60),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            icon: Icons.person_outline,
            hint: "Boy's Name",
            controller: _boyNameController,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  icon: Icons.calendar_today_outlined,
                  hint: "15-Feb-2026",
                  controller: _boyDateController,
                  onTap: () => _selectDate(context, _boyDateController),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputField(
                  icon: Icons.access_time_outlined,
                  hint: "06:19 PM",
                  controller: _boyTimeController,
                  onTap: () => _selectTime(context, _boyTimeController),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInputField(
            icon: Icons.location_on_outlined,
            hint: "Agra\n(027N09, 078E00 +5.5)",
            controller: _boyPlaceController,
            maxLines: 2,
          ),
          const SizedBox(height: 30),

          const AppText(
            "GIRL'S DETAILS",
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD81B60),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            icon: Icons.person_outline,
            hint: "Girl's Name",
            controller: _girlNameController,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  icon: Icons.calendar_today_outlined,
                  hint: "15-Feb-2026",
                  controller: _girlDateController,
                  onTap: () => _selectDate(context, _girlDateController),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputField(
                  icon: Icons.access_time_outlined,
                  hint: "06:19 PM",
                  controller: _girlTimeController,
                  onTap: () => _selectTime(context, _girlTimeController),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInputField(
            icon: Icons.location_on_outlined,
            hint: "Agra\n(027N09, 078E00 +5.5)",
            controller: _girlPlaceController,
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          // Save Checkbox
          Row(
            children: [
              Checkbox(
                value: _saveDetails,
                onChanged: (value) {
                  setState(() {
                    _saveDetails = value ?? false;
                  });
                },
                activeColor: const Color(0xFFD81B60),
              ),
              const AppText(
                'Save',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD81B60),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Type or Paste Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFD81B60).withOpacity(0.3),
              ),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    'Type or Paste Birth Details',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD81B60),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.add, color: Color(0xFFD81B60), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Show Match Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Handle show match
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD81B60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const AppText(
                'SHOW MATCH',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD81B60).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: const Color(0xFFD81B60), size: 22),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: onTap != null,
              onTap: onTap,
              maxLines: maxLines,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime tempDate = DateTime.now();
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 320,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Select Birth Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B0D31),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: Color(0xFF8B0D31),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
                  const Divider(height: 1, color: Colors.black12),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(tempDate),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B0D31),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      controller.text =
          "${result.day}-${_getMonthName(result.month)}-${result.year}";
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime tempTime = DateTime.now();
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 320,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Select Birth Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B0D31),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: Color(0xFF8B0D31),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: tempTime,
                        onDateTimeChanged: (DateTime newTime) {
                          setModalState(() {
                            tempTime = newTime;
                          });
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.black12),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(tempTime),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B0D31),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      final hour = result.hour;
      final minute = result.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = (hour % 12 == 0 ? 12 : hour % 12)
          .toString()
          .padLeft(2, '0');
      controller.text = "$formattedHour:$minute $period";
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

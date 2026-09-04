import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/core/theme/app_colors.dart';

class MatchMakingScreen extends StatefulWidget {
  const MatchMakingScreen({super.key});

  @override
  State<MatchMakingScreen> createState() => _MatchMakingScreenState();
}

class _MatchMakingScreenState extends State<MatchMakingScreen> {
  String? profile1Name;
  String? profile2Name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E6),
      appBar: CustomAppBar(
        title: 'Match Making'.tr,
        showLeading: true,
        backgroundColor: const Color(0xFFFFF4E6),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Profile Circles with Connection
              Stack(
                alignment: Alignment.center,
                children: [
                  // Connection Line
                  Positioned(
                    child: CustomPaint(
                      size: const Size(300, 200),
                      painter: ConnectionLinePainter(),
                    ),
                  ),
                  
                  // Decorative Stars
                  Positioned(
                    top: 20,
                    left: 40,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.orange.shade300,
                      size: 30,
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 20,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.pink.shade200,
                      size: 35,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 80,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.blue.shade300,
                      size: 40,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.purple.shade300,
                      size: 35,
                    ),
                  ),
                  
                  // Profile Circles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      profile1Name != null
                          ? _buildProfileCircle(
                              profile1Name!.substring(0, 1).toUpperCase(),
                              profile1Name,
                              () => _showAddProfileDialog(true),
                            )
                          : _buildAddProfileCircle(() => _showAddProfileDialog(true)),
                      const SizedBox(width: 80),
                      profile2Name != null
                          ? _buildProfileCircle(
                              profile2Name!.substring(0, 1).toUpperCase(),
                              profile2Name,
                              () => _showAddProfileDialog(false),
                            )
                          : _buildAddProfileCircle(() => _showAddProfileDialog(false)),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 60),
              
              // Description
              const AppText('The stars reveal compatibility'.tr,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3142),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const AppText('Our astrology-based matchmaking reveals the\nstrengths and challenges in your connections.'.tr,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
                textAlign: TextAlign.center,
                height: 1.5,
              ),
              const SizedBox(height: 40),
              
              // Check Compatibility Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (profile1Name != null && profile2Name != null) {
                      // Navigate to compatibility result
                    } else {
                      Get.snackbar(
                        'Add Profiles',
                        'Please add both profiles to check compatibility',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(20),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C63B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const AppText('Check Compatibility'.tr,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCircle(String initial, String? name, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8DEFF),
              border: Border.all(
                color: const Color(0xFFFFB74D),
                width: 4,
              ),
            ),
            child: Center(
              child: AppText(
                initial,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4C63B6),
              ),
            ),
          ),
          if (name != null) ...[
            const SizedBox(height: 8),
            AppText(
              name,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddProfileCircle(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFFFB74D),
                width: 3,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText('ADD'.tr,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3142),
                ),
                const SizedBox(height: 4),
                AppText('Click to select profile'.tr,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProfileDialog(bool isFirstProfile) {
    Get.bottomSheet(
      AddProfileBottomSheet(
        onSave: (name) {
          setState(() {
            if (isFirstProfile) {
              profile1Name = name;
            } else {
              profile2Name = name;
            }
          });
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class ConnectionLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB74D).withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(60, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2 - 40,
      size.width - 60,
      size.height / 2,
    );

    // Heart in the middle
    canvas.drawPath(path, paint);
    
    final heartPaint = Paint()
      ..color = Colors.pink.shade300
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2 - 5, size.height / 2 - 45),
      8,
      heartPaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2 + 5, size.height / 2 - 45),
      8,
      heartPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AddProfileBottomSheet extends StatefulWidget {
  final Function(String) onSave;

  const AddProfileBottomSheet({super.key, required this.onSave});

  @override
  State<AddProfileBottomSheet> createState() => _AddProfileBottomSheetState();
}

class _AddProfileBottomSheetState extends State<AddProfileBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _tobController = TextEditingController();
  final TextEditingController _pobController = TextEditingController();
  String selectedGender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('Add Profile'.tr,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3142),
            ),
            const SizedBox(height: 24),
            
            // Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Name'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Gender
            const AppText('Gender'.tr,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedGender = 'Male'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selectedGender == 'Male' ? const Color(0xFF4C63B6) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedGender == 'Male' ? const Color(0xFF4C63B6) : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: AppText('Male'.tr,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: selectedGender == 'Male' ? Colors.white : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedGender = 'Female'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selectedGender == 'Female' ? const Color(0xFF4C63B6) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedGender == 'Female' ? const Color(0xFF4C63B6) : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: AppText('Female'.tr,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: selectedGender == 'Female' ? Colors.white : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date of Birth
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: () async {
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
                                child: Text('Select Birth Date'.tr,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepPink),
                                ),
                              ),
                              Expanded(
                                child: CupertinoTheme(
                                  data: const CupertinoThemeData(
                                    textTheme: CupertinoTextThemeData(
                                      dateTimePickerTextStyle: TextStyle(color: AppColors.deepPink, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.date,
                                    initialDateTime: tempDate,
                                    minimumDate: DateTime(1900),
                                    maximumDate: DateTime.now(),
                                    onDateTimeChanged: (DateTime newDate) {
                                      setModalState(() => tempDate = newDate);
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
                                  child: Text('Done'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepPink)),
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
                  _dobController.text = "${result.day}-${result.month}-${result.year}";
                }
              },
              decoration: InputDecoration(
                hintText: 'Date of Birth'.tr,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Time of Birth
            TextField(
              controller: _tobController,
              readOnly: true,
              onTap: () async {
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
                                child: Text('Select Birth Time'.tr,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepPink),
                                ),
                              ),
                              Expanded(
                                child: CupertinoTheme(
                                  data: const CupertinoThemeData(
                                    textTheme: CupertinoTextThemeData(
                                      dateTimePickerTextStyle: TextStyle(color: AppColors.deepPink, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.time,
                                    initialDateTime: tempTime,
                                    onDateTimeChanged: (DateTime newTime) {
                                      setModalState(() => tempTime = newTime);
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
                                  child: Text('Done'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepPink)),
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
                  final formattedHour = (hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0');
                  _tobController.text = "$formattedHour:$minute $period";
                }
              },
              decoration: InputDecoration(
                hintText: 'Time of Birth'.tr,
                suffixIcon: const Icon(Icons.access_time_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Place of Birth
            TextField(
              controller: _pobController,
              decoration: InputDecoration(
                hintText: 'Place of Birth'.tr,
                suffixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const AppText('Reset'.tr,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty) {
                        widget.onSave(_nameController.text);
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C63B6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const AppText('Save'.tr,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/utils/custom_snackbar.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../kundli/screens/kundli_matching_screen.dart';
import 'create_kundali_screen.dart';
import 'kundli_screen.dart';
import 'match_making_screen.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? profile1Name;
  String? profile2Name;
  
  // Controllers for Open Kundli tab
  final TextEditingController _boyNameController = TextEditingController();
  final TextEditingController _boyDateController = TextEditingController();
  final TextEditingController _boyTimeController = TextEditingController();
  final TextEditingController _boyPlaceController = TextEditingController();
  final TextEditingController _girlNameController = TextEditingController();
  final TextEditingController _girlDateController = TextEditingController();
  final TextEditingController _girlTimeController = TextEditingController();
  final TextEditingController _girlPlaceController = TextEditingController();
  bool _saveDetails = false;
  
  // Saved Kundlis List
  List<Map<String, String>> savedKundlis = [
    {
      'name': 'Rahul Sharma',
      'dob': '15-Jan-1995',
      'time': '10:30 AM',
      'place': 'Delhi',
    },
    {
      'name': 'Priya Singh',
      'dob': '22-Mar-1997',
      'time': '02:15 PM',
      'place': 'Mumbai',
    },
    {
      'name': 'Amit Kumar',
      'dob': '08-Jul-1993',
      'time': '06:45 PM',
      'place': 'Bangalore',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Match Making',
        showLeading: false,
        backgroundColor: Colors.white,
        titleColor: AppColors.textColorPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryColor),
            onPressed: () {
             Get.to((CreateKundaliScreen()));
              print("Plus clicked");
            },
          ),
        ],
        iconColor: AppColors.textColorPrimary,
      ),
      body: Column(
        children: [
          // Custom Circular Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _tabController.animateTo(0);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabController.index == 0
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: AppText(
                          'OPEN KUNDLI',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _tabController.index == 0
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _tabController.animateTo(1);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _tabController.index == 1
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: AppText(
                          'NEW MATCHING',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _tabController.index == 1
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOpenKundliTab(),
                _buildNewMatchingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenKundliTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Kundli...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        
        // Saved Kundlis List
        Expanded(
          child: savedKundlis.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'No Saved Kundlis',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'Save kundlis to access them quickly',
                        fontSize: 14,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: savedKundlis.length,
                  itemBuilder: (context, index) {
                    final kundli = savedKundlis[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            // Profile Circle
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.secondaryColor,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: AppText(
                                  kundli['name']!.substring(0, 1).toUpperCase(),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    kundli['name']!,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textColorPrimary,
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 10,
                                        color: AppColors.textColorSecondary,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: AppText(
                                          kundli['dob']!,
                                          fontSize: 10,
                                          color: AppColors.textColorSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.access_time_outlined,
                                        size: 10,
                                        color: AppColors.textColorSecondary,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: AppText(
                                          kundli['time']!,
                                          fontSize: 10,
                                          color: AppColors.textColorSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 10,
                                        color: AppColors.textColorSecondary,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: AppText(
                                          kundli['place']!,
                                          fontSize: 10,
                                          color: AppColors.textColorSecondary,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Action Menu
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: AppColors.textColorSecondary,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                if (value == 'view') {
                                  Get.to((KundliScreen()));
                                  // View kundli details
                                } else if (value == 'edit') {
                                  // Edit kundli
                                } else if (value == 'delete') {
                                  setState(() {
                                    savedKundlis.removeAt(index);
                                  });
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility_outlined,
                                        size: 18,
                                        color: AppColors.textColorPrimary,
                                      ),
                                      const SizedBox(width: 12),
                                      const AppText(
                                        'View',
                                        fontSize: 14,
                                        color: AppColors.textColorPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 12),
                                      const AppText(
                                        'Edit',
                                        fontSize: 14,
                                        color: AppColors.textColorPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red.shade400,
                                      ),
                                      const SizedBox(width: 12),
                                      AppText(
                                        'Delete',
                                        fontSize: 14,
                                        color: Colors.red.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Add New Kundli Button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _showAddKundliBottomSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  AppText(
                    'Add New Kundli',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddKundliBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'Add New Kundli',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColorPrimary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildInputField(
                icon: Icons.person_outline,
                hint: "Name",
                controller: _boyNameController,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      icon: Icons.calendar_today_outlined,
                      hint: "Date of Birth",
                      controller: _boyDateController,
                      onTap: () => _selectDate(context, _boyDateController),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInputField(
                      icon: Icons.access_time_outlined,
                      hint: "Time",
                      controller: _boyTimeController,
                      onTap: () => _selectTime(context, _boyTimeController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInputField(
                icon: Icons.location_on_outlined,
                hint: "Place of Birth",
                controller: _boyPlaceController,
              ),
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_boyNameController.text.isNotEmpty &&
                        _boyDateController.text.isNotEmpty &&
                        _boyTimeController.text.isNotEmpty &&
                        _boyPlaceController.text.isNotEmpty) {
                      setState(() {
                        savedKundlis.add({
                          'name': _boyNameController.text,
                          'dob': _boyDateController.text,
                          'time': _boyTimeController.text,
                          'place': _boyPlaceController.text,
                        });
                      });
                      _boyNameController.clear();
                      _boyDateController.clear();
                      _boyTimeController.clear();
                      _boyPlaceController.clear();
                      Get.back();
                      CustomSnackbar.showSuccess('Kundli saved successfully');
                    } else {
                      CustomSnackbar.showError('Please fill all fields');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const AppText(
                    'Save Kundli',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildNewMatchingTab() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Profile Circles with Connection
            Stack(
              alignment: Alignment.center,
              children: [
                // Connection Line
                Positioned(
                  child: CustomPaint(
                    size: const Size(250, 150),
                    painter: ConnectionLinePainter(),
                  ),
                ),
                
                // Decorative Stars
                Positioned(
                  top: 15,
                  left: 30,
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.goldAccent,
                    size: 24,
                  ),
                ),
                Positioned(
                  bottom: 60,
                  right: 15,
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.primaryColor,
                    size: 28,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 60,
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.secondaryColor,
                    size: 32,
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 15,
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.accentColor,
                    size: 28,
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
                    const SizedBox(width: 50),
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
            
            const SizedBox(height: 40),
            
            // Description
            const AppText(
              'The stars reveal compatibility',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const AppText(
              'Our astrology-based matchmaking reveals the\nstrengths and challenges in your connections.',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textColorSecondary,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: 30),
            
            // Check Compatibility Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (profile1Name != null && profile2Name != null) {
                    CustomSnackbar.showInfo('Compatibility results coming soon!', title: 'Coming Soon');
                  } else {
                    CustomSnackbar.showWarning('Please add both profiles to check compatibility', title: 'Add Profiles');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const AppText(
                  'Check Compatibility',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
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
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: AppColors.primaryColor, size: 22),
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = "${picked.day}-${_getMonthName(picked.month)}-${picked.year}";
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildProfileCircle(String initial, String? name, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softPink,
              border: Border.all(
                color: AppColors.primaryColor,
                width: 3,
              ),
            ),
            child: Center(
              child: AppText(
                initial,
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: AppColors.deepPink,
              ),
            ),
          ),
          if (name != null) ...[
            const SizedBox(height: 6),
            AppText(
              name,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorPrimary,
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: AppColors.primaryColor,
                width: 2.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText(
                  'ADD',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 3),
                AppText(
                  'Click to select profile',
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColorSecondary,
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
      ..color = AppColors.primaryColor.withOpacity(0.3)
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
      ..color = AppColors.secondaryColor
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
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Add Profile',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 20),
            
            // Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
            
            // Gender
            const AppText(
              'Gender',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textColorSecondary,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedGender = 'Male'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedGender == 'Male' ? AppColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedGender == 'Male' ? AppColors.primaryColor : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: AppText(
                          'Male',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedGender == 'Male' ? Colors.white : AppColors.textColorSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedGender = 'Female'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedGender == 'Female' ? AppColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedGender == 'Female' ? AppColors.primaryColor : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: AppText(
                          'Female',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedGender == 'Female' ? Colors.white : AppColors.textColorSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Date of Birth
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _dobController.text = "${date.day}-${date.month}-${date.year}";
                }
              },
              decoration: InputDecoration(
                hintText: 'Date of Birth',
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
            
            // Time of Birth
            TextField(
              controller: _tobController,
              readOnly: true,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  _tobController.text = time.format(context);
                }
              },
              decoration: InputDecoration(
                hintText: 'Time of Birth',
                suffixIcon: const Icon(Icons.access_time_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
            
            // Place of Birth
            TextField(
              controller: _pobController,
              decoration: InputDecoration(
                hintText: 'Place of Birth',
                suffixIcon: const Icon(Icons.location_on_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const AppText(
                      'Reset',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty) {
                        widget.onSave(_nameController.text);
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const AppText(
                      'Save',
                      fontSize: 14,
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

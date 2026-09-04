import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/custom_button.dart';

class MatrimonySearchScreen extends StatefulWidget {
  const MatrimonySearchScreen({super.key});

  @override
  State<MatrimonySearchScreen> createState() => _MatrimonySearchScreenState();
}

class _MatrimonySearchScreenState extends State<MatrimonySearchScreen> {
  String? selectedMotherTongue;
  String? selectedCommunity;

  final List<String> motherTongues = [
    'Hindi',
    'English',
    'Marathi',
    'Bengali',
    'Tamil',
    'Telugu',
    'Gujarati',
    'Kannada',
    'Malayalam',
    'Punjabi',
  ];

  final List<String> communities = [
    'Hindu',
    'Muslim',
    'Christian',
    'Sikh',
    'Buddhist',
    'Jain',
    'Parsi',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFC0CB),
              Color(0xFFFFE4E9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Family Image
                      Container(
                        height: 350,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.pexels.com/photos/1444442/pexels-photo-1444442.jpeg?auto=compress&cs=tinysrgb&w=800',
                            ),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Form Container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText('Search for Matches who speak'.tr,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A4A4A),
                            ),
                            const SizedBox(height: 20),
                            
                            // Mother Tongue Dropdown
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedMotherTongue,
                                decoration: InputDecoration(
                                  hintText: 'Mother tongue *'.tr,
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF9E9E9E),
                                ),
                                dropdownColor: Colors.white,
                                items: motherTongues.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: AppText(
                                      value,
                                      fontSize: 15,
                                      color: const Color(0xFF4A4A4A),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedMotherTongue = newValue;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            AppText('and belong to'.tr,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A4A4A),
                            ),
                            const SizedBox(height: 20),
                            
                            // Community Dropdown
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedCommunity,
                                decoration: InputDecoration(
                                  hintText: 'Community *'.tr,
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF9E9E9E),
                                ),
                                dropdownColor: Colors.white,
                                items: communities.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: AppText(
                                      value,
                                      fontSize: 15,
                                      color: const Color(0xFF4A4A4A),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCommunity = newValue;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Let's Begin Button
                            CustomButton(
                              text: "Let's Begin",
                              height: 56,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              borderRadius: 12,
                              gradient: AppColors.primaryGradient,
                              onTap: () {
                                if (selectedMotherTongue != null && selectedCommunity != null) {
                                  // Handle search
                                  Get.snackbar(
                                    'Search Started',
                                    'Searching for matches...',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(20),
                                  );
                                } else {
                                  Get.snackbar(
                                    'Required Fields',
                                    'Please select both mother tongue and community',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(20),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

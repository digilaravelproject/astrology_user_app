import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../astrologers/controllers/astrologer_controller.dart';

class AstrologerFilterBottomSheet extends StatefulWidget {
  const AstrologerFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<AstrologerFilterBottomSheet> createState() => _AstrologerFilterBottomSheetState();
}

class _AstrologerFilterBottomSheetState extends State<AstrologerFilterBottomSheet> {
  final controller = Get.find<AstrologerController>();
  int selectedCategoryIndex = 0;

  // Local state for filters before applying
  late List<String> tempSkills;
  late List<String> tempLanguages;
  late double tempRating;
  late int tempMinPrice;
  late int tempMaxPrice;
  late String tempSortBy;
  late bool tempIsOnline;

  final List<Map<String, dynamic>> filterCategories = [
    {
      'title': AppStrings.sortBy,
      'type': 'radio',
      'options': [
        'rating_high_to_low',
        'price_low_to_high',
        'price_high_to_low',
        'experience_high_to_low'
      ],
      'display_options': [
        'Rating: High to Low',
        'Price: Low to High',
        'Price: High to Low',
        'Experience: High to Low'
      ]
    },
    {
      'title': AppStrings.skills,
      'type': 'checkbox',
      'options': ['Vedic', 'Tarot', 'Numerology', 'Palmistry', 'Vastu', 'Life Coach']
    },
    {
      'title': AppStrings.languages,
      'type': 'checkbox',
      'options': ['Hindi', 'English', 'Marathi', 'Bengali', 'Gujarati', 'Punjabi']
    },
    {
      'title': AppStrings.priceRange,
      'type': 'slider',
      'min': 0,
      'max': 1000,
    },
    {
      'title': AppStrings.rating,
      'type': 'radio',
      'options': [4.5, 4.0, 3.0, 0.0],
      'display_options': ['4.5 & above', '4.0 & above', '3.0 & above', 'All Ratings']
    },
  ];

  @override
  void initState() {
    super.initState();
    tempSkills = List.from(controller.selectedSkills);
    tempLanguages = List.from(controller.selectedLanguages);
    tempRating = controller.minRating.value;
    tempMinPrice = controller.minPrice.value;
    tempMaxPrice = controller.maxPrice.value;
    tempSortBy = controller.sortBy.value;
    tempIsOnline = controller.isOnlineOnly.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  AppStrings.filtersTitle,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // sidebar
                Container(
                  width: 120,
                  color: Colors.grey.shade50,
                  child: ListView.builder(
                    itemCount: filterCategories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategoryIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            border: isSelected
                                ? const Border(left: BorderSide(color: AppColors.deepPink, width: 4))
                                : null,
                          ),
                          child: AppText(
                            filterCategories[index]['title'],
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.deepPink : Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Options area
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: _buildOptionsList(),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        tempSkills.clear();
                        tempLanguages.clear();
                        tempRating = 0.0;
                        tempMinPrice = 0;
                        tempMaxPrice = 1000;
                        tempSortBy = 'rating_high_to_low';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.deepPink),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: AppText(AppStrings.clearAll, color: AppColors.deepPink, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.setFilters(
                        minP: tempMinPrice,
                        maxP: tempMaxPrice,
                        skills: tempSkills,
                        langs: tempLanguages,
                        rating: tempRating,
                        online: tempIsOnline,
                        sort: tempSortBy,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepPink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: AppText(AppStrings.applyFilters, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    final cat = filterCategories[selectedCategoryIndex];
    final type = cat['type'];

    if (type == 'slider') {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              '₹$tempMinPrice - ₹$tempMaxPrice',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.deepPink,
            ),
            const SizedBox(height: 20),
            RangeSlider(
              values: RangeValues(
                tempMinPrice.toDouble().clamp(0, 1000),
                tempMaxPrice.toDouble().clamp(0, 1000),
              ),
              min: 0,
              max: 1000,
              divisions: 20,
              activeColor: AppColors.deepPink,
              inactiveColor: AppColors.deepPink.withOpacity(0.1),
              labels: RangeLabels('₹$tempMinPrice', '₹$tempMaxPrice'),
              onChanged: (values) {
                setState(() {
                  tempMinPrice = values.start.round();
                  tempMaxPrice = values.end.round();
                });
              },
            ),
          ],
        ),
      );
    }

    final options = cat['options'] as List;
    final displayOptions = cat['display_options'] as List?;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final displayText = displayOptions != null ? displayOptions[index] : option.toString();

        if (type == 'checkbox') {
          final isChecked = cat['title'] == AppStrings.skills
              ? tempSkills.contains(option)
              : tempLanguages.contains(option);

          return CheckboxListTile(
            value: isChecked,
            activeColor: AppColors.deepPink,
            dense: true,
            title: AppText(displayText.tr, fontSize: 14, color: Colors.black87),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) {
              setState(() {
                if (cat['title'] == AppStrings.skills) {
                  val! ? tempSkills.add(option) : tempSkills.remove(option);
                } else {
                  val! ? tempLanguages.add(option) : tempLanguages.remove(option);
                }
              });
            },
          );
        } else {
          // radio
          bool isSelected = false;
          if (cat['title'] == AppStrings.sortBy) {
            isSelected = tempSortBy == option;
          } else if (cat['title'] == AppStrings.rating) {
            isSelected = tempRating == option;
          }

          return RadioListTile<dynamic>(
            value: option,
            groupValue: isSelected ? option : null,
            activeColor: AppColors.deepPink,
            dense: true,
            title: AppText(displayText.tr, fontSize: 14, color: Colors.black87),
            onChanged: (val) {
              setState(() {
                if (cat['title'] == AppStrings.sortBy) {
                  tempSortBy = val;
                } else if (cat['title'] == AppStrings.rating) {
                  tempRating = (val as num).toDouble();
                }
              });
            },
          );
        }
      },
    );
  }
}

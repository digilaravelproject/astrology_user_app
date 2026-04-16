import 'package:flutter/material.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';


final Map<String, dynamic> kundliData = {
  "compatibility_score": 28.5,
  "max_score": 36,
  "percentage": 79.2,
  "verdict": "Highly Compatible",
  "recommendation": "This match is favorable for marriage. The couple shares good mental and emotional compatibility.",
  "guna_milan": {
    "varna": {
      "score": 1,
      "max": 1,
      "description": "Spiritual compatibility - Both belong to compatible varnas"
    },
    "vashya": {
      "score": 2,
      "max": 2,
      "description": "Dominance - Mutual respect and understanding"
    },
    "tara": {
      "score": 3,
      "max": 3,
      "description": "Birth star compatibility - Favorable nakshatras"
    },
    "yoni": {
      "score": 4,
      "max": 4,
      "description": "Physical compatibility - Excellent match"
    },
    "graha_maitri": {
      "score": 4.5,
      "max": 5,
      "description": "Planetary friendship - Good mental compatibility"
    },
    "gana": {
      "score": 6,
      "max": 6,
      "description": "Temperament - Both are Manushya gana"
    },
    "bhakoot": {
      "score": 5,
      "max": 7,
      "description": "Love and affection - Minor doshas present"
    },
    "nadi": {
      "score": 3,
      "max": 8,
      "description": "Health and genes - Nadi dosha partially present"
    }
  },
  "doshas": {
    "manglik": {
      "male": {"present": false, "intensity": null},
      "female": {"present": true, "intensity": "Mild", "cancelled_by": "Jupiter aspect"}
    },
    "nadi_dosha": {
      "present": true,
      "severity": "Low",
      "remedies": ["Nadi Nivaran Puja", "Gold donation"]
    }
  }
};

class KundliMatchScreen extends StatelessWidget {
  const KundliMatchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Match Result',
            style: TextStyle(
              color: AppColors.textColorPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          // Removed the bottom line by not using bottom property
          // and setting elevation to 0
          bottom: const TabBar(
            indicatorColor: AppColors.primaryColor,
            indicatorWeight: 2.5,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textColorSecondary,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Guna Milan'),
              Tab(text: 'Doshas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OverviewTab(),
            GunaMilanTab(),
            DoshasTab(),
          ],
        ),
      ),
    );
  }
}

// ===================== TAB 1: OVERVIEW =====================
class OverviewTab extends StatelessWidget {
  const OverviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score = kundliData['compatibility_score'] as double;
    final maxScore = kundliData['max_score'] as int;
    final percentage = kundliData['percentage'] as double;
    final verdict = kundliData['verdict'] as String;
    final recommendation = kundliData['recommendation'] as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Circular Progress
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Match',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  verdict,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: AppColors.goldAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Score: $score / $maxScore',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recommendation Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.dividerColor, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite, color: AppColors.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Recommendation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  recommendation,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textColorSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== TAB 2: GUNA MILAN (4 Columns) =====================
class GunaMilanTab extends StatelessWidget {
  const GunaMilanTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gunaData = kundliData['guna_milan'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with 4 columns
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Guna',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Score',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Max',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    'Area of Life',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Guna Rows
          ...gunaData.entries.map((entry) {
            final key = entry.key;
            final value = entry.value as Map<String, dynamic>;
            final score = value['score'] is double
                ? (value['score'] as double).toString()
                : value['score'].toString();
            final maxScore = value['max'].toString();
            final description = value['description'].split('-').first.trim();
           // final gunaName = key[0].toUpperCase() + key.substring(1);
            final gunaName = key.contains('_')
                ? key.split('_').last
                : key;

            final formattedGunaName =
                gunaName[0].toUpperCase() + gunaName.substring(1);

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.dividerColor, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      formattedGunaName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.textColorPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      score,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      maxScore,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      description,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textColorSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ===================== TAB 3: DOSHAS =====================
class DoshasTab extends StatelessWidget {
  const DoshasTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final doshasData = kundliData['doshas'] as Map<String, dynamic>;
    final manglikData = doshasData['manglik'] as Map<String, dynamic>;
    final nadiData = doshasData['nadi_dosha'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manglik Dosha Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dividerColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Manglik Dosha',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (manglikData['female']['present'] as bool)
                              ? AppColors.errorColor.withOpacity(0.1)
                              : AppColors.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (manglikData['female']['present'] as bool) ? 'Active' : 'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: (manglikData['female']['present'] as bool)
                                ? AppColors.errorColor
                                : AppColors.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDoshaStatusRow(
                        'Male',
                        (manglikData['male']['present'] as bool) ? 'Present' : 'Not Present',
                        (manglikData['male']['present'] as bool),
                      ),
                      const SizedBox(height: 12),
                      _buildDoshaStatusRow(
                        'Female',
                        (manglikData['female']['present'] as bool) ? 'Present' : 'Not Present',
                        (manglikData['female']['present'] as bool),
                      ),
                      if (manglikData['female']['present'] as bool) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.tune, size: 16, color: AppColors.textColorSecondary),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Intensity:',
                                    style: TextStyle(fontSize: 13, color: AppColors.textColorSecondary),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    manglikData['female']['intensity'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.clear, size: 16, color: AppColors.textColorSecondary),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Cancelled by:',
                                    style: TextStyle(fontSize: 13, color: AppColors.textColorSecondary),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    manglikData['female']['cancelled_by'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nadi Dosha Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dividerColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.health_and_safety, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Nadi Dosha',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (nadiData['present'] as bool)
                              ? AppColors.warningColor.withOpacity(0.1)
                              : AppColors.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (nadiData['present'] as bool) ? 'Partial' : 'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: (nadiData['present'] as bool)
                                ? AppColors.warningColor
                                : AppColors.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDoshaStatusRow(
                        'Status',
                        (nadiData['present'] as bool) ? 'Present' : 'Not Present',
                        (nadiData['present'] as bool),
                      ),
                      if (nadiData['present'] as bool) ...[
                        const SizedBox(height: 12),
                        _buildDoshaStatusRow(
                          'Severity',
                          nadiData['severity'] as String,
                          true,
                          isWarning: true,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.fieldBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Suggested Remedies:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...(nadiData['remedies'] as List).map((remedy) => Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 5, color: AppColors.primaryColor),
                                    const SizedBox(width: 10),
                                    Text(
                                      remedy,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoshaStatusRow(String label, String value, bool isActive, {bool isWarning = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textColorSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isWarning
                ? AppColors.warningColor
                : (isActive ? AppColors.errorColor : AppColors.successColor),
          ),
        ),
      ],
    );
  }
}


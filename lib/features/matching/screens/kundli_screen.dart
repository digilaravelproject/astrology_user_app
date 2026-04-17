import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../controllers/kundli_controller.dart';
import 'kundli_chart_widget.dart';

class KundliScreen extends StatefulWidget {
  final String? birthDate;
  final String? birthTime;
  final double? latitude;
  final double? longitude;
  final String? datetime;
  final String? name;
  final String? place;

  const KundliScreen({
    super.key,
    this.birthDate,
    this.birthTime,
    this.latitude,
    this.longitude,
    this.datetime,
    this.name,
    this.place,
  });

  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late KundliController controller;
  
  final List<String> _tabs = [
    "Birth Details",
    "Ascendant",
    "Planets",
    "Houses",
    "Dashas",
    "Yogas",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    // Get or create controller
    if (Get.isRegistered<KundliController>()) {
      controller = Get.find<KundliController>();
    } else {
      // Binding should handle this, but fallback
      controller = Get.put(KundliController(
        getBirthChartUseCase: Get.find(),
        createKundliUseCase: Get.find(),
        getKundliListUseCase: Get.find(),
        getKundliByIdUseCase: Get.find(),
        updateKundliUseCase: Get.find(),
        deleteKundliUseCase:  Get.find(),
      ));
    }
    
    // Check if we should skip fetching (data already loaded)
    final arguments = Get.arguments as Map<String, dynamic>?;
    final skipFetch = arguments?['skipFetch'] ?? false;
    
    // Only fetch if not skipped and we don't have data
    if (!skipFetch && controller.kundliData.value == null) {
      // Fetch data with provided parameters - all required
      if (widget.birthDate != null && 
          widget.birthTime != null && 
          widget.latitude != null && 
          widget.longitude != null && 
          widget.datetime != null) {
        controller.fetchKundliData(
          birthDate: widget.birthDate!,
          birthTime: widget.birthTime!,
          latitude: widget.latitude!,
          longitude: widget.longitude!,
          datetime: widget.datetime!,
        );
      } else {
        print('[KUNDLI_APP] [ERROR] Missing required parameters for birth chart API');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5),
      appBar: CustomAppBar(
        title: widget.name ?? 'Kundli',
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.kundliData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.kundliData.value == null) {
          return Center(
            child: AppText(
              controller.errorMessage.value.isEmpty ? 'No data available' : controller.errorMessage.value,
              fontSize: 14,
              color: Colors.grey,
            ),
          );
        }

        return Column(
          children: [
            _buildTopTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBirthDetailsTab(),
                  _buildAscendantTab(),
                  _buildPlanetsTab(),
                  _buildHousesTab(),
                  _buildDashasTab(),
                  _buildYogasTab(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTopTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildBirthDetailsTab() {
    final birth = controller.kundliData.value!.data.birthDetails;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText("Birth Information", fontSize: 16, fontWeight: FontWeight.w700),
            const SizedBox(height: 16),
            _buildInfoRow("Date of Birth", birth.date),
            _buildInfoRow("Time of Birth", birth.time),
            _buildInfoRow("Place of Birth", birth.place),
            const Divider(height: 24),
            const AppText("Location Details", fontSize: 14, fontWeight: FontWeight.w600),
            const SizedBox(height: 12),
            _buildInfoRow("Latitude", birth.latitude.toStringAsFixed(4)),
            _buildInfoRow("Longitude", birth.longitude.toStringAsFixed(4)),
            _buildInfoRow("Timezone", birth.timezone),
            _buildInfoRow("Timezone Offset", "${birth.timezoneOffset} hours"),
          ],
        ),
      ),
    );
  }

  Widget _buildAscendantTab() {
    final ascendant = controller.kundliData.value!.data.ascendant;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText("Ascendant (Lagna)", fontSize: 16, fontWeight: FontWeight.w700),
                const SizedBox(height: 16),
                _buildInfoRow("Sign", ascendant.sign),
                _buildInfoRow("Degree", "${ascendant.degree.toStringAsFixed(3)}°"),
                _buildInfoRow("Nakshatra", ascendant.nakshatra),
                _buildInfoRow("Pada", ascendant.pada.toString()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: KundliChartWidget(
              title: "Lagna Chart (D1)",
              planetData: controller.getPlanetsGroupedByHouse(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsTab() {
    final planets = controller.kundliData.value!.data.planets;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText("Planetary Positions", fontSize: 16, fontWeight: FontWeight.w700),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowHeight: 40,
                dataRowMinHeight: 35,
                columns: const [
                  DataColumn(label: AppText("Planet", fontWeight: FontWeight.bold, fontSize: 12)),
                  DataColumn(label: AppText("Sign", fontWeight: FontWeight.bold, fontSize: 12)),
                  DataColumn(label: AppText("House", fontWeight: FontWeight.bold, fontSize: 12)),
                  DataColumn(label: AppText("Degree", fontWeight: FontWeight.bold, fontSize: 12)),
                  DataColumn(label: AppText("Nakshatra", fontWeight: FontWeight.bold, fontSize: 12)),
                  DataColumn(label: AppText("Retrograde", fontWeight: FontWeight.bold, fontSize: 12)),
                ],
                rows: planets.map((p) => DataRow(
                  cells: [
                    DataCell(AppText(p.name, fontSize: 11, fontWeight: FontWeight.w600)),
                    DataCell(AppText(p.sign, fontSize: 11)),
                    DataCell(AppText(p.house.toString(), fontSize: 11)),
                    DataCell(AppText(p.degreeFormatted, fontSize: 11)),
                    DataCell(AppText(p.nakshatra, fontSize: 11)),
                    DataCell(
                      p.isRetrograde 
                        ? const Icon(Icons.refresh, size: 16, color: Colors.red)
                        : const Icon(Icons.check, size: 16, color: Colors.green),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHousesTab() {
    final houses = controller.kundliData.value!.data.houses;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText("House Cusps", fontSize: 16, fontWeight: FontWeight.w700),
            const SizedBox(height: 16),
            ...houses.map((h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: AppText(
                        h.house.toString(),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(h.sign, fontSize: 13, fontWeight: FontWeight.w600),
                        AppText(
                          "${h.degree.toStringAsFixed(2)}°",
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDashasTab() {
    final dashas = controller.kundliData.value!.data.dashas;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current Dasha
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor.withOpacity(0.1), AppColors.primaryColor.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.star, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const AppText("Current Dasha Period", fontSize: 16, fontWeight: FontWeight.w700),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow("Mahadasha", dashas.current.mahadasha),
                _buildInfoRow("Antardasha", dashas.current.antardasha),
                _buildInfoRow("Pratyantardasha", dashas.current.pratyantardasha),
                const Divider(height: 20),
                _buildInfoRow("Start Date", dashas.current.startDate),
                _buildInfoRow("End Date", dashas.current.endDate),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Upcoming Dashas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText("Upcoming Dasha Periods", fontSize: 16, fontWeight: FontWeight.w700),
                const SizedBox(height: 16),
                ...dashas.upcoming.map((d) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppText(
                              "${d.mahadasha} - ${d.antardasha}",
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          AppText(
                            "${d.startDate} to ${d.endDate}",
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYogasTab() {
    final yogas = controller.getPresentYogas();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (yogas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: AppText(
                  "No significant yogas found",
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...yogas.map((yoga) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          yoga.name,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStrengthColor(yoga.strength).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText(
                          yoga.strength,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStrengthColor(yoga.strength),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppText(
                    yoga.description,
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: AppText(label, fontSize: 12, color: Colors.grey.shade700),
          ),
          const AppText(": ", fontSize: 12),
          Expanded(
            child: AppText(value, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'strong':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'weak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

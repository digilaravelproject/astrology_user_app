import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'controllers/panchang_controller.dart';

class PanchangScreen extends GetView<PanchangController> {
  const PanchangScreen({super.key});

  Future<void> _selectDate(BuildContext context) async {
    await controller.pickDate(context);
  }

  @override
  Widget build(BuildContext context) {
    print('[PCB_APP] [DEBUG] PanchangScreen build called');
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5),
      appBar: const CustomAppBar(
        title: 'Panchang',
      ),
      body: Column(
        children: [
          _buildCalendarSection(),
          Expanded(
            child: Obx(() {
              print('[PCB_APP] [DEBUG] Obx rebuild - isLoading: ${controller.isLoading.value}');
              print('[PCB_APP] [DEBUG] Obx rebuild - panchangData null: ${controller.panchangData.value == null}');
              
              if (controller.isLoading.value && controller.panchangData.value == null) {
                print('[PCB_APP] [DEBUG] Showing loading indicator');
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.panchangData.value == null) {
                print('[PCB_APP] [DEBUG] Showing no data message');
                return Center(
                  child: AppText(
                    controller.errorMessage.value.isEmpty
                        ? 'No data available'
                        : controller.errorMessage.value,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                );
              }

              print('[PCB_APP] [DEBUG] Showing panchang data');
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSunMoonSection(),
                    const SizedBox(height: 24),
                    _buildCorePanchangSection(),
                    const SizedBox(height: 24),
                    _buildMuhurtaSection("Shubh Muhurta", _getAuspiciousTimings(), Colors.green),
                    const SizedBox(height: 16),
                    _buildMuhurtaSection("Ashubh Muhurta", _getInauspiciousTimings(), Colors.red),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Obx(() => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          DateFormat('MMMM yyyy').format(controller.selectedDate.value),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E1A47),
                        ),
                        AppText(
                          DateFormat('EEEE, dd MMM').format(controller.selectedDate.value),
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            controller.showFullCalendar.value ? Iconsax.arrow_up_2_copy : Iconsax.calendar_copy,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: controller.toggleCalendar,
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.location_copy, color: AppColors.primaryColor),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (controller.showFullCalendar.value)
                SizedBox(
                  height: 300,
                  child: CalendarDatePicker(
                    initialDate: controller.selectedDate.value,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    onDateChanged: controller.selectDate,
                  ),
                )
              else
                _buildDateStrip(),
              const SizedBox(height: 15),
            ],
          )),
    );
  }

  Widget _buildDateStrip() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: controller.scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 30,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 5));
          final isSelected = date.day == controller.selectedDate.value.day &&
              date.month == controller.selectedDate.value.month &&
              date.year == controller.selectedDate.value.year;

          return GestureDetector(
            onTap: () => controller.selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    DateFormat('EEE').format(date).toUpperCase(),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white70 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    date.day.toString(),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF2E1A47),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSunMoonSection() {
    final data = controller.panchangData.value?.data;
    print('[PCB_APP] [DEBUG] _buildSunMoonSection - data null: ${data == null}');
    if (data == null) return const SizedBox.shrink();

    print('[PCB_APP] [DEBUG] Sunrise: ${data.sunrise}, Sunset: ${data.sunset}');
    
    return Row(
      children: [
        Expanded(
          child: _buildTimingCard(
            title: "Sun Timings",
            items: [
              {"label": "Sunrise", "time": controller.formatTime(data.sunrise), "icon": Icons.wb_sunny_rounded, "color": Colors.orange},
              {"label": "Sunset", "time": controller.formatTime(data.sunset), "icon": Icons.wb_twilight_rounded, "color": Colors.deepOrange},
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimingCard(
            title: "Moon Timings",
            items: [
              {"label": "Moonrise", "time": controller.formatTime(data.moonrise), "icon": Icons.nightlight_round, "color": Colors.blueGrey},
              {"label": "Moonset", "time": controller.formatTime(data.moonset), "icon": Icons.mode_night_rounded, "color": Colors.indigo},
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimingCard({required String title, required List<Map<String, dynamic>> items}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title, fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(item['icon'], size: 16, color: item['color']),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(item['label'], fontSize: 11, color: Colors.grey),
                        AppText(item['time'], fontSize: 13, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCorePanchangSection() {
    final data = controller.panchangData.value?.data;
    if (data == null) return const SizedBox.shrink();

    final details = [
      {"label": "Tithi", "value": "${data.tithi.name} upto ${controller.formatTime(data.tithi.endTime)}"},
      {"label": "Nakshatra", "value": "${data.nakshatra.name} upto ${controller.formatTime(data.nakshatra.endTime)}"},
      {"label": "Yoga", "value": "${data.yoga.name} upto ${controller.formatTime(data.yoga.endTime)}"},
      {"label": "Karana", "value": "${data.karana.name} upto ${controller.formatTime(data.karana.endTime)}"},
      {"label": "Vara", "value": data.vara.name},
      {"label": "Location", "value": data.location},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Panchang Details', fontSize: 15, fontWeight: FontWeight.w700),
          const SizedBox(height: 12),
          ...details.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: AppText(d['label']!, fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                    const AppText(":  ", fontWeight: FontWeight.bold),
                    Expanded(
                      child: AppText(d['value']!, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMuhurtaSection(String title, List<Map<String, String>> timings, Color color) {
    if (timings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: AppText(title, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: timings
                .map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(t['title']!, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          AppText(t['time']!, fontSize: 13, color: color, fontWeight: FontWeight.w700),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getAuspiciousTimings() {
    final data = controller.panchangData.value?.data;
    if (data == null) return [];

    List<Map<String, String>> timings = [];

    // if (data.abhijitMuhurta.start.isNotEmpty && data.abhijitMuhurta.end.isNotEmpty) {
    //   timings.add({
    //     "title": "Abhijit Muhurta",
    //     "time": controller.formatTimeRange(data.abhijitMuhurta.start, data.abhijitMuhurta.end),
    //   });
    // }

    for (var timing in data.auspiciousTimings) {
      timings.add({
        "title": timing.name,
        "time": controller.formatTimeRange(timing.start, timing.end),
      });
    }

    return timings;
  }

  List<Map<String, String>> _getInauspiciousTimings() {
    final data = controller.panchangData.value?.data;
    if (data == null) return [];

    List<Map<String, String>> timings = [];

    if (data.rahukaal.start.isNotEmpty && data.rahukaal.end.isNotEmpty) {
      timings.add({
        "title": "Rahu Kaal",
        "time": controller.formatTimeRange(data.rahukaal.start, data.rahukaal.end),
      });
    }

    if (data.yamagandam.start.isNotEmpty && data.yamagandam.end.isNotEmpty) {
      timings.add({
        "title": "Yamagandam",
        "time": controller.formatTimeRange(data.yamagandam.start, data.yamagandam.end),
      });
    }

    if (data.gulika.start.isNotEmpty && data.gulika.end.isNotEmpty) {
      timings.add({
        "title": "Gulika Kaal",
        "time": controller.formatTimeRange(data.gulika.start, data.gulika.end),
      });
    }

    // for (var period in data.inauspiciousPeriods) {
    //   timings.add({
    //     "title": period.name,
    //     "time": controller.formatTimeRange(period.start, period.end),
    //   });
    // }

    return timings;
  }
}

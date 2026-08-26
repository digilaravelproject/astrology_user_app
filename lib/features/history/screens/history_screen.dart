import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/constants/app_strings.dart';
import 'chat_history_detail_screen.dart';
import '../controllers/history_controller.dart';
import '../domain/usecases/get_chat_sessions_usecase.dart';
import '../domain/usecases/get_call_sessions_usecase.dart';
import '../data/repositories/history_repository.dart';
import 'package:intl/intl.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final HistoryController _historyController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (!Get.isRegistered<HistoryController>()) {
      if (!Get.isRegistered<HistoryRepository>()) {
        Get.put<HistoryRepository>(HistoryRepositoryImpl(apiClient: Get.find()));
      }
      if (!Get.isRegistered<GetChatSessionsUseCase>()) {
        Get.put(GetChatSessionsUseCase(Get.find<HistoryRepository>()));
      }
      if (!Get.isRegistered<GetCallSessionsUseCase>()) {
        Get.put(GetCallSessionsUseCase(Get.find<HistoryRepository>()));
      }
      Get.put(HistoryController(
        getChatSessionsUseCase: Get.find(),
        getCallSessionsUseCase: Get.find(),
      ));
    }
    _historyController = Get.find<HistoryController>();
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightPink.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.deepPink,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: AppText(
          AppStrings.navHistory,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.deepPink,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.deepPink,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepPink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: "Chat".tr),
                Tab(text: "Call".tr),
                Tab(text: "Join Live".tr),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryList("Chat"),
          _buildHistoryList("Call"),
          _buildHistoryList("Live"),
        ],
      ),
    );
  }

  Widget _buildHistoryList(String type) {
    if (type == "Chat") {
      return Obx(() {
        if (_historyController.isLoading.value && _historyController.chatSessions.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }
        
        if (_historyController.error.value.isNotEmpty && _historyController.chatSessions.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _historyController.fetchChatSessions(isRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child: Text("Error: ${_historyController.error.value}"),
              ),
            ),
          );
        }

        if (_historyController.chatSessions.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _historyController.fetchChatSessions(isRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child: AppText(
                  "No chat history available.",
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _historyController.fetchChatSessions(isRefresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _historyController.chatSessions.length,
            itemBuilder: (context, index) {
              final session = _historyController.chatSessions[index];
              final isCompleted = session.status == "completed";
              final astrologerName = session.provider?.name ?? "Astrologer";
              
              DateTime? date;
              try {
                date = DateTime.parse(session.createdAt);
              } catch (_) {}
              
              final dateStr = date != null ? DateFormat('dd MMM, yyyy').format(date) : "N/A";
              final timeStr = date != null ? DateFormat('hh:mm a').format(date) : "N/A";
              
              final durationMins = (session.durationSeconds / 60).ceil();
              
              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => ChatScreen(
                      astrologerName: astrologerName,
                      astrologerImage: session.provider?.profilePhoto ?? '',
                      sessionId: session.id,
                      initialStatus: session.status, // "completed" or whatever
                      startedAtString: session.startedAt,
                    ),
                    binding: ChatBinding(),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar Placeholder
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.lightPink.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AppText(
                            astrologerName.isNotEmpty ? astrologerName[0].toUpperCase() : 'A',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepPink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              astrologerName,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              "$dateStr • $timeStr",
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              "${'Chat Duration'.tr}: $durationMins ${'mins'.tr}",
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                      
                      // Status & Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText(
                            "₹${session.totalCost}",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: AppText(
                              session.status.capitalizeFirst ?? session.status,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? Colors.green : Colors.red,
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
        );
      });
    }

    if (type == "Call") {
      return Obx(() {
        if (_historyController.isCallLoading.value && _historyController.callSessions.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }
        
        if (_historyController.callError.value.isNotEmpty && _historyController.callSessions.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _historyController.fetchCallSessions(isRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child: Text("Error: ${_historyController.callError.value}"),
              ),
            ),
          );
        }

        if (_historyController.callSessions.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => _historyController.fetchCallSessions(isRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child: AppText(
                  "No call history available.",
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _historyController.fetchCallSessions(isRefresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _historyController.callSessions.length,
            itemBuilder: (context, index) {
              final session = _historyController.callSessions[index];
              final isCompleted = session.status == "completed";
              final astrologerName = session.provider?.name ?? "Astrologer";
              
              DateTime? date;
              if (session.createdAt != null) {
                try {
                  date = DateTime.parse(session.createdAt!);
                } catch (_) {}
              }
              
              final dateStr = date != null ? DateFormat('dd MMM, yyyy').format(date) : "N/A";
              final timeStr = date != null ? DateFormat('hh:mm a').format(date) : "N/A";
              
              final durationMins = (session.durationSeconds / 60).ceil();
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar Placeholder
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.lightPink.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppText(
                          astrologerName.isNotEmpty ? astrologerName[0].toUpperCase() : 'A',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepPink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            astrologerName,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            "$dateStr • $timeStr",
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            "${'Call Duration'.tr}: $durationMins ${'mins'.tr}",
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    
                    // Status & Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          "₹${session.totalCost}",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            session.status.capitalizeFirst ?? session.status,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });
    }

    // Mock Data for Call and Live
    final List<Map<String, String>> historyItems = List.generate(
      15,
      (index) => {
        "name": "Astrologer ${index + 1}",
        "date": "${15 - index} Feb, 2026",
        "status": index % 2 == 0 ? "Completed" : "Missed",
        "price": "₹${(index + 1) * 50}",
        "time": "10:00 AM",
        "duration": "${(index + 1) * 5} mins",
      },
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        final isCompleted = item['status'] == "Completed";
        
        return GestureDetector(
          onTap: () {
            if (type == "Chat") {
              Get.to(() => ChatHistoryDetailScreen(
                astrologerName: item['name']!,
                date: item['date']!,
              ));
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar Placeholder
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightPink.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppText(
                      item['name']![0],
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepPink,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        item['name']!,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        "${item['date']} • ${item['time']}",
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        type == "Live" ? "Joined Live Session" : "$type Duration: ${item['duration']}",
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                
                // Status & Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      item['price']!,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AppText(
                        item['status']!,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

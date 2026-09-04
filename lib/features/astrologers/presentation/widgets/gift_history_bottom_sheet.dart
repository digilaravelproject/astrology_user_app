import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import 'package:astro_user/features/astrologers/presentation/controllers/astrologer_controller.dart';
import 'package:astro_user/features/astrologers/data/models/gift_history_model.dart';

class GiftHistoryBottomSheet extends StatefulWidget {
  final int astrologerId;
  final String astrologerName;

  const GiftHistoryBottomSheet({
    super.key,
    required this.astrologerId,
    required this.astrologerName,
  });

  @override
  State<GiftHistoryBottomSheet> createState() => _GiftHistoryBottomSheetState();
}

class _GiftHistoryBottomSheetState extends State<GiftHistoryBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Fetch history only once when the sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AstrologerController>().fetchGiftHistory(widget.astrologerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AstrologerController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Gift History'.tr,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E1A47),
                  ),
                  AppText(
                    'Sent to ${widget.astrologerName}',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // History List
          SizedBox(
            height: Get.height * 0.5,
            child: Obx(() {
              if (controller.isHistoryLoading.value && controller.giftHistory.isEmpty) {
                return _buildShimmerList();
              }
              
              if (controller.giftHistory.isEmpty) {
                return _buildEmptyState();
              }
              
              return ListView.separated(
                itemCount: controller.giftHistory.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final item = controller.giftHistory[index];
                  return _buildHistoryItem(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(GiftHistoryItem item) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Gift Icon
          Container(
            height: 50,
            width: 50,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.deepPink.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: CustomImageWidget(
              imagePath: item.gift?.iconUrl,
              height: 30,
              width: 30,
              fit: BoxFit.contain,
              fallbackWidget: const Icon(Icons.card_giftcard, color: Colors.pink, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item.gift?.title ?? 'Unknown Gift',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E1A47),
                ),
                AppText(
                  dateStr,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '₹${item.amount}',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.deepPink,
              ),
              AppText(
                item.status.capitalizeFirst ?? '',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: item.status.toLowerCase() == 'completed' ? Colors.green : Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const ShimmerWidget.circular(height: 50, width: 50),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget.rectangular(height: 15, width: 100),
                  SizedBox(height: 8),
                  ShimmerWidget.rectangular(height: 12, width: 150),
                ],
              ),
            ),
            const ShimmerWidget.rectangular(height: 15, width: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          AppText('No gifts sent yet'.tr,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

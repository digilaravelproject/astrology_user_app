import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_user/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/features/wallet/presentation/widgets/recharge_bottom_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.myWallet,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await walletController.fetchWallet();
          await walletController.fetchTransactions();
        },
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildBalanceCard(context, walletController),
              _buildTransactionHistory(context, walletController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      padding: const EdgeInsets.all(28),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E1A47),
            AppColors.primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1A47).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.walletBalance,
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Obx(() => AppText(
                  "₹${controller.balance}",
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  overflow: TextOverflow.ellipsis,
                )),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const RechargeBottomSheet(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      AppText(
                        AppStrings.addMoney,
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context, WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 24, 15, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                AppStrings.transactions,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E1A47),
              ),
            //  const Icon(Icons.sort_rounded, size: 20, color: Color(0xFF2E1A47)),
            ],
          ),
        ),
        Obx(() {
          if (controller.transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    AppText(
                      "No transactions found",
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              final tx = controller.transactions[index];
              final isCredit = tx.transactionType == "credit";
              return GestureDetector(
                onTap: () => _showTransactionDetailsBottomSheet(context, tx),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon Circle
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (isCredit ? Colors.green : AppColors.primaryColor).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
                          color: isCredit ? Colors.green : AppColors.primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      
                      // Transaction details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              tx.description.isNotEmpty
                                  ? tx.description
                                  : (isCredit ? "Wallet Recharge" : "Consultation"),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E1A47),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            AppText(
                              _formatDate(tx.createdAt),
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      
                      // Amount & Info Icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AppText(
                                "${isCredit ? '+' : '-'} ₹${tx.amount}",
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isCredit ? Colors.green : const Color(0xFF2E1A47),
                              ),
                              if (tx.status.toLowerCase() != 'completed')
                                AppText(
                                  tx.status.capitalizeFirst ?? '',
                                  fontSize: 10,
                                  color: _getStatusColor(tx.status),
                                  fontWeight: FontWeight.w600,
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 30),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return "";
      final dateTime = DateTime.parse(dateString);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}";
    } catch (e) {
      return dateString.split('T')[0];
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showTransactionDetailsBottomSheet(BuildContext context, dynamic tx) {
    final double baseAmount = double.tryParse(tx.baseAmount?.toString() ?? '') ?? double.tryParse(tx.amount?.toString() ?? '') ?? 0.0;
    final double gstAmount = double.tryParse(tx.gstAmount?.toString() ?? '') ?? 0.0;
    final double totalAmount = double.tryParse(tx.totalAmount?.toString() ?? '') ?? (baseAmount + gstAmount);
    final double gstPercent = double.tryParse(tx.gstPercent?.toString() ?? '') ?? 18.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "Transaction Details".tr,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E1A47),
                      ),
                      if (tx.invoiceNumber != null && tx.invoiceNumber.toString().isNotEmpty)
                        AppText(
                          tx.invoiceNumber.toString(),
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 14),

              // Breakdown Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    _buildBreakdownRow("Recharge Base Amount (Credited)", "₹${baseAmount.toStringAsFixed(2)}", isBold: true),
                    const SizedBox(height: 10),
                    _buildBreakdownRow("${"GST Applied".tr} (${gstPercent.toStringAsFixed(0)}%)", "₹${gstAmount.toStringAsFixed(2)}", color: AppColors.deepPink),
                    const Divider(height: 24),
                    _buildBreakdownRow("Total Amount Paid via Gateway", "₹${totalAmount.toStringAsFixed(2)}", isTotal: true),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Meta Details
              if (tx.providerOrderId != null && tx.providerOrderId.toString().isNotEmpty)
                _buildMetaRow("Order ID", tx.providerOrderId.toString()),
              if (tx.providerPaymentId != null && tx.providerPaymentId.toString().isNotEmpty)
                _buildMetaRow("Payment ID", tx.providerPaymentId.toString()),
              _buildMetaRow("Payment Mode", (tx.paymentProvider?.toString() ?? "Razorpay").toUpperCase()),
              _buildMetaRow("Status", (tx.status?.toString() ?? "Completed").toUpperCase(), statusColor: _getStatusColor(tx.status)),
              _buildMetaRow("Date & Time", _formatDate(tx.createdAt)),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: AppText(
                    "Close".tr,
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow(String title, String value, {bool isBold = false, bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AppText(
            title.tr,
            fontSize: isTotal ? 13 : 13,
            fontWeight: isTotal || isBold ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF2E1A47) : Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        AppText(
          value,
          fontSize: isTotal ? 15 : 14,
          fontWeight: isTotal || isBold ? FontWeight.w900 : FontWeight.w700,
          color: color ?? (isTotal ? AppColors.primaryColor : const Color(0xFF2E1A47)),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label.tr,
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: AppText(
              value.tr,
              fontSize: 12,
              color: statusColor ?? Colors.black87,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

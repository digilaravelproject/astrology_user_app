import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../widgets/recharge_bottom_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.myWallet,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBalanceCard(context),
            _buildTransactionHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              AppText(
                "₹100",
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      AppText(
                        AppStrings.addMoney,
                        color: Colors.white,
                        fontSize: 12,
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

  Widget _buildTransactionHistory(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [
      {"title": AppStrings.walletRecharge, "date": "18 Feb, 2026", "amount": "+ ₹100", "type": "credit"},
      {"title": AppStrings.consultationDrSharma, "date": "17 Feb, 2026", "amount": "- ₹50", "type": "debit"},
      {"title": AppStrings.kundaliReport, "date": "16 Feb, 2026", "amount": "- ₹20", "type": "debit"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                AppStrings.transactions,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E1A47),
              ),
              const Icon(Icons.sort_rounded, size: 20, color: Color(0xFF2E1A47)),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final isCredit = tx["type"] == "credit";
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCredit ? Icons.add_rounded : Icons.remove_rounded,
                      color: isCredit ? Colors.green : Colors.red,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          tx["title"],
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E1A47).withOpacity(0.9),
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          tx["date"],
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  AppText(
                    tx["amount"],
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isCredit ? Colors.green : const Color(0xFF2E1A47),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

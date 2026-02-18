import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';

class RechargeBottomSheet extends StatefulWidget {
  const RechargeBottomSheet({super.key});

  @override
  State<RechargeBottomSheet> createState() => _RechargeBottomSheetState();
}

class _RechargeBottomSheetState extends State<RechargeBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  String selectedAmount = '100';

  final List<String> amounts = ['50', '100', '200', '500', '1000', '2000'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildAmountSelector(),
          _buildCustomInput(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CustomButton(
              text: AppStrings.proceedToPay,
              fontSize: 16,
              height: 55,
              borderRadius: 15,
              onTap: () {
                // Proceed to payment logic
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AppText(
            AppStrings.rechargeWallet,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E1A47),
          ),
          const SizedBox(height: 6),
          AppText(
            AppStrings.selectAmountToAdd,
            fontSize: 13,
            color: Colors.grey.shade600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.popularAmounts,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1A47),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: amounts.map((amount) {
              final isSelected = selectedAmount == amount;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAmount = amount;
                    _amountController.clear();
                  });
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 72) / 3,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AppText(
                      '₹$amount',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF2E1A47),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInput() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (value.isNotEmpty) {
            setState(() {
              selectedAmount = '';
            });
          }
        },
        decoration: InputDecoration(
          hintText: AppStrings.enterCustomAmount,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixText: '₹ ',
          prefixStyle: const TextStyle(
            color: Color(0xFF2E1A47),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        style: const TextStyle(
          color: Color(0xFF2E1A47),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

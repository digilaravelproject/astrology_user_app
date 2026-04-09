import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/wallet_controller.dart';
import '../../../core/utils/custom_snackbar.dart';

class RechargeBottomSheet extends StatefulWidget {
  final double? neededAmount;
  final String? serviceType;

  const RechargeBottomSheet({
    super.key,
    this.neededAmount,
    this.serviceType,
  });

  @override
  State<RechargeBottomSheet> createState() => _RechargeBottomSheetState();
}

class _RechargeBottomSheetState extends State<RechargeBottomSheet> {
  final WalletController walletController = Get.find<WalletController>();
  final TextEditingController _amountController = TextEditingController();
  String selectedAmount = '100';

  final List<String> amounts = ['50', '100', '200', '500', '1000', '2000'];

  @override
  void initState() {
    super.initState();
    _amountController.text = selectedAmount;
  }

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
          if (widget.neededAmount != null) _buildLowBalanceWarning(),
          _buildHeader(),
          _buildAmountSelector(),
          _buildCustomInput(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(() => CustomButton(
              text: AppStrings.proceedToPay,
              fontSize: 16,
              height: 55,
              isLoading: walletController.isLoading.value,
              borderRadius: 15,
              onTap: () async {
                if (_amountController.text.isEmpty) {
                  CustomSnackbar.showError('Please enter an amount');
                  return;
                }
                double? amount = double.tryParse(_amountController.text);
                if (amount == null || amount <= 0) {
                  CustomSnackbar.showError('Please enter a valid amount');
                  return;
                }

                await walletController.startTopUp(amount);
                // The bottom sheet can stay open or close based on success callback in controller
                // If you want it to close here, you can, but it's better handled in controller or after verification
                if (!walletController.isLoading.value) {
                  Navigator.pop(context);
                }
              },
            )),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLowBalanceWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.deepPink.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.deepPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.deepPink, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Insufficient Balance',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepPink,
                    ),
                    AppText(
                      'You need at least ₹${widget.neededAmount?.toStringAsFixed(2)} for this ${widget.serviceType ?? 'session'}.',
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                AppStrings.rechargeWallet,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E1A47),
              ),
              Obx(() => AppText(
                '₹${walletController.balance}',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.deepPink,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: AppText(
              AppStrings.selectAmountToAdd,
              fontSize: 13,
              color: Colors.grey.shade600,
              textAlign: TextAlign.left,
            ),
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
                    _amountController.text = amount;
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/astrologers/domain/models/astrologer_model.dart';
import '../../features/wallet/controllers/wallet_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/custom_button.dart';
import '../constants/app_strings.dart';

import '../../features/wallet/widgets/recharge_bottom_sheet.dart';
import '../services/network/api_client.dart';
import '../constants/app_urls.dart';
import '../utils/custom_snackbar.dart';
import '../../features/astrologers/controllers/astrologer_controller.dart';
import '../../features/call/presentation/pages/call_screen.dart';
import '../../features/call/presentation/controllers/call_controller.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/chat/presentation/bindings/chat_binding.dart';
import '../services/network/websocket_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SessionBottomSheetHelper {
  static int? activeSubSessionId;

  static void show(BuildContext context, AstrologerModel astro) async {
    // 1. Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.deepPink),
      ),
    );

    bool hasActivePackage = false;
    int remainingSeconds = 0;

    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(
        '${AppUrls.packageActiveStatus}?astrologer_id=${astro.userId}',
      );
      
      Navigator.pop(context); // Dismiss loading dialog

      if (response.isSuccess && response.body != null) {
        final body = response.body;
        final data = (body is Map && body.containsKey('has_active_package'))
            ? body
            : (body is Map ? body['data'] : null);
        if (data != null && data is Map) {
          hasActivePackage = data['has_active_package'] == true;
          if (hasActivePackage) {
            final purchase = data['package_purchase'];
            if (purchase != null && purchase is Map) {
              remainingSeconds = int.tryParse(purchase['remaining_duration']?.toString() ?? '') ?? 0;
            }
          }
        }
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog in case of exception
      CustomSnackbar.showError("Failed to check package status: $e");
      return;
    }

    final walletController = Get.find<WalletController>();
    final double walletBalance = double.tryParse(walletController.balance) ?? 0.0;

    // If package is not purchased, verify wallet balance and show confirmation.
    if (!hasActivePackage) {
      final double requiredAmount = (astro.packagePrice ?? 500).toDouble();
      if (walletBalance < requiredAmount) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RechargeBottomSheet(
            neededAmount: requiredAmount,
            serviceType: 'package',
          ),
        );
      } else {
        _showPurchaseConfirmationSheet(context, astro, walletBalance, requiredAmount);
      }
      return;
    }

    String remainingTimeStr;
    if (remainingSeconds < 60) {
      remainingTimeStr = '$remainingSeconds sec';
    } else if (remainingSeconds < 3600) {
      final int mins = remainingSeconds ~/ 60;
      remainingTimeStr = '$mins min';
    } else {
      final int remainingMinutes = remainingSeconds ~/ 60;
      final int remDays = remainingMinutes ~/ 1440;
      final int remHours = (remainingMinutes % 1440) ~/ 60;
      final int remMins = remainingMinutes % 60;

      if (remDays > 0) {
        if (remHours > 0) {
          remainingTimeStr = '$remDays day $remHours hr';
        } else {
          remainingTimeStr = '$remDays day';
        }
      } else {
        if (remMins > 0) {
          remainingTimeStr = '$remHours hr $remMins min';
        } else {
          remainingTimeStr = '$remHours hr';
        }
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              
              // Header
              AppText(
                "Connect with".tr + " ${astro.name}",
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
              const SizedBox(height: 6),
              AppText(
                "Select a service to start your session".tr,
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 20),

              // Remaining Time Info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.timer_outlined, color: Colors.orange.shade800, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "Remaining Package Time".tr,
                            fontSize: 11,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            remainingTimeStr,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade900,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Obx(() {
                  final astroCtrl = Get.isRegistered<AstrologerController>() ? Get.find<AstrologerController>() : null;
                  final currentAstro = astroCtrl?.astrologers.firstWhereOrNull((a) => a.id == astro.id || (astro.userId > 0 && a.userId == astro.userId)) ?? 
                                       astroCtrl?.selectedAstrologer.value ?? 
                                       astro;

                  final bool hasChat = currentAstro.isChatEnabled == true;
                  final bool hasCall = currentAstro.isCallEnabled == true;
                  final bool isActuallyOffline = !currentAstro.isOnline || (!hasChat && !hasCall);

                  if (isActuallyOffline) {
                    return Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Offline'.tr,
                            icon: Icons.person_off,
                            fontSize: 13,
                            height: 48,
                            borderRadius: 12,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            textColor: Colors.grey,
                            borderColor: Colors.grey,
                            onTap: () {
                              CustomSnackbar.showInfo('Astrologer is offline.');
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (hasChat)
                        Expanded(
                          child: CustomButton(
                            text: currentAstro.isBusy ? 'Busy' : (!currentAstro.isOnline ? 'Offline' : AppStrings.chat),
                            icon: Icons.chat_bubble_outline_rounded,
                            fontSize: 13,
                            height: 48,
                            borderRadius: 12,
                            backgroundColor: (!currentAstro.isOnline || currentAstro.isBusy) ? Colors.grey.withOpacity(0.2) : null,
                            textColor: (!currentAstro.isOnline || currentAstro.isBusy) ? Colors.grey : Colors.white,
                            borderColor: (!currentAstro.isOnline || currentAstro.isBusy) ? Colors.grey : Colors.transparent,
                            onTap: () async {
                              if (!currentAstro.isOnline || currentAstro.isBusy) {
                                CustomSnackbar.showInfo(currentAstro.isBusy ? 'Astrologer is currently engaged.' : 'Astrologer is offline.');
                                return;
                              }
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(color: AppColors.deepPink),
                                ),
                              );
                              try {
                                final result = await PackageSessionService.startSubSession(
                                  astrologerId: currentAstro.userId,
                                  mode: 'chat',
                                );
                                Navigator.pop(context); // Dismiss loading dialog
                                Navigator.pop(context); // Dismiss bottom sheet
                                
                                activeSubSessionId = result.subSession.id;
                                
                                Get.to(() => ChatScreen(
                                  astrologerName: currentAstro.name,
                                  astrologerImage: currentAstro.profilePhoto != null ? '${AppUrls.baseImageUrl}${currentAstro.profilePhoto}' : '',
                                  sessionId: result.linkedChatSession!.id,
                                  initialStatus: 'initiated',
                                  isPackageChat: true,
                                ), binding: ChatBinding());
                              } catch (e) {
                                Navigator.pop(context); // Dismiss loading dialog
                                CustomSnackbar.showError(e.toString());
                              }
                            },
                          ),
                        ),
                      if (hasChat && hasCall)
                        const SizedBox(width: 12),
                      if (hasCall)
                        Expanded(
                          child: CustomButton(
                            text: currentAstro.isBusy ? 'Busy' : (!currentAstro.isOnline ? 'Offline' : AppStrings.call),
                            icon: Icons.call_outlined,
                            fontSize: 13,
                            height: 48,
                            borderRadius: 12,
                            backgroundColor: (!currentAstro.isOnline || currentAstro.isBusy) ? Colors.grey.withOpacity(0.2) : Colors.transparent,
                            textColor: (!currentAstro.isOnline || currentAstro.isBusy) ? Colors.grey : Colors.white,
                            borderColor: (!currentAstro.isOnline || currentAstro.isBusy) ? Colors.grey : Colors.transparent,
                            gradient: (!currentAstro.isOnline || currentAstro.isBusy) ? null : const LinearGradient(
                              colors: [
                                Color(0xFF4CAF50),
                                Color(0xFF388E3C),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () async {
                              if (!currentAstro.isOnline || currentAstro.isBusy) {
                                CustomSnackbar.showInfo(currentAstro.isBusy ? 'Astrologer is currently engaged.' : 'Astrologer is offline.');
                                return;
                              }
                              var permissionStatus = await Permission.microphone.status;
                              if (!permissionStatus.isGranted) {
                                permissionStatus = await Permission.microphone.request();
                              }
                              if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
                                await openAppSettings();
                                return;
                              }

                              if (permissionStatus.isGranted) {
                                Navigator.pop(context); // Dismiss bottom sheet
                                
                                final callController = Get.isRegistered<CallController>()
                                    ? Get.find<CallController>()
                                    : Get.put(CallController());
                                    
                                Get.to(() => const CallScreen());
                                
                                callController.initiateCall(
                                  providerId: currentAstro.userId,
                                  providerName: currentAstro.name,
                                  providerImage: currentAstro.profilePhoto != null ? '${AppUrls.baseImageUrl}${currentAstro.profilePhoto}' : '',
                                  isPackageSession: true,
                                );
                              } else {
                                CustomSnackbar.showError('Microphone permission is required for calling.');
                              }
                            },
                          ),
                        ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static void _showPurchaseConfirmationSheet(
    BuildContext context,
    AstrologerModel astro,
    double walletBalance,
    double requiredAmount,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        RxBool isPurchasing = false.obs;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            if (isPurchasing.value) {
              return SizedBox(
                height: 180,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.deepPink),
                      const SizedBox(height: 16),
                      Text("Purchasing package, please wait...".tr),
                    ],
                  ),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                AppText(
                  "Confirm Package Purchase".tr,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
                const SizedBox(height: 6),
                AppText(
                  "Would you like to purchase this session package for".tr + " ₹${astro.packagePrice ?? 500}?",
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Cancel".tr,
                        backgroundColor: Colors.grey.shade200,
                        textColor: Colors.grey.shade800,
                        borderColor: Colors.grey.shade200,
                        borderRadius: 12,
                        height: 48,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Purchase".tr,
                        borderRadius: 12,
                        height: 48,
                        onTap: () async {
                          isPurchasing.value = true;
                          try {
                            final response = await Get.find<ApiClient>().post(
                              AppUrls.purchasePackage,
                              data: {'astrologer_id': astro.userId},
                            );
                            if (response.isSuccess) {
                              CustomSnackbar.showSuccess("Package purchased successfully.".tr);
                              Navigator.pop(context);
                              // Refresh wallet balance
                              await Get.find<WalletController>().fetchWallet();
                              final astrologerController = Get.find<AstrologerController>();
                              await astrologerController.fetchAstrologers();
                              final updatedAstro = astrologerController.astrologers.firstWhere(
                                (a) => a.id == astro.id,
                                orElse: () => astro,
                              );
                              show(context, updatedAstro);
                            } else {
                              CustomSnackbar.showError(response.message);
                              isPurchasing.value = false;
                            }
                          } catch (e) {
                            CustomSnackbar.showError("Something went wrong during purchase.".tr);
                            isPurchasing.value = false;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            );
          }),
        );
      },
    );
  }
}

class PackageSessionService {
  static final ApiClient _apiClient = Get.find<ApiClient>();

  /// Check active package status & recovery
  static Future<ActiveStatusResponse> getActiveStatus(int astrologerId) async {
    final response = await _apiClient.get(
      AppUrls.packageActiveStatus,
      queryParameters: {'astrologer_id': astrologerId},
    );
    if (response.isSuccess) {
      final body = response.body;
      final Map<String, dynamic> data = (body is Map && body.containsKey('has_active_package'))
          ? Map<String, dynamic>.from(body)
          : (body is Map && body['data'] is Map ? Map<String, dynamic>.from(body['data']) : {});
      final purchase = data['package_purchase'] != null 
          ? PackagePurchase.fromJson(data['package_purchase']) 
          : null;
      if (purchase != null) {
        WebSocketService.packageRemainingSeconds.value = purchase.remainingDuration;
      }
      return ActiveStatusResponse(
        hasActivePackage: data['has_active_package'] ?? false,
        purchase: purchase,
        activeSubSession: data['active_sub_session'] != null 
            ? PackageSubSession.fromJson(data['active_sub_session']) 
            : null,
      );
    } else {
      throw Exception(response.message);
    }
  }

  /// Start a sub-session (mode: 'chat' | 'call')
  static Future<StartSubSessionResult> startSubSession({
    required int astrologerId,
    required String mode,
    String? question,
  }) async {
    final response = await _apiClient.post(
      AppUrls.packageSessionStart,
      data: {
        'astrologer_id': astrologerId,
        'mode': mode,
        if (question != null) 'question': question,
      },
    );
    if (response.isSuccess) {
      final Map<String, dynamic> data = response.body is Map<String, dynamic> 
          ? response.body 
          : {};
      final remainingDuration = int.tryParse(data['remaining_duration']?.toString() ?? '') ?? 0;
      WebSocketService.packageRemainingSeconds.value = remainingDuration;
      return StartSubSessionResult(
        subSession: PackageSubSession.fromJson(data['sub_session']),
        remainingDuration: remainingDuration,
        linkedChatSession: data['chat_session'] != null
            ? PackageChatSession.fromJson(data['chat_session'])
            : null,
        linkedCallSession: data['call_session'] != null
            ? PackageCallSession.fromJson(data['call_session'])
            : null,
      );
    } else {
      throw Exception(response.message);
    }
  }

  static int? activeSubSessionId;

  /// Spawn Dual-Subchannel (WhatsApp-Style Switch)
  static Future<Map<String, dynamic>> spawnChannel({
    required int subSessionId,
    required String channelType,
    String? callType,
    String? question,
  }) async {
    final response = await _apiClient.post(
      AppUrls.packageSpawnChannel,
      data: {
        'sub_session_id': subSessionId,
        'channel_type': channelType,
        if (callType != null) 'call_type': callType,
        if (question != null) 'question': question,
      },
    );
    if (response.isSuccess) {
      return response.body is Map<String, dynamic> ? response.body['data'] ?? {} : {};
    } else {
      throw Exception(response.message);
    }
  }

  /// Terminate channel
  static Future<Map<String, dynamic>> terminateChannel({
    required int subSessionId,
    required String channelType,
    required String action,
  }) async {
    final response = await _apiClient.post(
      AppUrls.packageTerminateChannel,
      data: {
        'sub_session_id': subSessionId,
        'channel_type': channelType,
        'action': action,
      },
    );
    if (response.isSuccess) {
      return response.body is Map<String, dynamic> ? response.body['data'] ?? {} : {};
    } else {
      throw Exception(response.message);
    }
  }

  /// End sub-session
  static Future<EndSubSessionResult> endSubSession(int subSessionId) async {
    final response = await _apiClient.post(
      AppUrls.packageSessionEnd,
      data: {'sub_session_id': subSessionId},
    );
    if (response.isSuccess) {
      final Map<String, dynamic> data = response.body is Map<String, dynamic> 
          ? response.body 
          : {};
      return EndSubSessionResult(
        subSession: PackageSubSession.fromJson(data['sub_session']),
        remainingDuration: data['remaining_duration'] ?? 0,
      );
    } else {
      throw Exception(response.message);
    }
  }
}


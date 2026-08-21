import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/features/call/presentation/widgets/floating_call_bubble.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CallController>();
    controller.isCallScreenVisible = true;
    FloatingCallBubble.dismiss();
  }

  @override
  void dispose() {
    controller.isCallScreenVisible = false;
    // Minimize to bubble if the call is still active
    if (controller.status.value == 'ongoing' || 
        controller.status.value == 'ringing' || 
        controller.status.value == 'dialing' || 
        controller.status.value == 'waiting') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.sessionId != null && controller.providerName != null) {
          controller.minimizeToBubble(Get.context!, controller.providerName!, controller.providerImage ?? "", shouldPop: false);
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final status = controller.status.value;
        final minutes = (controller.durationSeconds.value ~/ 60).toString().padLeft(2, '0');
        final seconds = (controller.durationSeconds.value % 60).toString().padLeft(2, '0');

        return Stack(
          fit: StackFit.expand,
          children: [
            // Blurred profile background
            if (controller.providerImage != null && controller.providerImage!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: controller.providerImage!.startsWith('http')
                    ? controller.providerImage!
                    : '${AppUrls.baseImageUrl}${controller.providerImage!.startsWith('/') ? controller.providerImage!.substring(1) : controller.providerImage}',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: AppColors.primaryColor.withValues(alpha: 0.8)),
              )
            else
              Container(color: AppColors.primaryColor.withValues(alpha: 0.8)),
            
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),

            // Main UI content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Bar: Title/Status & Switch to Chat action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                status == 'ongoing' ? 'Ongoing Call' : status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (status == 'ongoing')
                                Text(
                                  '$minutes:$seconds',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 12,
                          child: IconButton(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 26),
                            tooltip: "Switch to Chat",
                            onPressed: () => _showSwitchToChatDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Middle Profile Display
                  Column(
                    children: [
                      // Pulsing avatar
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildPulseCircle(delay: 0),
                          _buildPulseCircle(delay: 1),
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.white24,
                            child: CircleAvatar(
                              radius: 66,
                              backgroundImage: controller.providerImage != null && controller.providerImage!.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      controller.providerImage!.startsWith('http')
                                          ? controller.providerImage!
                                          : '${AppUrls.baseImageUrl}${controller.providerImage!.startsWith('/') ? controller.providerImage!.substring(1) : controller.providerImage}'
                                    )
                                  : null,
                              child: controller.providerImage == null || controller.providerImage!.isEmpty
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        controller.providerName ?? 'Astrologer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status == 'ringing' ? 'Ringing...' : (status == 'waiting' ? 'Waiting in queue...' : 'Connecting P2P...'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute button
                        _buildControlButton(
                          icon: controller.isMuted.value ? Icons.mic_off : Icons.mic,
                          label: 'Mute',
                          isActive: controller.isMuted.value,
                          onPressed: () => controller.toggleMute(),
                        ),

                        _buildEndCallButton(onPressed: () {
                          if (controller.status.value == 'ongoing') {
                            controller.endCall();
                          } else {
                            controller.cancelCall();
                          }
                          Get.back();
                        }),

                        // Speaker button
                        _buildControlButton(
                          icon: controller.isSpeakerOn.value ? Icons.volume_up : Icons.volume_down,
                          label: 'Speaker',
                          isActive: controller.isSpeakerOn.value,
                          onPressed: () => controller.toggleSpeaker(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showSwitchToChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.chat_bubble_rounded, color: AppColors.primaryColor, size: 22),
            SizedBox(width: 10),
            Text('Switch to Chat', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'End the current call and start a chat session with ${controller.providerName ?? "Astrologer"}?',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _switchToChat();
            },
            icon: const Icon(Icons.chat_bubble_rounded, size: 16),
            label: const Text('Switch'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchToChat() async {
    final providerId = controller.providerId;
    final providerName = controller.providerName ?? 'Astrologer';
    final providerImage = controller.providerImage ?? '';

    // End call first
    if (controller.status.value == 'ongoing') {
      await controller.endCall();
    } else {
      await controller.cancelCall();
    }
    Get.back(); // Pop CallScreen

    // Show loading and call chat initiate
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        AppUrls.initiateChat,
        data: {'provider_id': providerId},
      );
      Get.back(); // close loader

      if (response.isSuccess) {
        CustomSnackbar.showSuccess(response.message);
        
        int sessionId = 0;
        if (response.body != null && response.body is Map) {
          final sessionData = response.body['session'];
          if (sessionData != null && sessionData is Map) {
            sessionId = int.tryParse(sessionData['id']?.toString() ?? '') ?? 0;
          }
        }
        
        Get.to(() => ChatScreen(
          astrologerName: providerName,
          astrologerImage: providerImage,
          sessionId: sessionId,
          initialStatus: 'initiated',
        ), binding: ChatBinding());
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      Get.back(); // close loader
      CustomSnackbar.showError(e.toString());
    }
  }

  Widget _buildPulseCircle({required int delay}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 1.0, end: 1.8),
      duration: Duration(seconds: 2 + delay),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Container(
          width: 140 * value,
          height: 140 * value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: (0.15 * (2.0 - value))),
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.white12,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primaryColor : Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEndCallButton({required VoidCallback onPressed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'End',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

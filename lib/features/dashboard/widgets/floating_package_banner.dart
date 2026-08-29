import 'dart:async';
import 'package:astro_user/core/services/network/websocket_service.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_image_widget.dart';

class FloatingPackageBannerWidget extends StatefulWidget {
  const FloatingPackageBannerWidget({Key? key}) : super(key: key);

  @override
  State<FloatingPackageBannerWidget> createState() =>
      _FloatingPackageBannerWidgetState();
}

class _FloatingPackageBannerWidgetState
    extends State<FloatingPackageBannerWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (WebSocketService.packageRemainingSeconds.value > 0) {
        WebSocketService.packageRemainingSeconds.value--;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '00:00';
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final channel =
            WebSocketService.packageActiveChannel.value.toLowerCase();
        if (channel == 'chat' || channel == 'text') {
          if (FloatingChatBubble.onTapCallback != null) {
            FloatingChatBubble.onTapCallback?.call();
          }
        } else if (channel == 'call' ||
            channel == 'audio' ||
            channel == 'video') {
          if (FloatingCallBubble.onTapCallback != null) {
            FloatingCallBubble.onTapCallback?.call();
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.deepPink.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepPink.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Obx(() {
              final avatar = WebSocketService.packageAstrologerAvatar.value;
              if (avatar.isNotEmpty) {
                return CustomImageWidget(
                  imagePath: avatar,
                  height: 40,
                  width: 40,
                  radius: BorderRadius.circular(20),
                );
              }
              return const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              );
            }),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      WebSocketService.packageAstrologerName.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Obx(() {
                    final channel =
                        WebSocketService.packageActiveChannel.value
                            .toLowerCase();
                    final isChat = channel == 'chat' || channel == 'text';
                    return Row(
                      children: [
                        Icon(
                          isChat
                              ? Icons.chat_bubble_outline
                              : Icons.call_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Active Package',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppColors.deepPink,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Obx(
                    () => Text(
                      _formatDuration(
                        WebSocketService.packageRemainingSeconds.value,
                      ),
                      style: const TextStyle(
                        color: AppColors.deepPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

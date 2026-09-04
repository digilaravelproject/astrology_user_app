import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';
import 'package:astro_user/core/widgets/custom_text_field.dart';
import 'package:astro_user/core/widgets/network_ping_indicator.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_user/features/chat/domain/entities/chat_message.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_user/features/call/presentation/pages/call_screen.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:astro_user/core/utils/session_bottom_sheet_helper.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'package:astro_user/features/kundli/kundli_screen.dart';
import 'package:astro_user/features/auth/presentation/controllers/auth_controller.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatScreen extends StatefulWidget {
  final String astrologerName;
  final String astrologerImage;
  final int sessionId;
  final String initialStatus;
  final String? startedAtString;

  final bool isPackageChat;

  const ChatScreen({
    super.key,
    required this.astrologerName,
    required this.astrologerImage,
    required this.sessionId,
    required this.initialStatus,
    this.startedAtString,
    this.isPackageChat = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late final ChatController _controller;
  late AnimationController _pulseController;
  late AnimationController _dotController;
  late Animation<double> _pulse1;
  late Animation<double> _pulse2;
  late Animation<double> _pulse3;

  @override
  void initState() {
    super.initState();
    // Retrieve or instantiate controller safely
    if (!Get.isRegistered<ChatController>()) {
      ChatBinding().dependencies();
    }
    _controller = Get.find<ChatController>();
    _controller.isPackageChat = widget.isPackageChat;
    _controller.initSession(
      sessionId: widget.sessionId,
      currentUserId: 0,
      initialStatus: widget.initialStatus,
      astrologerName: widget.astrologerName,
      startedAtString: widget.startedAtString,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulse1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _pulse2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
    _pulse3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller.status.value == 'ongoing' || _controller.status.value == 'initiated') {
          _controller.minimizeToBubble(
            context,
            widget.astrologerName,
            widget.astrologerImage,
            shouldPop: false,
          );
          // Return true to allow system back to pop the screen
          return true;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: widget.astrologerName,
          centerTitle: false,
          showLeading: true,
          onLeadingPressed: () {
            if (_controller.status.value == 'ongoing' || _controller.status.value == 'initiated') {
              _controller.minimizeToBubble(
                context,
                widget.astrologerName,
                widget.astrologerImage,
                shouldPop: true,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
          actions: [
            Obx(() {
              if (_controller.status.value == 'ongoing') {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NetworkPingIndicator(pingMs: _controller.currentPingMs.value),
                    const SizedBox(width: 8),
                    // Call switch icon ONLY for package/session chats
                    if (widget.isPackageChat)
                      IconButton(
                        icon: const Icon(Icons.swap_calls_rounded, color: Colors.green, size: 26),
                        tooltip: "Switch to Call",
                        onPressed: () => _showSwitchToCallConfirmation(context),
                      ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(right: 16), // Adjusted right margin to 16
                      child: InkWell(
                        onTap: () => _showEndChatConfirmation(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: const AppText(
                            "End Chat",
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (widget.isPackageChat && details.primaryVelocity != null) {
              if (details.primaryVelocity! < -300 || details.primaryVelocity! > 300) {
                _showSwitchToCallConfirmation(context);
              }
            }
          },
          child: Container(
            decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
              opacity: 0.12,
            ),
          ),
          child: Column(
            children: [
            // Timer / Status Bar
            Obx(() {
              final seconds = _controller.elapsedSeconds.value;
              final status = _controller.status.value.toLowerCase();
              final isEnded = status == 'ended' || status == 'completed' || status == 'cancelled' || status == 'rejected';
              final isInitiated = status == 'initiated';

              if (isInitiated) return const SizedBox.shrink();

              String statusText = "Chat has ended";
              if (status == 'ongoing') {
                statusText = "Chat in progress • ${_formatDuration(seconds)}";
              } else if (status == 'cancelled') {
                statusText = "Chat Cancelled";
              } else if (status == 'rejected') {
                statusText = "Chat Rejected";
              } else if (status == 'completed') {
                statusText = "Chat Completed";
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: isEnded ? Colors.grey.shade300 : AppColors.lightPink.withOpacity(0.3),
                child: Center(
                  child: AppText(
                    statusText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isEnded ? Colors.black54 : AppColors.deepPink,
                  ),
                ),
              );
            }),

            // Messages List
            Expanded(
              child: Obx(() {
                final st = _controller.status.value.toLowerCase();
                final isInitiated = (st == 'initiated' || st == 'ringing') && st != 'ongoing' && st != 'accepted';
                if (isInitiated) {
                  return _buildRingingScreen();
                }

                if (_controller.isLoading.value && _controller.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  controller: _controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true, // Show latest messages at bottom
                  itemCount: _controller.messages.length,
                  itemBuilder: (context, index) {
                    // Reverse index for display
                    final message = _controller.messages[_controller.messages.length - 1 - index];
                    final isMe = message.isMe;
                    final status = message.status;
                    
                    bool isReply = false;
                    String replyUser = '';
                    String replyText = '';
                    String mainText = message.text;
                    
                    if (message.replyTo != null) {
                      isReply = true;
                      replyUser = message.replyTo!.isMe ? 'You' : widget.astrologerName;
                      replyText = message.replyTo!.text;
                    } else if (message.replyToId != null && message.replyToId != 0) {
                      final originalMsg = _controller.messages.firstWhereOrNull((m) => m.id == message.replyToId);
                      if (originalMsg != null) {
                        isReply = true;
                        replyUser = originalMsg.isMe ? 'You' : widget.astrologerName;
                        replyText = originalMsg.text;
                      }
                    } else if (mainText.startsWith('>>reply>>')) {
                      // Fallback for old cached messages
                      isReply = true;
                      final endQuote = mainText.indexOf('<<reply<<');
                      if (endQuote != -1) {
                        final quotePart = mainText.substring(9, endQuote);
                        final colonIdx = quotePart.indexOf(': ');
                        if (colonIdx != -1) {
                          replyUser = quotePart.substring(0, colonIdx);
                          replyText = quotePart.substring(colonIdx + 2);
                        } else {
                          replyText = quotePart;
                        }
                        mainText = mainText.substring(endQuote + 9).trimLeft();
                      } else {
                        final quotePart = mainText.substring(9);
                        final colonIdx = quotePart.indexOf(': ');
                        if (colonIdx != -1) {
                          replyUser = quotePart.substring(0, colonIdx);
                          replyText = quotePart.substring(colonIdx + 2);
                        } else {
                          replyUser = 'User';
                          replyText = quotePart;
                        }
                        mainText = '';
                      }
                    }

                    if (replyText.startsWith('>>reply>>')) {
                      final endQuote = replyText.indexOf('<<reply<<');
                      if (endQuote != -1) {
                        replyText = replyText.substring(endQuote + 9).trimLeft();
                      }
                    }

                    return SwipeTo(
                      key: ValueKey('user_chat_msg_${message.id}_${message.time.millisecondsSinceEpoch}_$index'),
                      onRightSwipe: (details) {
                        _controller.setReply(message);
                      },
                      onLeftSwipe: (details) {
                        _controller.setReply(message);
                      },
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.deepPink : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (isReply)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border(left: BorderSide(color: isMe ? Colors.white : AppColors.deepPink, width: 4)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppText(replyUser, color: isMe ? Colors.white : AppColors.deepPink, fontWeight: FontWeight.bold, fontSize: 12),
                                      const SizedBox(height: 4),
                                      AppText(replyText, color: isMe ? Colors.white70 : Colors.black87, fontSize: 12, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              if (message.type == 'image')
                                ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: message.image != null && message.image!.startsWith('http')
                                    ? Image.network(
                                        message.image!,
                                        height: 150,
                                        width: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : (message.image != null && File(message.image!).existsSync()
                                        ? Image.file(
                                            File(message.image!),
                                            height: 150,
                                            width: 200,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            message.attachmentUrl != null && message.attachmentUrl!.startsWith('http')
                                                ? message.attachmentUrl!
                                                : '${AppUrls.baseImageUrl}${message.attachmentUrl ?? ""}',
                                            height: 150,
                                            width: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Container(
                                              height: 150,
                                              width: 200,
                                              color: Colors.grey,
                                              child: const Icon(Icons.broken_image, color: Colors.white),
                                            ),
                                          )),
                              )
                            else if (message.type == 'document')
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Iconsax.document, color: Colors.black54, size: 24),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: AppText(
                                        mainText.replaceFirst('📄 ', ''),
                                        fontSize: 14,
                                        color: Colors.black87,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (mainText.isNotEmpty)
                              AppText(
                                mainText,
                                fontSize: 14,
                                color: isMe ? Colors.white : Colors.black87,
                                height: 1.4,
                              ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText(
                                  "${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')} ${message.time.hour >= 12 ? 'pm' : 'am'}",
                                  fontSize: 10,
                                  color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    status == 'sending...'
                                        ? Icons.access_time
                                        : status == 'sent'
                                            ? Icons.check
                                            : Icons.done_all,
                                    size: 16,
                                    color: (status == 'seen' || status == 'read')
                                        ? Colors.blueAccent
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      )
                    );
                  },
                );
              }),
            ),

            // Input Area
            Obx(() {
              final status = _controller.status.value.toLowerCase();
              final isEnded = status == 'ended' || status == 'completed' || status == 'cancelled' || status == 'rejected';
              final isInitiated = status == 'initiated';
              if (isEnded || isInitiated) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_controller.replyingToMessage.value != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(left: BorderSide(color: AppColors.deepPink, width: 4)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      _controller.replyingToMessage.value!.isMe ? 'You' : widget.astrologerName,
                                      color: AppColors.deepPink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    const SizedBox(height: 4),
                                    AppText(
                                      _controller.replyingToMessage.value!.text.replaceAll('\n', ' '),
                                      color: Colors.black87,
                                      fontSize: 12,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                                onPressed: () => _controller.cancelReply(),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                            onPressed: _showAttachmentBottomSheet,
                          ),
                          IconButton(
                            icon: const Icon(Icons.auto_awesome, color: AppColors.deepPink),
                            onPressed: _openKundli,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller.messageController,
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _controller.sendTextMessage(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.deepPink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.send_1_copy, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        ),
      ),
    ));
  }

  Widget _buildRingingScreen() {
    return Container(
      color: const Color(0xFFF8F4FF),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chat bubble icon with pulsing ring
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing ring
                AnimatedBuilder(
                  animation: _dotController,
                  builder: (context, child) {
                    final pulse = ((_dotController.value * 2) % 1.0);
                    return Container(
                      width: 148 + pulse * 20,
                      height: 148 + pulse * 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepPink.withOpacity(0.07 - pulse * 0.05),
                      ),
                    );
                  },
                ),
                // Inner ring
                Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepPink.withOpacity(0.12),
                  ),
                ),
                // Avatar circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepPink.withOpacity(0.18),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: widget.astrologerImage.isNotEmpty
                      ? Image.network(
                          widget.astrologerImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              widget.astrologerName.isNotEmpty
                                  ? widget.astrologerName.substring(0, 1).toUpperCase()
                                  : 'A',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepPink,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            widget.astrologerName.isNotEmpty
                                ? widget.astrologerName.substring(0, 1).toUpperCase()
                                : 'A',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepPink,
                            ),
                          ),
                        ),
                ),
                // Chat badge at bottom-right
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.deepPink,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Astrologer name
            Text(
              widget.astrologerName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 6),

            // "Chat request sent" label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.deepPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Chat Request Sent',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.deepPink,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Fake chat bubbles to hint chat context
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // User bubble
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.deepPink,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Namaste, mujhe aapki guidance chahiye...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Typing indicator bubble
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _dotController,
                        builder: (context, child) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDot(0),
                              _buildDot(1),
                              _buildDot(2),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // "Waiting for astrologer to accept" animated text
            AnimatedBuilder(
              animation: _dotController,
              builder: (context, child) {
                return Text(
                  'Waiting for astrologer to accept',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Cancel request button
            GestureDetector(
              onTap: () => _controller.cancelChatSession(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.red.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close_rounded, color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Cancel Request',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final progress = _dotController.value;
    final delay = index * 0.25;
    final adjustedProgress = ((progress - delay) % 1.0 + 1.0) % 1.0;
    final opacity = adjustedProgress < 0.5
        ? adjustedProgress * 2
        : 1.0 - ((adjustedProgress - 0.5) * 2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Opacity(
        opacity: opacity.clamp(0.2, 1.0),
        child: Text(
          '.',
          style: TextStyle(
            fontSize: 22,
            color: AppColors.deepPink,
            fontWeight: FontWeight.bold,
            height: 0.9,
          ),
        ),
      ),
    );
  }

  void _showEndChatConfirmation(BuildContext context) {
    if (widget.isPackageChat && _controller.isCallAlsoActive) {
      _showGranularEndModal(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("End Chat"),
          content: const Text("Are you sure you want to end this chat session?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.terminateEntireSession();
              },
              child: const Text("End Chat", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  void _showGranularEndModal(BuildContext context) {
    final rem = WebSocketService.packageRemainingSeconds.value;
    final m = (rem ~/ 60).toString().padLeft(2, '0');
    final s = (rem % 60).toString().padLeft(2, '0');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Title
            const Row(
              children: [
                Icon(Icons.help_outline_rounded, color: Color(0xFF6B21A8), size: 22),
                SizedBox(width: 8),
                Text(
                  'End Consultation Options',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Package time remaining: $m:$s',
                style: TextStyle(fontSize: 13, color: Colors.orange.shade700, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: End Chat Only
            _buildEndOption(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: Colors.blue.shade700,
              bgColor: Colors.blue.shade50,
              title: 'End Chat Only (Continue Calling)',
              subtitle: 'Closes chat window and returns you to the call.',
              onTap: () {
                Navigator.of(ctx).pop();
                _controller.terminateChannelOnly();
              },
            ),
            const SizedBox(height: 12),

            // Option 2: End Entire Session
            _buildEndOption(
              icon: Icons.cancel_rounded,
              iconColor: Colors.red,
              bgColor: Colors.red.shade50,
              title: 'End Entire Session',
              subtitle: 'Completes consultation and finalises package time.',
              onTap: () {
                Navigator.of(ctx).pop();
                _controller.terminateEntireSession();
              },
            ),
            const SizedBox(height: 12),

            // Option 3: Cancel
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }


  void _showSwitchToCallConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Switch to Call"),
        content: const Text("Are you sure you want to end this chat session and switch to a call?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              
              // Show loader
              Get.dialog(
                const Center(child: CircularProgressIndicator(color: AppColors.deepPink)),
                barrierDismissible: false,
              );

              try {
                int subSessionId = PackageSessionService.activeSubSessionId ?? 0;
                
                if (subSessionId > 0) {
                  await PackageSessionService.spawnChannel(
                    subSessionId: subSessionId,
                    channelType: 'call',
                    callType: 'audio',
                  );
                }

                int providerId = _controller.peerId ?? 0;

                if (providerId <= 0) {
                  final apiClient = Get.find<ApiClient>();
                  final response = await apiClient.get(AppUrls.getCurrentSession);
                  
                  if (response.isSuccess && response.body['data'] != null) {
                    final data = response.body['data'];
                    final session = (data is Map && data.containsKey('session')) ? data['session'] : data;
                    providerId = int.tryParse(session?['provider_id']?.toString() ?? '') ?? 0;
                  }
                }
                
                if (providerId > 0) {
                  // If not package session, end chat session cleanly
                  if (subSessionId <= 0) {
                    await _controller.endChatSession(skipSummary: true);
                  }
                  
                  // Close loader dialog
                  if (Get.isDialogOpen ?? false) Get.back();

                  // Initiate call
                  final callController = Get.find<CallController>();
                  
                  await callController.initiateCall(
                    providerId: providerId,
                    providerName: widget.astrologerName,
                    providerImage: widget.astrologerImage,
                    isPackageSession: widget.isPackageChat,
                  );

                  // Navigate to CallScreen so user sees ringing UI
                  Get.to(() => const CallScreen());
                  return;
                }
                
                Get.back(); // close loader
                CustomSnackbar.showError("Failed to switch: active session details not found.");
              } catch (e) {
                Get.back(); // close loader
                CustomSnackbar.showError("Failed to switch: $e");
              }
            },
            child: const Text(
              "Switch",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      _controller.sendImageAttachment(image);
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      _controller.sendDocumentAttachment(result.files.single);
    }
  }

  Future<void> _openKundli() async {
    String name = '';
    String gender = '';
    String dob = '';
    String tob = '';
    String place = '';
    double lat = 0.0;
    double lng = 0.0;

    // 1. Check messages loaded in ChatController for system message with birth details
    for (final msg in _controller.messages) {
      final content = msg.text;
      if (content.contains('Birth Details:') || content.contains('Date of Birth:')) {
        final lines = content.split('\n');
        for (final line in lines) {
          final trimmed = line.trim().replaceAll(RegExp(r'^-\s*'), '');
          final lower = trimmed.toLowerCase();
          if (lower.startsWith('name:')) {
            name = trimmed.substring(5).trim();
          } else if (lower.startsWith('date of birth:')) {
            dob = trimmed.substring(14).trim();
          } else if (lower.startsWith('time of birth:')) {
            tob = trimmed.substring(14).trim();
          } else if (lower.startsWith('place of birth:')) {
            place = trimmed.substring(15).trim();
          } else if (lower.startsWith('latitude:')) {
            lat = double.tryParse(trimmed.substring(9).trim()) ?? 0.0;
          } else if (lower.startsWith('longitude:')) {
            lng = double.tryParse(trimmed.substring(10).trim()) ?? 0.0;
          } else if (lower.startsWith('gender:')) {
            gender = trimmed.substring(7).trim();
          }
        }
        if (dob.isNotEmpty) break;
      }
    }

    // 2. Fetch logged-in user profile if still empty
    if (dob.isEmpty) {
      if (Get.isRegistered<AuthController>()) {
        final currentUser = Get.find<AuthController>().currentUser.value;
        if (currentUser != null) {
          name = currentUser.name;
          gender = currentUser.gender ?? '';
          dob = currentUser.dateOfBirth ?? '';
          tob = currentUser.timeOfBirth ?? '';
          place = currentUser.placeOfBirth ?? '';
        }
      }
    }

    if (dob.isNotEmpty) {
      if (tob.length == 5) tob += ":00";
      Get.to(() => KundliScreen(
        fullName: name,
        gender: gender.isEmpty ? 'Male' : gender,
        dob: dob,
        tob: tob.isNotEmpty ? tob : '00:00:00',
        place: place.isEmpty ? 'India' : place,
        latitude: lat,
        longitude: lng,
      ));
    } else {
      CustomSnackbar.showError("Birth details not found. Please complete profile.");
    }
  }

  void _showAttachmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Iconsax.camera,
                  color: Colors.blue,
                  label: "Camera",
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Iconsax.gallery,
                  color: Colors.purple,
                  label: "Gallery",
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  icon: Iconsax.document,
                  color: Colors.orange,
                  label: "Document",
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickDocument();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          AppText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}

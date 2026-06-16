import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../astrologers/controllers/astrologer_controller.dart';
import '../../../astrologers/domain/models/gift_model.dart' as model;
import '../controllers/live_controller.dart';
import '../../data/models/live_session_model.dart';

class LiveRoomScreen extends StatefulWidget {
  final int sessionId;
  final String astrologerName;
  final String astrologerImage;

  const LiveRoomScreen({
    super.key,
    required this.sessionId,
    this.astrologerName = "Priya Sharma",
    this.astrologerImage = "",
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  late LiveController _liveController;
  final AstrologerController _giftController = Get.find<AstrologerController>();
  
  final List<Widget> _reactions = [];
  final TextEditingController _commentController = TextEditingController();
  model.GiftModel? _selectedGift;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlayerInitialized = false;
  Worker? _sessionWorker;

  @override
  void initState() {
    super.initState();
    _liveController = Get.find<LiveController>();
    
    // Join the session
    _liveController.joinSession(widget.sessionId);
    
    // Fetch gifts listing
    _giftController.fetchGifts();

    // Listen to session changes to get stream_url
    _sessionWorker = ever(_liveController.currentSession, (session) {
      if (session != null && session.streamUrl != null && !_isPlayerInitialized) {
        _initializeVideoPlayer(session.streamUrl!);
      }
    });
  }

  Future<void> _initializeVideoPlayer(String url) async {
    if (_isPlayerInitialized) return;
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      );
      setState(() {
        _isPlayerInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing live stream video player: $e');
    }
  }

  @override
  void dispose() {
    _sessionWorker?.dispose();
    _liveController.leaveSession(widget.sessionId);
    _commentController.dispose();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _showGiftSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          AppStrings.sendAGift,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (_giftController.isGiftsLoading.value) {
                         return const Center(child: CircularProgressIndicator(color: Colors.orange));
                      }
                      if (_giftController.gifts.isEmpty) {
                         return const Center(child: Text("No gifts available", style: TextStyle(color: Colors.white70)));
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _giftController.gifts.length,
                        itemBuilder: (context, index) {
                          final gift = _giftController.gifts[index];
                          final isSelected = _selectedGift == gift;
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                _selectedGift = gift;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.orange : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomImageWidget(
                                    imagePath: gift.iconUrl,
                                    height: 35,
                                    width: 35,
                                    fit: BoxFit.contain,
                                    fallbackWidget: const Icon(Icons.card_giftcard, color: Colors.orange, size: 28),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    gift.title,
                                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.monetization_on, color: Colors.orange, size: 10),
                                      const SizedBox(width: 2),
                                      Text(
                                        gift.price,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _selectedGift == null ? null : () async {
                          Navigator.pop(context);
                          final int giftId = _selectedGift!.id;
                          await _liveController.sendSuperChat(widget.sessionId, giftId, "Sent a ${_selectedGift!.title} 🎉");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          disabledBackgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Obx(() => (_liveController.isSendingSuperChat.value)
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _selectedGift == null ? AppStrings.selectAGift : "${AppStrings.sendGiftAction} ${_selectedGift!.title}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addReaction() {
    setState(() {
      _reactions.add(
        const FloatingReaction(),
      );
    });
    Timer(const Duration(seconds: 3), () {
      if (mounted && _reactions.isNotEmpty) {
        setState(() {
          _reactions.removeAt(0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live camera stream backdrop / video player
          Positioned.fill(
            child: _isPlayerInitialized && _chewieController != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _videoPlayerController!.value.size.width,
                      height: _videoPlayerController!.value.size.height,
                      child: Chewie(controller: _chewieController!),
                    ),
                  )
                : Obx(() {
                    final currentSession = _liveController.currentSession.value;
                    final image = currentSession?.astrologer?.profilePhoto ?? widget.astrologerImage;
                    return CustomImageWidget(
                      imagePath: image.isNotEmpty ? image : "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1000&auto=format&fit=crop", 
                      fit: BoxFit.cover,
                    );
                  }),
          ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.2, 0.7, 1.0],
                ),
              ),
            ),
          ),

          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: Column(
              children: [
                // Header details
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildCircleActionIcon(Icons.arrow_back, () => Navigator.pop(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                _buildAstrologerAvatar(),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Obx(() => AppText(
                                              _liveController.currentSession.value?.astrologer?.name ?? widget.astrologerName,
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildViewerCount(),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Comments feed & comment bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scrollable real-time comments list
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.25,
                        ),
                        child: _buildChatList(),
                      ),
                      const SizedBox(height: 12),
                      
                      // Input controls
                      Row(
                        children: [
                          Expanded(
                            child: _buildCommentInput(),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showGiftSheet,
                            child: _buildCircleIconButton(Icons.wallet_giftcard_rounded, Colors.white),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _addReaction,
                            child: _buildCircleIconButton(Icons.favorite, Colors.red, isHeart: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // floating reactions
          Positioned(
            right: 20,
            bottom: 80,
            child: SizedBox(
              width: 50,
              height: 300,
              child: Stack(
                clipBehavior: Clip.none,
                children: _reactions,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleActionIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildAstrologerAvatar() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Obx(() {
          final currentSession = _liveController.currentSession.value;
          final image = currentSession?.astrologer?.profilePhoto ?? widget.astrologerImage;
          return CircleAvatar(
            radius: 17,
            backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
            child: image.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
          );
        }),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            AppStrings.liveBadge,
            style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildViewerCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Obx(() {
            final count = _liveController.currentSession.value?.viewerCount ?? 0;
            return Text(
              '$count',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Obx(() {
        final reversedComments = _liveController.comments.reversed.toList();
        return ListView.builder(
          shrinkWrap: true,
          reverse: true,
          padding: EdgeInsets.zero,
          itemCount: reversedComments.length,
          itemBuilder: (context, index) {
            final comment = reversedComments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: (comment.userAvatar != null && comment.userAvatar!.isNotEmpty) 
                        ? NetworkImage(comment.userAvatar!) 
                        : null,
                    child: (comment.userAvatar == null || comment.userAvatar!.isEmpty)
                        ? const Icon(Icons.person, size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          comment.userName,
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        AppText(
                          comment.message,
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              onSubmitted: (val) {
                _liveController.sendComment(widget.sessionId, val);
                _commentController.clear();
              },
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: AppStrings.typeYourComment,
                hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                border: InputBorder.none,
                filled: false,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _liveController.sendComment(widget.sessionId, _commentController.text);
              _commentController.clear();
            },
            child: Icon(Icons.send_rounded, color: Colors.white.withOpacity(0.5), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, Color color, {bool isHeart = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Icon(
        icon, 
        color: isHeart ? Colors.red : (icon == Icons.wallet_giftcard_rounded ? Colors.blueAccent : Colors.white), 
        size: 24
      ),
    );
  }
}

class FloatingReaction extends StatefulWidget {
  const FloatingReaction({super.key});

  @override
  State<FloatingReaction> createState() => _FloatingReactionState();
}

class _FloatingReactionState extends State<FloatingReaction> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _startX;

  @override
  void initState() {
    super.initState();
    _startX = (DateTime.now().millisecond % 30).toDouble();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double value = _animation.value;
        final double y = -300 * value;
        final double x = _startX + (20 * (value < 0.5 ? value : 1 - value)); // Sway
        final double opacity = 1.0 - value;
        final double scale = 0.5 + (0.5 * value);

        return Positioned(
          bottom: 16 - y,
          left: x,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: const Icon(Icons.favorite, color: Colors.red, size: 24),
            ),
          ),
        );
      },
    );
  }
}

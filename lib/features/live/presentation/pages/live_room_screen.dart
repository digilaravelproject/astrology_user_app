import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_image_widget.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../astrologers/controllers/astrologer_controller.dart';
import '../../../astrologers/domain/models/gift_model.dart' as model;
import '../controllers/live_controller.dart';
import '../../data/models/live_session_model.dart';
import '../../../../core/services/network/websocket_service.dart';
import '../../../../core/constants/app_urls.dart';

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

  Room? _room;
  VideoTrack? _remoteVideoTrack;
  bool _isLiveKitConnected = false;
  Worker? _sessionWorker;
  Worker? _mediaWorker;
  bool _isSpeakerMuted = false;
  bool _isSendingComment = false;

  void _toggleSpeakerMute() async {
    final room = _room;
    setState(() {
      _isSpeakerMuted = !_isSpeakerMuted;
    });
    
    if (room == null) return;
    
    for (var participant in room.remoteParticipants.values) {
      for (var publication in participant.audioTrackPublications) {
        try {
          if (_isSpeakerMuted) {
            await publication.unsubscribe();
          } else {
            await publication.subscribe();
          }
        } catch (e) {
          debugPrint('[LIVE] Error toggling subscription: $e');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _liveController = Get.find<LiveController>();
    
    // Fetch gifts listing
    _giftController.fetchGifts();

    // Subscribe to dynamic websocket channel FIRST (must complete before join API)
    try {
      final ws = Get.find<WebSocketService>();
      ws.subscribeToChannel('presence-live-session.${widget.sessionId}');
    } catch (e) {
      debugPrint('[LIVE] Error subscribing to websocket channel: $e');
    }

    // Join the session AFTER websocket subscription
    _liveController.joinSession(widget.sessionId);

    // Listen to session changes to connect to LiveKit
    _sessionWorker = ever(_liveController.currentSession, (session) {
      if (session != null) {
        if (session.isBroadcasting && !_isLiveKitConnected) {
          _connectLiveKit(session.id);
        } else if (!session.isBroadcasting && _isLiveKitConnected) {
          _disconnectLiveKit();
        }
      }
    });

    _mediaWorker = ever(_liveController.isAudioOn, (isAudioOn) async {
      final room = _room;
      if (room == null) return;
      for (var participant in room.remoteParticipants.values) {
        for (var publication in participant.audioTrackPublications) {
          try {
            if (!isAudioOn || _isSpeakerMuted) {
              await publication.unsubscribe();
            } else {
              await publication.subscribe();
            }
          } catch (e) {
            debugPrint('[LIVE] Error auto-toggling audio track: $e');
          }
        }
      }
    });
  }

  Future<void> _connectLiveKit(int sessionId) async {
    if (_isLiveKitConnected || _room != null) return;
    
    final watchData = await _liveController.watchLiveSession(sessionId);
    if (watchData == null) {
      debugPrint('[LIVE] Watch data is null. Astrologer might not be broadcasting yet.');
      return;
    }
    
    final String wsUrl = watchData['livekit_ws_url'] ?? '';
    final String token = watchData['token'] ?? '';
    
    if (wsUrl.isEmpty || token.isEmpty) {
      debugPrint('[LIVE] wsUrl or token is empty');
      return;
    }
    
    try {
      debugPrint('[LIVE] Connecting to LiveKit room: $wsUrl');
      final room = Room();
      await room.connect(
        wsUrl,
        token,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );
      
      _room = room;
      if (mounted) {
        setState(() {
          _isLiveKitConnected = true;
        });
      }
      
      // Find already subscribed tracks and apply speaker mute status
      for (var participant in room.remoteParticipants.values) {
        for (var trackPublication in participant.audioTrackPublications) {
          if (_isSpeakerMuted || !_liveController.isAudioOn.value) {
            trackPublication.unsubscribe();
          }
        }
        for (var trackPublication in participant.videoTrackPublications) {
          if (trackPublication.subscribed && trackPublication.track != null) {
            if (mounted) {
              setState(() {
                _remoteVideoTrack = trackPublication.track as VideoTrack?;
              });
            }
          }
        }
      }
      
      // Listen to events
      final listener = room.createListener();
      listener.on<TrackSubscribedEvent>((event) {
        if (event.track is VideoTrack && mounted) {
          setState(() {
            _remoteVideoTrack = event.track as VideoTrack?;
          });
        } else if (event.track is AudioTrack) {
          if (_isSpeakerMuted || !_liveController.isAudioOn.value) {
            event.publication.unsubscribe();
          }
        }
      });
      
      listener.on<TrackUnsubscribedEvent>((event) {
        if (event.track == _remoteVideoTrack && mounted) {
          setState(() {
            _remoteVideoTrack = null;
          });
        }
      });
      
      listener.on<RoomDisconnectedEvent>((event) {
        debugPrint('[LIVE] LiveKit room disconnected');
        _disconnectLiveKit();
      });
      
    } catch (e) {
      debugPrint('[LIVE] LiveKit connection error: $e');
      _disconnectLiveKit();
    }
  }

  void _disconnectLiveKit() {
    _room?.disconnect();
    _room = null;
    if (mounted) {
      setState(() {
        _isLiveKitConnected = false;
        _remoteVideoTrack = null;
      });
    }
  }

  @override
  void dispose() {
    _sessionWorker?.dispose();
    _mediaWorker?.dispose();
    _disconnectLiveKit();
    _liveController.leaveSession(widget.sessionId);
    _commentController.dispose();
    try {
      final ws = Get.find<WebSocketService>();
      ws.unsubscribeFromChannel('presence-live-session.${widget.sessionId}');
    } catch (e) {
      debugPrint('[LIVE] Error unsubscribing from websocket channel: $e');
    }
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
            child: Obx(() {
              final isCameraOn = _liveController.isCameraOn.value;
              return Stack(
                children: [
                  Positioned.fill(
                    child: (isCameraOn && _remoteVideoTrack != null)
                        ? VideoTrackRenderer(
                            _remoteVideoTrack!,
                            fit: VideoViewFit.cover,
                          )
                        : Container(
                            color: Colors.black,
                            child: Obx(() {
                              final currentSession = _liveController.currentSession.value;
                              final rawImage = currentSession?.astrologer?.profilePhoto ?? widget.astrologerImage;
                              final image = rawImage.isNotEmpty
                                  ? (rawImage.startsWith('http')
                                      ? rawImage
                                      : '${AppUrls.baseImageUrl}$rawImage')
                                  : '';
                              return CustomImageWidget(
                                imagePath: image.isNotEmpty ? image : "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1000&auto=format&fit=crop", 
                                fit: BoxFit.cover,
                              );
                            }),
                          ),
                  ),
                  
                  if (!isCameraOn)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.8),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_off, color: Colors.white70, size: 64),
                              SizedBox(height: 12),
                              Text(
                                "Camera is Stopped",
                                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Right side vertical action buttons (Share, Report, Speaker Mute)
                  Positioned(
                    right: 16,
                    bottom: 210,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRightActionButton(
                          icon: Icons.share,
                          onTap: () {
                            // Share live stream link/details
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildRightActionButton(
                          icon: Icons.warning_amber_rounded,
                          onTap: () {
                            // Report session
                          },
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          final isAstrologerMuted = !_liveController.isAudioOn.value;
                          final isMuted = _isSpeakerMuted || isAstrologerMuted;
                          return _buildRightActionButton(
                            icon: isMuted ? Icons.volume_off : Icons.volume_up,
                            onTap: isAstrologerMuted ? null : _toggleSpeakerMute,
                            isActive: !isMuted,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
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
          final rawImage = currentSession?.astrologer?.profilePhoto ?? widget.astrologerImage;
          final image = rawImage.isNotEmpty
              ? (rawImage.startsWith('http')
                  ? rawImage
                  : '${AppUrls.baseImageUrl}$rawImage')
              : '';
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
            
            // System Notification (Join/Leave)
            if (comment.isSystem) {
              final avatarUrl = (comment.userAvatar != null && comment.userAvatar!.isNotEmpty)
                  ? (comment.userAvatar!.startsWith('http')
                      ? comment.userAvatar!
                      : '${AppUrls.baseImageUrl}${comment.userAvatar}')
                  : null;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.person, size: 10, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        comment.message,
                        style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Normal Comment
            final avatarUrl = (comment.userAvatar != null && comment.userAvatar!.isNotEmpty)
                ? (comment.userAvatar!.startsWith('http')
                    ? comment.userAvatar!
                    : '${AppUrls.baseImageUrl}${comment.userAvatar}')
                : null;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
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
                if (_isSendingComment) return;
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
              if (_isSendingComment) return;
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

  Widget _buildRightActionButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isActive = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.redAccent,
          size: 20,
        ),
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

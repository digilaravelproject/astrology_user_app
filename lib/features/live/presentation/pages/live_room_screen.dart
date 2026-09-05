import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/constants/app_constants.dart';
import 'package:astro_user/features/astrologers/presentation/controllers/astrologer_controller.dart';
import 'package:astro_user/features/astrologers/data/models/gift_model.dart' as model;
import 'package:astro_user/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_user/features/live/data/models/live_session_model.dart';
import 'package:astro_user/core/services/websocket/websocket_service.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/features/astrologers/presentation/bindings/astrologers_binding.dart';

class LiveRoomScreen extends StatefulWidget {
  final int sessionId;
  final String astrologerName;
  final String astrologerImage;
  final List<LiveSessionModel> allSessions;
  final int initialIndex;

  const LiveRoomScreen({
    super.key,
    required this.sessionId,
    this.astrologerName = "Priya Sharma",
    this.astrologerImage = "",
    this.allSessions = const [],
    this.initialIndex = 0,
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  late LiveController _liveController;
  final RxBool _isFollowing = false.obs;
  final RxBool _isFollowLoading = false.obs;
  final RxInt _followerCount = 0.obs;
  late final AstrologerController _giftController;
  
  final List<Widget> _reactions = [];
  final TextEditingController _commentController = TextEditingController();
  model.GiftModel? _selectedGift;

  Room? _room;
  VideoTrack? _remoteVideoTrack;
  bool _isLiveKitConnected = false;
  Worker? _sessionWorker;
  Worker? _mediaWorker;
  bool _isSpeakerMuted = false;

  // Navigation between live sessions
  late int _currentIndex;



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
    _currentIndex = widget.initialIndex;
    _liveController = Get.find<LiveController>();

    final initialSession = widget.allSessions.firstWhereOrNull((s) => s.id == widget.sessionId);
    if (initialSession?.astrologerId != null) {
      _fetchAstrologerDetails(initialSession!.astrologerId!);
    }

    if (!Get.isRegistered<AstrologerController>()) {
      AstrologersBinding().dependencies();
    }
    _giftController = Get.find<AstrologerController>();
    _commentController.addListener(() {
      setState(() {});
    });
    
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

    // Automatically trigger animation for new superchats
    ever(_liveController.comments, (List<LiveCommentModel> currentComments) {
      if (currentComments.isNotEmpty) {
        final lastComment = currentComments.last;
        // Check if the latest comment is a super chat (has giftIconUrl)
        if (lastComment.giftIconUrl != null) {
          _addReaction(lastComment.giftIconUrl);
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

  bool _isConnectingLiveKit = false;

  Future<void> _connectLiveKit(int sessionId) async {
    if (_isLiveKitConnected || _isConnectingLiveKit) return;
    _isConnectingLiveKit = true;
    
    try {
      if (_room != null) {
        try {
          await _room!.disconnect();
          await _room!.dispose();
        } catch (e) {
          debugPrint("Error disposing previous room: $e");
        }
        _room = null;
      }
      
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
      
      debugPrint('[LIVE] Connecting to LiveKit room: $wsUrl');
      final room = Room();
      
      List<RTCIceServer> iceServers = [];
      try {
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.get(AppUrls.turnCredentials, handleError: false, showErrorScreen: false);
        if (response.isSuccess && response.body != null) {
          final data = response.body['data'];
          if (data != null && data['iceServers'] != null) {
            iceServers = (data['iceServers'] as List).map((s) {
              return RTCIceServer(
                urls: List<String>.from(s['urls'] ?? []),
                username: s['username']?.toString(),
                credential: s['credential']?.toString(),
              );
            }).toList();
            debugPrint('[LIVE] Dynamic TURN credentials loaded successfully');
          }
        }
      } catch (e) {
        debugPrint('[LIVE] Error fetching dynamic TURN credentials: $e');
      }

      if (iceServers.isEmpty) {
        debugPrint('[LIVE] Falling back to default TURN credentials');
        iceServers = [
          RTCIceServer(
            urls: [AppConstants.liveKitTurnServerUrl],
            username: AppConstants.liveKitTurnUsername,
            credential: AppConstants.liveKitTurnCredential,
          )
        ];
      }

      await room.connect(
        wsUrl,
        token,
        connectOptions: ConnectOptions(
          rtcConfiguration: RTCConfiguration(iceServers: iceServers),
        ),
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
    } finally {
      _isConnectingLiveKit = false;
    }
  }

  void _disconnectLiveKit() async {
    final roomToDispose = _room;
    _room = null;
    if (roomToDispose != null) {
      try {
        await roomToDispose.disconnect();
        await roomToDispose.dispose();
      } catch (e) {
        debugPrint('[LIVE] Error disconnecting room: $e');
      }
    }
    
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
                         return Center(child: Text("No gifts available".tr, style: TextStyle(color: Colors.white70)));
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

  void _addReaction([String? imageUrl]) {
    setState(() {
      _reactions.add(
        FloatingReaction(imageUrl: imageUrl, key: UniqueKey()),
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

  void _navigateToSession(int newIndex) {
    if (widget.allSessions.isEmpty) return;
    if (newIndex < 0 || newIndex >= widget.allSessions.length) return;
    final session = widget.allSessions[newIndex];
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LiveRoomScreen(
          sessionId: session.id,
          astrologerName: session.astrologer?.name ?? 'Astrologer',
          astrologerImage: session.astrologer?.profilePhoto ?? '',
          allSessions: widget.allSessions,
          initialIndex: newIndex,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final isGoingRight = newIndex > _currentIndex;
          final tween = Tween<Offset>(
            begin: Offset(isGoingRight ? 1.0 : -1.0, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _goToPrevSession() => _navigateToSession(_currentIndex - 1);
  void _goToNextSession() => _navigateToSession(_currentIndex + 1);

  Future<void> _showExitConfirmation() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Leave Stream?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to leave this live session?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldLeave == true && mounted) {
      Navigator.pop(context); // Actually leave
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _showExitConfirmation();
      },
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -300) {
          // Swipe Left → next session
          _goToNextSession();
        } else if (velocity > 300) {
          // Swipe Right → prev session
          _goToPrevSession();
        }
      },
      child: Scaffold(
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
                              
                              if (image.isNotEmpty) {
                                return CustomImageWidget(
                                  imagePath: image, 
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return Container(
                                  color: AppColors.deepPink.withOpacity(0.15),
                                  child: Center(
                                    child: Text(
                                      widget.astrologerName.isNotEmpty ? widget.astrologerName.substring(0, 1).toUpperCase() : 'A',
                                      style: TextStyle(
                                        fontSize: 120,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.deepPink.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                  ),
                  
                  if (!isCameraOn)
                    Positioned.fill(
                      child: Obx(() {
                        final currentSession = _liveController.currentSession.value;
                        final rawImage = currentSession?.astrologer?.profilePhoto ?? widget.astrologerImage;
                        final image = rawImage.isNotEmpty
                            ? (rawImage.startsWith('http') ? rawImage : '${AppUrls.baseImageUrl}$rawImage')
                            : '';
                        final session = currentSession;
                        final isEnded = session?.status == 'completed';

                        return Stack(
                          children: [
                            // Background: image or letter
                            Positioned.fill(
                              child: image.isNotEmpty
                                  ? Stack(
                                      children: [
                                        CustomImageWidget(imagePath: image, fit: BoxFit.cover),
                                        BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                          child: Container(color: Colors.black.withOpacity(0.5)),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      color: AppColors.deepPink.withOpacity(0.12),
                                      child: Center(
                                        child: Text(
                                          widget.astrologerName.isNotEmpty
                                              ? widget.astrologerName.substring(0, 1).toUpperCase()
                                              : '',
                                          style: TextStyle(
                                            fontSize: 160,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.deepPink.withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            // Camera off indicator
                            if (!isEnded)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.videocam_off_rounded, color: Colors.white, size: 32),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Camera is Stopped".tr,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),


                ],
              );
            }),
          ),
          
          Positioned.fill(
            child: Obx(() {
              final session = _liveController.currentSession.value;
              final isEnded = session?.status == 'completed';
              if (isEnded) return const SizedBox.shrink();
              
              return Container(
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
              );
            }),
          ),

          // Mic muted indicator — shown when audio off but camera is still on
          Positioned(
            top: 0, bottom: 0, left: 0, right: 0,
            child: Obx(() {
              final isAudioOn = _liveController.isAudioOn.value;
              final isCameraOn = _liveController.isCameraOn.value;
              if (isAudioOn || !isCameraOn) return const SizedBox.shrink();
              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_off_rounded, color: Colors.amber, size: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Astrologer's Mic is Mute",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          // Top gradient for header visibility
          Positioned(
            top: 0, left: 0, right: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Bottom gradient for comments/inputs visibility
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 350,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
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
                        _buildAstrologerInfoPanel(),
                        const Spacer(),
                        _buildCircleActionIcon(Icons.close, () => _showExitConfirmation()),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                
                // Super Chat Banner
                Obx(() {
                  final superChat = _liveController.activeSuperChat.value;
                  if (superChat == null) return const SizedBox.shrink();
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.withOpacity(0.8), Colors.deepOrange.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        if (superChat.userAvatar != null && superChat.userAvatar!.isNotEmpty)
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              superChat.userAvatar!.startsWith('http') 
                                  ? superChat.userAvatar! 
                                  : '${AppUrls.baseImageUrl}${superChat.userAvatar}'
                            ),
                          )
                        else
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white24,
                            child: Text(
                              superChat.userName.isNotEmpty ? superChat.userName.substring(0, 1).toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                superChat.userName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                superChat.message,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (superChat.giftIconUrl != null)
                          Image.network(
                            superChat.giftIconUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                      ],
                    ),
                  );
                }),

                // Comments feed & comment bar
                Obx(() {
                  final session = _liveController.currentSession.value;
                  final isEnded = session?.status == 'completed';
                  if (isEnded) return const SizedBox.shrink();
                  
                  return Padding(
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: _buildCommentInput(),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(() {
                                  final session = _liveController.currentSession.value;
                                  final isEnded = session?.status == 'completed';
                                  if (isEnded) return const SizedBox.shrink();
                                  
                                  final isAstrologerMuted = !_liveController.isAudioOn.value;
                                  final isUserMuted = _isSpeakerMuted;
                                  final isActuallyMuted = isAstrologerMuted || isUserMuted;
                                  
                                  return _buildRightActionButton(
                                    icon: isActuallyMuted ? Icons.volume_off : Icons.volume_up,
                                    onTap: isAstrologerMuted ? null : _toggleSpeakerMute,
                                    isActive: !isAstrologerMuted,
                                    activeColor: isActuallyMuted ? Colors.white : Colors.green,
                                  );
                                }),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _showGiftSheet,
                                  child: _buildCircleIconButton(Icons.wallet_giftcard_rounded, Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // floating reactions
          Positioned(
            right: 20,
            bottom: 80,
            child: Obx(() {
              final session = _liveController.currentSession.value;
              final isEnded = session?.status == 'completed';
              if (isEnded) return const SizedBox.shrink();
              
              return SizedBox(
                width: 50,
                height: 300,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: _reactions,
                ),
              );
            }),
          ),
          
          // Navigation buttons (Left and Right)
          if (_currentIndex > 0)
            Positioned(
              left: 10,
              top: MediaQuery.of(context).size.height / 2 - 20,
              child: _buildNavButton(
                icon: Icons.chevron_left,
                onTap: _goToPrevSession,
              ),
            ),
          if (_currentIndex < widget.allSessions.length - 1)
            Positioned(
              right: 10,
              top: MediaQuery.of(context).size.height / 2 - 20,
              child: _buildNavButton(
                icon: Icons.chevron_right,
                onTap: _goToNextSession,
              ),
            ),

          // Live Session Ended Overlay
          Positioned.fill(
            child: Obx(() {
              final session = _liveController.currentSession.value;
              final isEnded = session?.status == 'completed';
              if (!isEnded) return const SizedBox.shrink();
              
              return Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off, color: Colors.white70, size: 64),
                      const SizedBox(height: 12),
                      Text("Live Session Ended".tr,
                        style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("Go Back".tr),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildCircleActionIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }


  Widget _buildAstrologerInfoPanel() {
    return Obx(() {
      final session = _liveController.currentSession.value;
      final astrologer = session?.astrologer;
      final name = astrologer?.name ?? widget.astrologerName;
      final followers = _followerCount.value;
      final liveCount = session?.viewerCount ?? 0;

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with LIVE badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildAstrologerAvatar(size: 40),
              Positioned(
                bottom: -4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Name and Stats/Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name.isNotEmpty ? (name.length > 15 ? '${name.substring(0, 15)}...' : name) : 'Astrologer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 1))
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, color: Colors.blue, size: 14),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '$liveCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12, shadows: [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 1))]),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.person, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '$followers',
                    style: const TextStyle(color: Colors.white, fontSize: 12, shadows: [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 1))]),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleFollow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isFollowing.value ? Colors.grey : AppColors.deepPink,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _isFollowLoading.value
                          ? const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
                            )
                          : Text(
                              _isFollowing.value ? 'Following'.tr : 'Follow'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildAstrologerAvatar({double size = 32}) {
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
            child: image.isEmpty 
              ? Text(
                  widget.astrologerName.isNotEmpty ? widget.astrologerName.substring(0, 1).toUpperCase() : '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ) 
              : null,
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
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                  ClipOval(
                    child: Container(
                      width: 24,
                      height: 24,
                      color: Colors.grey.shade800,
                          child: avatarUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: avatarUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(child: Text(comment.userName.isNotEmpty ? comment.userName.substring(0, 1).toUpperCase() : '', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                                  errorWidget: (context, url, error) => Center(child: Text(comment.userName.isNotEmpty ? comment.userName.substring(0, 1).toUpperCase() : '', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                                )
                              : Center(child: Text(comment.userName.isNotEmpty ? comment.userName.substring(0, 1).toUpperCase() : '', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: comment.isSystem ? '${comment.userName} ' : '${comment.userName}: ',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: comment.message,
                            style: TextStyle(
                              color: comment.isSystem ? Colors.white70 : Colors.white,
                              fontSize: 13,
                              fontStyle: comment.isSystem ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                          if (comment.giftIconUrl != null)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: CachedNetworkImage(
                                  imageUrl: comment.giftIconUrl!,
                                  width: 24,
                                  height: 24,
                                  placeholder: (context, url) => const SizedBox(width: 24, height: 24),
                                  errorWidget: (context, url, error) => const Icon(Icons.card_giftcard, size: 20, color: Colors.orange),
                                ),
                              ),
                            ),
                        ],
                      ),
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
                if (_liveController.isSendingComment.value) return;
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
              if (_liveController.isSendingComment.value) return;
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
    Color activeColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          color: isActive ? activeColor : Colors.white,
          size: 24,
        ),
      ),
    );
  }


  Future<void> _fetchAstrologerDetails(int id) async {
    if (Get.isRegistered<AstrologerController>()) {
      final astroController = Get.find<AstrologerController>();
      final astrologerDetails = await astroController.fetchAstrologerById(id);
      if (astrologerDetails != null) {
        _isFollowing.value = astrologerDetails.isFollowed;
        _followerCount.value = astrologerDetails.totalOrders ?? 0;
      }
    }
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Future<void> _toggleFollow() async {
    if (_isFollowLoading.value) return;
    
    final initialSession = widget.allSessions.firstWhereOrNull((s) => s.id == widget.sessionId);
    final astrologerId = initialSession?.astrologerId ?? _liveController.currentSession.value?.astrologerId;
    
    if (astrologerId == null || astrologerId == 0) return;

    try {
      _isFollowLoading.value = true;
      if (Get.isRegistered<AstrologerController>()) {
        final astroController = Get.find<AstrologerController>();
        final result = await astroController.followAstrologer(astrologerId);
        if (result.isSuccess) {
          _isFollowing.value = !_isFollowing.value;
          astroController.isFollowing.value = _isFollowing.value;
        } else {
          CustomSnackbar.showError(result.message);
        }
      }
    } catch (e) {
      debugPrint('[LIVE] Error toggling follow: $e');
    } finally {
      _isFollowLoading.value = false;
    }
  }

}

class FloatingReaction extends StatefulWidget {
  final String? imageUrl;
  const FloatingReaction({super.key, this.imageUrl});

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
              child: widget.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.imageUrl!,
                      width: 40,
                      height: 40,
                      placeholder: (context, url) => const Icon(Icons.card_giftcard, color: Colors.orange, size: 32),
                      errorWidget: (context, url, error) => const Icon(Icons.card_giftcard, color: Colors.orange, size: 32),
                    )
                  : const Icon(Icons.favorite, color: Colors.red, size: 24),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_image_widget.dart';
import '../../../core/constants/app_strings.dart';

class LiveRoomScreen extends StatefulWidget {
  final String astrologerName;
  final String astrologerImage;

  const LiveRoomScreen({
    super.key,
    this.astrologerName = "Lord Busuz",
    this.astrologerImage = "https://randomuser.me/api/portraits/men/32.jpg",
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(name: "Andrew Phipps", message: "Hi, best games ⭐", avatar: "https://randomuser.me/api/portraits/men/1.jpg"),
    ChatMessage(name: "Joshua Chen", message: "Well played, Lord! You're Master 🫡", avatar: "https://randomuser.me/api/portraits/men/2.jpg"),
    ChatMessage(name: "Felícia Barbosa", message: "Give away bang! 🔥🔥", avatar: "https://randomuser.me/api/portraits/women/3.jpg"),
    ChatMessage(name: "Punica 0.2B", message: "Let's play Anno 1701 Again! 👋", avatar: "https://randomuser.me/api/portraits/women/4.jpg"),
  ];

  final List<Widget> _reactions = [];
  final TextEditingController _commentController = TextEditingController();

  final List<GiftModel> _gifts = [
    GiftModel(name: AppStrings.giftRose, icon: "🌹", price: 10),
    GiftModel(name: AppStrings.giftChocolate, icon: "🍫", price: 50),
    GiftModel(name: AppStrings.giftDiamond, icon: "💎", price: 100),
    GiftModel(name: AppStrings.giftStar, icon: "⭐", price: 200),
    GiftModel(name: AppStrings.giftHeart, icon: "❤️", price: 30),
    GiftModel(name: AppStrings.giftCrown, icon: "👑", price: 500),
    GiftModel(name: AppStrings.giftClap, icon: "👏", price: 5),
    GiftModel(name: AppStrings.giftCandy, icon: "🍬", price: 15),
  ];

  GiftModel? _selectedGift;

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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.wallet, color: Colors.orange, size: 14),
                              const SizedBox(width: 4),
                              const Text(
                                "500",
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _gifts.length,
                      itemBuilder: (context, index) {
                        final gift = _gifts[index];
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
                                Text(gift.icon, style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text(
                                  gift.name,
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.monetization_on, color: Colors.orange, size: 10),
                                    const SizedBox(width: 2),
                                    Text(
                                      gift.price.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _selectedGift == null ? null : () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${AppStrings.youSentAGift} ${_selectedGift!.name}!"),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          disabledBackgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          _selectedGift == null ? AppStrings.selectAGift : "${AppStrings.sendGiftAction} ${_selectedGift!.name}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    // Remove the reaction after animation completes (approx 3s)
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
      backgroundColor: Colors.black, // Dark fallback
      body: Stack(
        children: [
          // 1. Truly Static Background
          const Positioned.fill(
            child: CustomImageWidget(
              imagePath: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1000&auto=format&fit=crop", 
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. Static Gradient Overlay
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
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.2, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 3. Transparent, Keyboard-Aware Scaffold for content
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: Column(
              children: [
                // 3.1 Header (Always at top)
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
                                            child: AppText(
                                              widget.astrologerName,
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
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

                // 3.2 Chat & Interaction Area (Always pushed by keyboard)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chat List
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.25,
                        ),
                        child: _buildChatList(),
                      ),
                      const SizedBox(height: 12),
                      // Interaction Bar
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

          // 4. Reaction Animations (Separate Layer)
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
        CircleAvatar(
          radius: 17,
          backgroundImage: NetworkImage(widget.astrologerImage),
        ),
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
      child: const Row(
        children: [
          Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Text(
            "1628",
            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: ListView.builder(
        shrinkWrap: true,
        reverse: true,
        padding: EdgeInsets.zero,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[(_messages.length - 1) - index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(msg.avatar),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        msg.name,
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      AppText(
                        msg.message,
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
      ),
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
          Icon(Icons.send_rounded, color: Colors.white.withOpacity(0.5), size: 18),
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

class ChatMessage {
  final String name;
  final String message;
  final String avatar;

  ChatMessage({required this.name, required this.message, required this.avatar});
}

class GiftModel {
  final String name;
  final String icon;
  final int price;

  GiftModel({required this.name, required this.icon, required this.price});
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double value = _animation.value;
        final double y = -300 * value;
        final double x = _startX + (20 * (value < 0.5 ? value : 1 - value)); // Subtle sway
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

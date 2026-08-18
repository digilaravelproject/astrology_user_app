import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/screens/home_screen.dart';
import '../../chat/presentation/pages/chat_list_screen.dart';
import '../../call/screens/call_list_screen.dart';
import '../../live/presentation/pages/live_astrologer_screen.dart';
import '../../matching/screens/matching_screen.dart';
import '../../matrimony/screens/matrimony_screen.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../matrimony/controllers/matrimony_controller.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_user/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_user/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_user/core/constants/app_urls.dart';
import 'package:astro_user/features/call/presentation/controllers/call_controller.dart';
import '../../live/presentation/controllers/live_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final MatrimonyController _matrimonyController = Get.find<MatrimonyController>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const MatrimonyScreen(),
    const ChatListScreen(),
    const CallListScreen(),
    const LiveAstrologerScreen(),
    const MatchingScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(icon: Iconsax.home_2_copy, label: AppStrings.navHome),
    NavItem(icon: Iconsax.lovely_copy, label: AppStrings.navMatrimony),
    NavItem(icon: Iconsax.message_copy, label: 'Chat'),
    NavItem(icon: Iconsax.call_copy, label: 'Call'),
    NavItem(icon: Iconsax.play_circle_copy, label: AppStrings.navLive),
    NavItem(icon: Iconsax.heart_copy, label: 'Matching'),
  ];

  void _onItemTapped(int index) {
    if (index == 4) {
      if (Get.isRegistered<LiveController>()) {
        Get.find<LiveController>().fetchActiveSessions();
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // Check for initial index from arguments
    final argIndex = Get.arguments?['index'];
    if (argIndex != null && argIndex is int) {
      _selectedIndex = argIndex;
    }

    final bool skipPromo = Get.arguments?['skip_promo'] ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (!skipPromo) {
      //   _showPromotionalSheet();
      // }
      _checkCurrentActiveSession();
      Get.find<CallController>().checkCurrentActiveCallSession();
    });
  }

  Future<void> _checkCurrentActiveSession() async {
    try {
      final response = await Get.find<ApiClient>().get(AppUrls.getCurrentSession);
      if (response.isSuccess && response.body != null) {
        final data = response.body;
        final session = (data is Map)
            ? (data['session'] ?? data['data']?['session'] ?? data['data'] ?? data)
            : null;
        final sessionId = session?['id'];
        final status = session?['status'];
        final startedAt = session?['started_at'] ?? session?['accepted_at'] ?? session?['created_at'];
        // For user app, other person is provider (astrologer)
        final name = session?['provider']?['name'] ?? 'Astrologer';

        if (status == 'ongoing' || status == 'initiated' || status == 'accepted') {
          FloatingChatBubble.show(
              context: Get.context!,
              sessionId: sessionId,
              name: name,
              imageUrl: '', // We don't have the image in this payload
              status: status,
              startedAt: startedAt,
              onTap: () {
                final currentStatus = FloatingChatBubble.chatStatus.value;
                FloatingChatBubble.dismiss();
                Get.to(
                      () => ChatScreen(
                    astrologerName: name,
                    astrologerImage: '',
                    sessionId: sessionId,
                    initialStatus: currentStatus,
                    startedAtString: startedAt,
                  ),
                  binding: ChatBinding(),
                );
              }
          );
        }
      }
    } catch (e) {
      debugPrint("Error checking active session: $e");
    }
  }

  void _showPromotionalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              // Background Image/Gradient
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.asset(
                    "assets/images/astro.jpg",
                    // 'https://img.freepik.com/premium-photo/indian-sadhu-reading-scriptures_53876-25805.jpg', // Placeholder mystic image
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF2E1A47),
                    ),
                  ),
                ),
              ),

              // Overlay Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Close Button
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.black, size: 20),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.yellow, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.premiumAstrology,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.consultWithPremiumAI,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.getPrecisePredictions,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        AppStrings.getYourFreeChat,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigate effectively implies starting the chat flow
                            // For now just close, as user might want to browse
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6F00), // Orange color
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                          child: Text(
                            AppStrings.chatFreeNow,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Color? navGradientColor;
      // Accessing observable to ensure Obx is valid
      final isRegistered = _matrimonyController.isRegistered.value;

      if (_selectedIndex == 1) {
        navGradientColor = Colors.white;
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final callController = Get.find<CallController>();
          if (callController.sessionId != null) {
            try {
              const channel = MethodChannel('com.suryapath.user/app_retain');
              await channel.invokeMethod('sendToBackground');
            } catch (e) {
              debugPrint("Error sending to background: $e");
            }
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          extendBody: true,
          body: Column(
            children: [
              Obx(() {
                if (FloatingChatBubble.isActive &&
                    FloatingChatBubble.sessionId != null &&
                    FloatingChatBubble.name != null) {
                  return FloatingChatBubbleWidget(
                    sessionId: FloatingChatBubble.sessionId!,
                    name: FloatingChatBubble.name!,
                    imageUrl: '',
                  );
                }
                return const SizedBox.shrink();
              }),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            items: _navItems,
            onItemSelected: _onItemTapped,
            gradientColor: navGradientColor,
          ),
        ),
      );
    });
  }
}

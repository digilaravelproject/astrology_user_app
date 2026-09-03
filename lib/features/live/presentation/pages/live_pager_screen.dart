import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/live_controller.dart';
import 'live_room_screen.dart';

class LivePagerScreen extends StatefulWidget {
  final int initialIndex;

  const LivePagerScreen({
    super.key,
    required this.initialIndex,
  });

  @override
  State<LivePagerScreen> createState() => _LivePagerScreenState();
}

class _LivePagerScreenState extends State<LivePagerScreen> {
  late PageController _pageController;
  final LiveController _liveController = Get.find<LiveController>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final sessions = _liveController.activeSessions;
        if (sessions.isEmpty) {
          return const Center(
            child: Text(
              'No active streams currently.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return LiveRoomScreen(
                  key: ValueKey(session.id),
                  sessionId: session.id,
                  astrologerName: session.astrologer?.name ?? 'Astrologer',
                  astrologerImage: session.astrologer?.profilePhoto ?? '',
                );
              },
            ),
            
            // Left Button (Previous)
            Positioned(
              left: 10,
              top: MediaQuery.of(context).size.height / 2 - 25,
              child: IconButton(
                onPressed: () {
                  if (_pageController.page != null && _pageController.page! > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                ),
              ),
            ),

            // Right Button (Next)
            Positioned(
              right: 10,
              top: MediaQuery.of(context).size.height / 2 - 25,
              child: IconButton(
                onPressed: () {
                  if (_pageController.page != null && _pageController.page! < sessions.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

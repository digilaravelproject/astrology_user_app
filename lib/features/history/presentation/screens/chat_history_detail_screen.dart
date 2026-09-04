import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_user/core/theme/app_colors.dart';
import 'package:astro_user/core/constants/app_strings.dart';
import 'package:astro_user/core/widgets/app_text.dart';
import 'package:astro_user/core/widgets/custom_image_widget.dart';
import 'package:astro_user/core/widgets/custom_app_bar.dart';

class ChatHistoryDetailScreen extends StatelessWidget {
  final String astrologerName;
  final String date;

  const ChatHistoryDetailScreen({
    Key? key, 
    required this.astrologerName,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Messages
    final List<Map<String, dynamic>> messages = [
      {"text": "Namaste! How can I help you today?", "isMe": false, "time": "10:00 AM"},
      {"text": "I am worried about my career.", "isMe": true, "time": "10:01 AM"},
      {"text": "Can you share your birth details?", "isMe": false, "time": "10:01 AM"},
      {"text": "12th Aug 1995, 2:30 PM, Delhi", "isMe": true, "time": "10:02 AM"},
      {"text": "Let me analyze your chart. Please wait a moment.", "isMe": false, "time": "10:03 AM"},
      {"text": "Sure.", "isMe": true, "time": "10:03 AM"},
      {"text": "I see a strong career growth in the upcoming year.", "isMe": false, "time": "10:05 AM"},
      {"text": "That is great news! Thank you.", "isMe": true, "time": "10:06 AM"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: '',
        showLeading: true,
        onLeadingPressed: () => Navigator.pop(context),
        titleWidget: Row(
          children: [
            CustomImageWidget(
              imagePath: 'https://i.pravatar.cc/150?u=a042581f4e29026704d', // Placeholder
              height: 40,
              width: 40,
              radius: BorderRadius.circular(20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  astrologerName,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                AppText(
                  date,
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['isMe'] as bool;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.deepPink : Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isMe ? Colors.white : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                AppText(
                  "This chat session has ended.",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

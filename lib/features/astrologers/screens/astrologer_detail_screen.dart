import 'package:astro_user/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_image_widget.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_rating_bar.dart';
import '../../astrologers/controllers/astrologer_controller.dart';
import '../../astrologers/domain/models/astrologer_model.dart';
import '../../astrologers/domain/models/review_model.dart';
import '../../astrologers/screens/all_reviews_screen.dart';
import '../../chat/presentation/pages/chat_screen.dart';
import '../../call/screens/call_screen.dart';
import '../../../core/utils/wallet_helper.dart';
import '../../../core/constants/app_urls.dart';
import '../widgets/gift_history_bottom_sheet.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../wallet/widgets/recharge_bottom_sheet.dart';

class AstrologerDetailScreen extends StatefulWidget {
  final int astrologerId;

  const AstrologerDetailScreen({
    Key? key,
    required this.astrologerId,
  }) : super(key: key);

  @override
  State<AstrologerDetailScreen> createState() => _AstrologerDetailScreenState();
}

class _AstrologerDetailScreenState extends State<AstrologerDetailScreen> {
  final AstrologerController _controller = Get.find<AstrologerController>();
  AstrologerModel? _astrologer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAstrologer();
      _controller.fetchReviews(widget.astrologerId);
    });
  }

  @override
  void didUpdateWidget(covariant AstrologerDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.astrologerId != widget.astrologerId) {
      _fetchAstrologer();
      _controller.fetchReviews(widget.astrologerId);
    }
  }

  Future<void> _fetchAstrologer() async {
    setState(() {
      _isLoading = true;
      _astrologer = null;
    });
    
    try {
      final result = await _controller.fetchAstrologerById(widget.astrologerId);
      if (mounted && result != null) {
        setState(() {
          _astrologer = result;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // AppBar
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Color(0xFF2D2D2D)),
                      onSelected: (value) {
                        // Handle menu selection
                        if (value == 'Block' || value == 'Unblock') {
                          if (_astrologer!.isBlocked) {
                            _showUnblockBottomSheet(context, _astrologer!.name);
                          } else {
                            _showBlockBottomSheet(context, _astrologer!.name);
                          }
                        } else if (value == 'Report') {
                          _showReportBottomSheet(context, _astrologer!.name);
                        }
                        else if (value == 'Review') {
                          _showReviewBottomSheet(context, _astrologer!.name);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return { 
                          _astrologer?.isBlocked == true ? 'Unblock' : 'Block', 
                          'Report', 
                          'Review' 
                        }.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: AppText(
                              choice,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorPrimary,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
                // Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header Card
                      if (_astrologer != null) _buildProfileHeaderCard(_astrologer!),
                      if (_astrologer == null && !_isLoading) 
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: AppText('Astrologer data not found', color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Gallery Section - commented out
                      // _buildGallerySection(),
                      // const SizedBox(height: 16),
                      // Reviews Section
                      Obx(() => _buildReviewsSection()),
                      const SizedBox(height: 16),
                      // Chat with Assistant
                      //_buildChatAssistantSection(),
                      const SizedBox(height: 16),
                      // Send Gift
                      _buildGiftSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: (_astrologer?.isOnline ?? false)
          ? _buildBottomActions(context)
          : null,

     // bottomNavigationBar: _buildBottomActions(context),

    );
  }

  void _showUnblockBottomSheet(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.green),
              const SizedBox(height: 16),
              AppText(
                "Unblock $name?",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),
              AppText(
                "You will be able to message and call this astrologer again.",
                fontSize: 14,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Cancel",
                      backgroundColor: Colors.grey.shade100,
                      textColor: Colors.black87,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: "Unblock",
                      backgroundColor: Colors.green,
                      onTap: () async {
                        Get.back(); // Close bottom sheet
                        try {
                          final result = await _controller.unblockAstrologer(widget.astrologerId);
                          if (result.isSuccess) {
                            CustomSnackbar.showSuccess(result.message);
                            _fetchAstrologer(); // Refresh local state
                          } else {
                            CustomSnackbar.showError(result.message);
                          }
                        } catch (e) {
                          CustomSnackbar.showError("Failed to unblock astrologer: $e");
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showBlockBottomSheet(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.block_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              AppText(
                "Block $name?",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),
              AppText(
                "You won't be able to message or call this astrologer anymore.",
                fontSize: 14,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Cancel",
                      backgroundColor: Colors.grey.shade100,
                      textColor: Colors.black87,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: "Block",
                      backgroundColor: Colors.red,
                      onTap: () async {
                        Get.back(); // Close bottom sheet
                        try {
                          final result = await _controller.blockAstrologer(widget.astrologerId);
                          if (result.isSuccess) {
                            CustomSnackbar.showSuccess(result.message);
                            // Navigate back to listing after blocking
                            Get.back();
                          } else {
                            CustomSnackbar.showError(result.message);
                          }
                        } catch (e) {
                          CustomSnackbar.showError("Failed to block astrologer: $e");
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showReportBottomSheet(BuildContext context, String name) {
    final TextEditingController _reasonController = TextEditingController();
    String? _selectedReason;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: AppText(
                        "Report Astrologer",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppText(
                      "Why do you want to report?",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 16),

                    // Text field for custom reason
                    Container(
                      width: double.infinity,
                     // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          hintText: "Enter reason for reporting...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Predefined reasons
                    // ...["Inappropriate Behavior", "Spam", "Fake Profile", "Other"].map((reason) {
                    //   return Padding(
                    //     padding: const EdgeInsets.only(bottom: 12),
                    //     child: InkWell(
                    //       onTap: () {
                    //         setState(() {
                    //           _selectedReason = reason;
                    //           _reasonController.text = reason;
                    //         });
                    //       },
                    //       child: Container(
                    //         padding: const EdgeInsets.all(16),
                    //         decoration: BoxDecoration(
                    //           color: _selectedReason == reason ? const Color(0xFFFFF0F5) : Colors.grey.shade100,
                    //           borderRadius: BorderRadius.circular(12),
                    //           border: Border.all(
                    //             color: _selectedReason == reason ? const Color(0xFFFFCDD2) : Colors.grey.shade300,
                    //           ),
                    //         ),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             AppText(reason, fontSize: 14, color: Colors.black87),
                    //             if (_selectedReason == reason)
                    //               const Icon(Icons.check, size: 16, color: Color(0xFF4CAF50)),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   );
                    // }).toList(),
                    // const SizedBox(height: 20),

                    // Report button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: "Report",
                        backgroundColor: AppColors.primaryColor,
                        onTap: () async {
                          final reason = _reasonController.text.trim();
                          if (reason.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Please enter a reason for reporting",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.primaryColor,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(20),
                            );
                            return;
                          }

                          Get.back(); // Close bottom sheet
                          try {
                            final result = await _controller.reportAstrologer(widget.astrologerId, reason);
                            if (result.isSuccess) {
                              CustomSnackbar.showSuccess(result.message);

                              Get.back(); // Close detail screen
                            } else {
                              CustomSnackbar.showError(result.message);
                            }
                          } catch (e) {
                            CustomSnackbar.showError("Failed to report astrologer: $e");
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReviewBottomSheet(BuildContext context, String name) {
    double _selectedRating = 0.0;
    final TextEditingController _reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: AppText(
                        "Write a Review",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedRating = index + 1.0;
                              });
                            },
                            icon: Icon(
                              index < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 32,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppText(
                      "Share your experience",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                    //  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _reviewController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "How was your session with $name?",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: "Post Review",
                        backgroundColor: AppColors.deepPink,
                        textColor: Colors.white,
                        onTap: () async {
                          if (_selectedRating == 0) {
                            CustomSnackbar.showError("Please select a rating");
                            return;
                          }

                          final review = _reviewController.text.trim();
                          if (review.isEmpty) {
                            CustomSnackbar.showError("Please enter a review");
                            return;
                          }
                          Get.back(); // Close bottom sheet
                          try {
                            final result = await _controller.postReview(
                              widget.astrologerId,
                              _selectedRating.toInt(),
                              review,
                            );
                            print("hhgcgewbsj : $result");
                            if (result.isSuccess) {
                              CustomSnackbar.showSuccess(result.message);
                              _controller.fetchReviews(widget.astrologerId);
                            } else {

                              CustomSnackbar.showError(result.message);
                            }
                          } catch (e) {
                           // CustomSnackbar.showError("Failed to post review");
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeaderCard(AstrologerModel astro) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.deepPink.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPink.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                          ),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            image: DecorationImage(
                              image: NetworkImage(astro.fullProfilePhoto),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Online Status Dot
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: astro.isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (astro.isOnline ? Colors.green : Colors.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: (astro.isOnline ? Colors.green : Colors.grey).withOpacity(0.5), width: 0.5),
                    ),
                    child: AppText(
                      astro.isOnline ? 'Online' : 'Offline',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: astro.isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  if (astro.isBlocked)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.5), width: 0.5),
                      ),
                      child: const AppText(
                        'Blocked',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (astro.rating > 0)
                    CustomRatingBar(rating: astro.rating, size: 14),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: AppText(
                                      astro.name,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textColorPrimary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: Color(0xFF4CAF50), size: 16),
                                ],
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                astro.areasOfExpertise.join(', '),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColorSecondary,
                                height: 1.3,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(() => Container(
                              width: 70,
                              height: 28,
                              child: CustomButton(
                                text: _controller.isFollowing.value ? 'Following' : 'Follow',
                                fontSize: 10,
                                height: 28,
                                borderRadius: 14,
                                backgroundColor: astro.isBlocked ? Colors.grey.shade300 : (_controller.isFollowing.value ? Colors.grey : AppColors.deepPink),
                                textColor: astro.isBlocked ? Colors.grey : Colors.white,
                                onTap: astro.isBlocked ? null : () async {
                                  final result = await _controller.followAstrologer(widget.astrologerId);
                                  if (result.isSuccess) {
                                    _controller.isFollowing.value = !_controller.isFollowing.value;
                                  } else {
                                    CustomSnackbar.showError(result.message);
                                  }
                                },
                              ),
                            )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      astro.languages.join(', '),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorHint,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            'Exp: ${astro.yearsOfExperience} Years',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColorPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              '₹${astro.chatRate ?? '0'}',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColorSecondary,
                              style: GoogleFonts.inter(decoration: TextDecoration.lineThrough),
                            ),
                            const SizedBox(width: 6),
                            AppText(
                              '₹${astro.chatRate ?? '0'}',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.deepPink,
                            ),
                            AppText('/min', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.deepPink,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepPink.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt, color: Colors.yellow, size: 14),
                      const SizedBox(width: 6),
                      Flexible(
                        child: AppText(
                          '₹ 30/session for 30 minute complete guide',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          _BioText(bio: astro.bio),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final reviews = _controller.reviews;

    // Show only first 5 reviews
    final displayReviews = reviews.take(5).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Icon(Icons.star_rate_rounded, color: AppColors.deepPink, size: 24),
                  const SizedBox(width: 8),
                  AppText(
                    'User Reviews',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepPink,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showReviewBottomSheet(context, _astrologer!.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.deepPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.deepPink.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_comment_rounded, size: 14, color: AppColors.deepPink),
                      const SizedBox(width: 4),
                      AppText(
                        'Write',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepPink,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...displayReviews.map((review) => _buildReviewCard(review)).toList(),
          ],
          if (reviews.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: AppText(
                'No reviews yet. Be the first to review!',
                fontSize: 13,
                color: AppColors.textColorHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _navigateToAllReviews(),
              child: Center(
                child: AppText(
                  'See all ${reviews.length} reviews',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepPink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToAllReviews() {
    Get.to(() => AllReviewsScreen(astrologerId: widget.astrologerId));
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) {
                  final String? photo = review.user?.profilePhoto;
                  final String name = review.user?.name ?? 'U';
                  final bool hasImage = photo != null && photo.isNotEmpty;
                  
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.deepPink.withOpacity(0.1),
                    backgroundImage: hasImage 
                        ? NetworkImage(AppUrls.baseImageUrl + photo) 
                        : null,
                    child: hasImage 
                        ? null 
                        : AppText(
                            name[0].toUpperCase(),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepPink,
                          ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  review.user?.name ?? 'Unknown',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF880E4F),
                ),
              ),
             // const Icon(Icons.more_vert, size: 20, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          CustomRatingBar(rating: review.rating, size: 16),
          const SizedBox(height: 8),
          AppText(
            review.review,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF880E4F),
            style: const TextStyle(height: 1.4),
          ),
          if (review.reply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEbee),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    _astrologer?.name ?? "Astrologer",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A148C),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    review.reply!,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF4A148C),
                    style: const TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGiftItems() {
    return Obx(() {
      if (_controller.isGiftsLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      
      if (_controller.gifts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No gifts available'),
          ),
        );
      }
      
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _controller.gifts.length,
        itemBuilder: (context, index) {
          final gift = _controller.gifts[index];
          return InkWell(
            onTap: () {
              if (_astrologer != null) {
                final walletController = Get.find<WalletController>();
                final double currentBalance = double.tryParse(walletController.balance) ?? 0.0;
                final double giftPrice = double.tryParse(gift.price.toString()) ?? 0.0;

                if (currentBalance < giftPrice) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => RechargeBottomSheet(
                      neededAmount: giftPrice,
                      serviceType: 'gift',
                    ),
                  );
                } else {
                  _controller.sendGift(gift, _astrologer!.id);
                }
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.deepPink.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Obx(() => _controller.sendingGiftId.value == gift.id
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.pink)
                      )
                    : CustomImageWidget(
                        imagePath: gift.iconUrl,
                        height: 35,
                        width: 35,
                        fit: BoxFit.contain,
                        fallbackWidget: const Icon(Icons.card_giftcard, color: Colors.pink, size: 24),
                      ),
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  gift.title,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF880E4F),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText(
                  '₹ ${gift.price}',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF880E4F),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_astrologer?.isChatEnabled == true)
          Expanded(
            child: GestureDetector(
              onTap: _astrologer?.isBlocked == true 
                ? () => CustomSnackbar.showError("This astrologer is blocked") 
                : () {
                    final walletController = Get.find<WalletController>();
                    final double balance = double.tryParse(walletController.balance) ?? 0.0;
                    WalletHelper.checkBalanceAndProceed(
                      context: context,
                      type: 'chat',
                      name: _astrologer?.name ?? 'Astrologer',
                      imageUrl: _astrologer?.fullProfilePhoto ?? '',
                      price: _astrologer?.chatRate ?? '0',
                      providerId: widget.astrologerId,
                      simulatedBalance: balance,
                    );
                  },
              child: Opacity(
                opacity: _astrologer?.isBlocked == true ? 0.6 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _astrologer?.isBlocked == true 
                        ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600])
                        : const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF388E3C)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (_astrologer?.isBlocked == true ? Colors.grey : const Color(0xFF4CAF50)).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.message_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_astrologer?.isBlocked == true ? 'Blocked' : 'Chat', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('₹${_astrologer?.chatRate ?? '0'}/min', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if(_astrologer?.isCallEnabled == true|| _astrologer?.isVideoCallEnabled == true)
          Expanded(
            child: GestureDetector(
              onTap: _astrologer?.isBlocked == true 
                ? () => CustomSnackbar.showError("This astrologer is blocked") 
                : () {
                    final walletController = Get.find<WalletController>();
                    final double balance = double.tryParse(walletController.balance) ?? 0.0;
                    WalletHelper.checkBalanceAndProceed(
                      context: context,
                      type: 'call',
                      name: _astrologer?.name ?? 'Astrologer',
                      imageUrl: _astrologer?.fullProfilePhoto ?? '',
                      price: _astrologer?.callRate ?? '0',
                      providerId: widget.astrologerId,
                      simulatedBalance: balance,
                    );
                  },
              child: Opacity(
                opacity: _astrologer?.isBlocked == true ? 0.6 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _astrologer?.isBlocked == true 
                        ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600])
                        : const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (_astrologer?.isBlocked == true ? Colors.grey : const Color(0xFFD32F2F)).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.call, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_astrologer?.isBlocked == true ? 'Blocked' : 'Call', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('₹${_astrologer?.callRate ?? '0'}/min', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatAssistantSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent, color: Color(0xFFE91E63), size: 24),
          const SizedBox(width: 8),
          AppText('Chat with Assistant', fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFFC2185B)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Color(0xFFE91E63)),
        ],
      ),
    );
  }

  Widget _buildGiftSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard, color: Color(0xFFE91E63), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: AppText('Send Gifts', fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFFC2185B), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  if (_astrologer != null) {
                    Get.bottomSheet(
                      GiftHistoryBottomSheet(
                        astrologerId: _astrologer!.id,
                        astrologerName: _astrologer!.name,
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  }
                },
                child: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              ),
              const Spacer(),
              Obx(() {
                final walletController = Get.find<WalletController>();
                return AppText('₹ ${walletController.balance}', fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFC2185B));
              }),
            ],
          ),
          const SizedBox(height: 16),
          _buildGiftItems(),
        ],
      ),
    );
  }

  void _showFullScreenGallery(BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
          body: PageView.builder(
            itemCount: images.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: Center(child: Image.network(images[index], fit: BoxFit.contain)));
            },
          ),
        ),
      ),
    );
  }
}

class _BioText extends StatefulWidget {
  final String bio;
  const _BioText({Key? key, required this.bio}) : super(key: key);

  @override
  State<_BioText> createState() => _BioTextState();
}

class _BioTextState extends State<_BioText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          widget.bio,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textColorSecondary,
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
          style: const TextStyle(height: 1.6),
        ),
        if (widget.bio.length > 100) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: AppText(
                isExpanded ? 'Show less' : 'See more',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.deepPink,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

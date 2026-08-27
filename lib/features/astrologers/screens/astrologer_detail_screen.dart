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
import '../../../core/utils/session_bottom_sheet_helper.dart';
import '../../chat_assistance/presentation/controllers/chat_assistance_controller.dart';
import '../../../core/constants/image_constants.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../home/widgets/astrologer_action_buttons.dart';

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
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFAF5EF),
                  Color(0xFFFDF9F5),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.08,
            child: Image.asset(
              ImageConstants.loginBackground,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // AppBar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: false,
                  title: _astrologer != null 
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AppText(
                            _astrologer!.name,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textColorPrimary,
                          ),
                        )
                      : const SizedBox.shrink(),
                  centerTitle: true,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D), size: 20),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF2D2D2D), size: 20),
                        padding: EdgeInsets.zero,
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
                        final Set<String> choices = {
                          _astrologer?.isBlocked == true ? 'Unblock' : 'Block',
                          'Report',
                        };
                        if (_astrologer?.isReviewEligible == true) {
                          choices.add('Review');
                        }
                        return choices.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: AppText(
                              choice.tr,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorPrimary,
                            ),
                          );
                        }).toList();
                      },
                    ),
    ),
                  ],
                ),
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
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
                        if (_astrologer != null && _astrologer!.bio.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _BioText(bio: _astrologer!.bio),
                          ),
                        const SizedBox(height: 16),
                        // Gallery Section - commented out
                        // _buildGallerySection(),
                        // const SizedBox(height: 16),
                        // Reviews Section
                        Obx(() => _buildReviewsSection()),
                        const SizedBox(height: 16),
                        // Chat with Assistant
                        _buildChatAssistantSection(),
                        const SizedBox(height: 16),
                        // Send Gift
                        _buildGiftSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: (_astrologer?.isBlocked == true || (_astrologer?.isAvailableOnline ?? false))
          ? _buildBottomActions(context)
          : null,

     // bottomNavigationBar: _buildBottomActions(context),

        ),
      ],
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
                "Unblock @name?".trParams({'name': name}),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),
              AppText(
                "You will be able to message and call this astrologer again.".tr,
                fontSize: 14,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Cancel".tr,
                      backgroundColor: Colors.grey.shade100,
                      textColor: Colors.black87,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: "Unblock".tr,
                      backgroundColor: Colors.green,
                      onTap: () async {
                        Get.back(); // Close bottom sheet
                        try {
                          final result = await _controller.unblockAstrologer(widget.astrologerId);
                          if (result.isSuccess) {
                            CustomSnackbar.showSuccess(result.message);
                            _fetchAstrologer(); // Refresh local detail state
                            // Silently refresh global lists
                            if (Get.isRegistered<ProfileController>()) {
                              Get.find<ProfileController>().fetchBlocked(showLoader: false);
                            }
                            if (Get.isRegistered<AstrologerController>()) {
                              Get.find<AstrologerController>().fetchAstrologers(showLoader: false);
                            }
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
                "Block @name?".trParams({'name': name}),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),
              AppText(
                "You won't be able to message or call this astrologer anymore.".tr,
                fontSize: 14,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Cancel".tr,
                      backgroundColor: Colors.grey.shade100,
                      textColor: Colors.black87,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: "Block".tr,
                      backgroundColor: Colors.red,
                      onTap: () async {
                        Get.back(); // Close bottom sheet
                        try {
                          final result = await _controller.blockAstrologer(widget.astrologerId);
                          if (result.isSuccess) {
                            CustomSnackbar.showSuccess(result.message);
                            // Silently refresh global lists
                            if (Get.isRegistered<ProfileController>()) {
                              Get.find<ProfileController>().fetchBlocked(showLoader: false);
                            }
                            if (Get.isRegistered<AstrologerController>()) {
                              Get.find<AstrologerController>().fetchAstrologers(showLoader: false);
                            }
                            // Navigate back after blocking
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
                          hintText: "How was your session?".tr,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: "Post Review".tr,
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
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                          ),
                          child: CustomImageWidget(
                            imagePath: astro.fullProfilePhoto,
                            fit: BoxFit.cover,
                            radius: BorderRadius.circular(37.5),
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
                            color: astro.statusBadge['color'],
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
                      color: astro.statusBadge['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: astro.statusBadge['color'].withOpacity(0.5), width: 0.5),
                    ),
                    child: AppText(
                      astro.statusBadge['text'],
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: astro.statusBadge['color'],
                    ),
                  ),
                  // if (astro.isBlocked)
                  //   Container(
                  //     margin: const EdgeInsets.only(top: 4),
                  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  //     decoration: BoxDecoration(
                  //       color: Colors.red.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(10),
                  //       border: Border.all(color: Colors.red.withOpacity(0.5), width: 0.5),
                  //     ),
                  //     child: const AppText(
                  //       'Blocked',
                  //       fontSize: 10,
                  //       fontWeight: FontWeight.w700,
                  //       color: Colors.red,
                  //     ),
                  //   ),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textColorPrimary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: Color(0xFF4CAF50), size: 16),
                                ],
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                astro.areasOfExpertise.map((e) => e.trim().tr).join(', '),
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
                                text: _controller.isFollowing.value ? 'Following'.tr : 'Follow'.tr,
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
                      astro.languages.map((l) => l.trim().tr).join(', '),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorHint,
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          '${"Exp".tr}: ${astro.yearsOfExperience} ${"Years".tr}',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textColorPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (astro.hasOffer && astro.originalChatRatePerMinute != null)
                              AppText(
                                '₹ ${double.tryParse(astro.originalChatRatePerMinute!)?.toStringAsFixed(2) ?? astro.originalChatRatePerMinute!}',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                                style: GoogleFonts.inter(decoration: TextDecoration.lineThrough),
                              ),
                            if (astro.hasOffer && astro.originalChatRatePerMinute != null)
                              const SizedBox(width: 6),
                            AppText(
                              '₹ ${double.tryParse(astro.chatRate ?? '0')?.toStringAsFixed(2) ?? astro.chatRate ?? '0'}',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.deepPink,
                            ),
                            AppText('/min', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                            if (astro.hasOffer) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: AppText(
                                  '${astro.discountPercentage ?? ''}% OFF',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
          // Row(
          //   children: [
          //     Expanded(
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          //         decoration: BoxDecoration(
          //           color: Colors.transparent,
          //           borderRadius: BorderRadius.circular(20),
          //           border: Border.all(color: Colors.grey.withOpacity(0.3)),
          //         ),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             const Icon(Icons.bolt, color: Colors.amber, size: 16),
          //             const SizedBox(width: 6),
          //             Flexible(
          //               child: AppText(
          //                 '₹ 30/session for 30 minute complete guide',
          //                 fontSize: 12,
          //                 fontWeight: FontWeight.w600,
          //                 color: Colors.black87,
          //                 maxLines: 1,
          //                 overflow: TextOverflow.ellipsis,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
                  'See all',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) {
                  final String? photo = review.user?.profilePhoto;
                  final bool hasImage = photo != null && photo.isNotEmpty;
                  
                  return CustomImageWidget(
                    imagePath: hasImage ? AppUrls.baseImageUrl + photo : null,
                    height: 36,
                    width: 36,
                    radius: BorderRadius.circular(18),
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  review.user?.name ?? 'Unknown',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
            style: const TextStyle(height: 1.4),
          ),
          if (review.reply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              margin: const EdgeInsets.only(left: 4, top: 4),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "Reply from ${_astrologer?.name ?? "Astrologer"}",
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    review.reply!,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
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
          mainAxisSpacing: 8,
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
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor)
                      )
                    : CustomImageWidget(
                        imagePath: gift.iconUrl,
                        height: 35,
                        width: 35,
                        fit: BoxFit.contain,
                        fallbackWidget: const Icon(Icons.card_giftcard, color: AppColors.primaryColor, size: 24),
                      ),
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  gift.title,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText(
                  '₹ ${gift.price}',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildBottomActions(BuildContext context) {
    if (_astrologer?.isBlocked == true) {
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
        child: CustomButton(
          text: 'Unblock'.tr,
          icon: Icons.lock_open,
          fontSize: 14,
          height: 48,
          width: double.infinity,
          borderRadius: 12,
          backgroundColor: AppColors.deepPink,
          textColor: Colors.white,
          borderColor: AppColors.deepPink,
          onTap: () async {
            final response = await _controller.unblockAstrologer(widget.astrologerId);
            if (response.isSuccess) {
              CustomSnackbar.showSuccess(response.message);
              _fetchAstrologer(); // refresh local detail state
              // Silently refresh global lists
              if (Get.isRegistered<ProfileController>()) {
                Get.find<ProfileController>().fetchBlocked(showLoader: false);
              }
              if (Get.isRegistered<AstrologerController>()) {
                Get.find<AstrologerController>().fetchAstrologers(showLoader: false);
              }
            } else {
              CustomSnackbar.showError(response.message);
            }
          },
        ),
      );
    }

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_astrologer?.isAvailableOnline == true) ...[
            CustomButton(
              text: _astrologer?.packageSessionText ?? 'Session (1 hr) @ ₹500',
              icon: Icons.timer,
              fontSize: 14,
              height: 48,
              width: double.infinity,
              borderRadius: 12,
              backgroundColor: (_astrologer?.isPurchase == true ? Colors.green : Colors.orange),
              textColor: Colors.white,
              borderColor: (_astrologer?.isPurchase == true ? Colors.green : Colors.orange),
              onTap: () {
                if (_astrologer != null) {
                  SessionBottomSheetHelper.show(context, _astrologer!);
                }
              },
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (_astrologer != null)
                Expanded(
                  child: AstrologerActionButtons(
                    astro: _astrologer!,
                    isDetailStyle: true,
                    showChat: true,
                    showCall: true,
                    providerIdFallback: widget.astrologerId,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatAssistantSection() {
    if (_astrologer?.isBlocked == true) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () {
        if (_astrologer != null) {
          final chatAssistanceController = Get.put(ChatAssistanceController());
          chatAssistanceController.initiateChatAssistance(
            _astrologer!.userId ?? widget.astrologerId,
            astroName: _astrologer!.name,
            astroImage: _astrologer!.fullProfilePhoto,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCDD2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.support_agent, color: AppColors.primaryColor, size: 24),
            const SizedBox(width: 8),
            const AppText('Assistance Chat', fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primaryColor),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: AppText('Send Gifts', fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primaryColor, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                return AppText('₹ ${walletController.balance}', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryColor);
              }),
            ],
          ),
          const SizedBox(height: 32),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'About Astrologer',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 12),
          AppText(
            widget.bio,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
            style: const TextStyle(height: 1.5),
          ),
          if (widget.bio.length > 80) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: AppText(
                  isExpanded ? 'Show less' : 'Show more',
                  fontSize: 13,
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../home/controllers/remedy_controller.dart';
import '../../home/domain/models/remedy_model.dart';

class RemedyDetailScreen extends StatefulWidget {
  /// The remedy id to fetch detail for
  final int remedyId;

  /// The accent color cycled from the list screen
  final Color accentColor;

  /// The exact image url shown on the list card
  final String imageUrl;

  const RemedyDetailScreen({
    Key? key,
    required this.remedyId,
    required this.imageUrl,
    this.accentColor = AppColors.deepPink,
  }) : super(key: key);

  @override
  State<RemedyDetailScreen> createState() => _RemedyDetailScreenState();
}

class _RemedyDetailScreenState extends State<RemedyDetailScreen> {
  RemedyModel? _remedy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final controller = Get.find<RemedyController>();
    final result = await controller.fetchRemedyById(widget.remedyId);
    if (mounted) {
      setState(() {
        _remedy = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor;
    final imageUrl = widget.imageUrl;  // ← use exactly the same image from the list

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: _remedy?.title ?? 'Remedy Detail',
        backgroundColor: color.withOpacity(0.05),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: color,
                strokeWidth: 2,
              ),
            )
          : _remedy == null
              ? const Center(
                  child: AppText(
                    'Could not load remedy detail.',
                    fontSize: 15,
                    color: Colors.black45,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero image banner ──────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              color.withOpacity(0.08),
                              Colors.white,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.15),
                                  blurRadius: 40,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Image.network(
                              imageUrl,
                              width: 120,
                              height: 120,
                              color: color,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.auto_fix_high_rounded,
                                size: 120,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Content ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            AppText(
                              _remedy!.title,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                            const SizedBox(height: 16),

                            // Description
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: color.withOpacity(0.15),
                                ),
                              ),
                              child: AppText(
                                _remedy!.description,
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Disclaimer
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blueGrey, size: 20),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: AppText(
                                      'Consult with an expert astrologer for personalized remedies based on your birth chart.',
                                      fontSize: 12,
                                      color: Colors.blueGrey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Shows a bottom sheet to pick an image from Camera or Gallery.
  /// Returns the selected [File] or null if canceled.
  static Future<File?> showImagePickerSheet(BuildContext context) async {
    File? selectedFile;

    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              "Select Image Source",
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  icon: Iconsax.camera_copy,
                  label: "Camera",
                  onTap: () async {
                    final XFile? photo = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 70,
                    );
                    if (photo != null) {
                      selectedFile = File(photo.path);
                    }
                    Get.back();
                  },
                ),
                _buildOption(
                  icon: Iconsax.gallery_copy,
                  label: "Gallery",
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );
                    if (image != null) {
                      selectedFile = File(image.path);
                    }
                    Get.back();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    return selectedFile;
  }

  static Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.deepPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.deepPink, size: 30),
          ),
          const SizedBox(height: 12),
          AppText(
            label,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textColorPrimary,
          ),
        ],
      ),
    );
  }
}

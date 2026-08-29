import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/image_constants.dart';
import 'shimmer_widget.dart';

/// Enum to represent different image types
enum ImageType { svg, svgString, png, network, file, gif, unknown }

/// Extension to determine the type of image based on its path
extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('<svg')) {
      return ImageType.svgString;
    } else if (startsWith('http') || startsWith('https')) {
      if (toLowerCase().endsWith('.gif')) {
        return ImageType.gif;
      }
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('file://')) {
      if (toLowerCase().endsWith('.gif')) {
        return ImageType.gif;
      }
      return ImageType.file;
    } else if (endsWith('.png') || endsWith('.jpg') || endsWith('.jpeg')) {
      return ImageType.png;
    } else if (endsWith('.gif')) {
      return ImageType.gif;
    } else {
      return ImageType.unknown;
    }
  }
}

/// A reusable custom image widget
class CustomImageWidget extends StatelessWidget {
  const CustomImageWidget({
    super.key,
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.fallbackWidget,
    this.placeHolder = ImageConstants.imageNotFound,
  });

  final String? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final String placeHolder;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;
  final Widget? fallbackWidget;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment!,
      child: _buildWidget(),
    )
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: _buildCircleImage(),
              ),
            )
          : _buildCircleImage(),
    );
  }

  Widget _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius!,
        child: _buildImageWithBorder(),
      );
    }
    return _buildImageWithBorder();
  }

  Widget _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: _buildImageView(),
      );
    }
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      switch (imagePath!.imageType) {
        case ImageType.svg:
          return SvgPicture.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          );
        case ImageType.svgString:
          return SvgPicture.string(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          );
        case ImageType.file:
          return Image.file(
            File(imagePath!),
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
          );
        case ImageType.network:
          return CachedNetworkImage(
            height: height,
            width: width,
            fit: fit,
            imageUrl: imagePath!,
            color: color,
            placeholder: (context, url) => ShimmerWidget.rectangular(
              height: height ?? double.infinity,
              width: width ?? double.infinity,
            ),
            errorWidget: (context, url, error) => fallbackWidget ?? _buildDefaultFallback(),
          );
        case ImageType.png:
          return Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
          );
        case ImageType.gif:
          if (imagePath!.startsWith('http')) {
            return FutureBuilder<File>(
              future: DefaultCacheManager().getSingleFile(imagePath!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ShimmerWidget.rectangular(
                    height: height ?? 30,
                    width: width ?? 30,
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Image.network(
                    imagePath!,
                    height: height,
                    width: width,
                    fit: fit ?? BoxFit.cover,
                    color: color,
                    errorBuilder: (context, error, stackTrace) => fallbackWidget ?? _buildDefaultFallback(),
                  );
                } else {
                  return Image.file(
                    snapshot.data!,
                    height: height,
                    width: width,
                    fit: fit ?? BoxFit.cover,
                    color: color,
                  );
                }
              },
            );
          } else if (imagePath!.startsWith('file://')) {
            return Image.file(
              File(imagePath!),
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
              color: color,
            );
          } else {
            return Image.asset(
              imagePath!,
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
              color: color,
            );
          }
        case ImageType.unknown:
          return fallbackWidget ?? _buildDefaultFallback();
      }
    }
    return fallbackWidget ?? _buildDefaultFallback();
  }

  Widget _buildDefaultFallback() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: radius,
      ),
      child: Center(
        child: Icon(Icons.person, color: Colors.grey.shade400, size: (height != null ? height! * 0.5 : 24)),
      ),
    );
  }
}

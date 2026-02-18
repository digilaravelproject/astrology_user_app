import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showLeading;
  final VoidCallback? onLeadingPressed;
  final Color backgroundColor;
  final Color titleColor;
  final Color? iconColor;
  final bool centerTitle;
  final double elevation;



  const CustomAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.showLeading = true,
    this.onLeadingPressed,
    this.backgroundColor = Colors.white,
    this.titleColor = const Color(0xFF2E1A47),
    this.iconColor,
    this.centerTitle = false,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      title: titleWidget ?? AppText(
        title,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: titleColor,
      ),
      leading: showLeading
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: iconColor ?? titleColor),
              onPressed: onLeadingPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

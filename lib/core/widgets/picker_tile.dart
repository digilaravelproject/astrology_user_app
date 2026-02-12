import 'package:flutter/material.dart';

/// Reusable picker tile widget for Date/Time selection
class PickerTile extends StatelessWidget {
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  const PickerTile({
    Key? key,
    required this.hint,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF8F00), size: 24),
            const SizedBox(width: 15),
            Text(
              hint,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E1A47),
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

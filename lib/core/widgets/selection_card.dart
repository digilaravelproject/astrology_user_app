import 'package:flutter/material.dart';

/// Reusable selection card widget (e.g., for Gender selection)
class SelectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFF9933).withOpacity(0.12) 
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFFF8F00) 
                : Colors.black.withOpacity(0.08),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFFF8F00).withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: isSelected ? 60 : 52,
              color: isSelected 
                  ? const Color(0xFFFF6D00) 
                  : Colors.black.withOpacity(0.25),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected 
                    ? const Color(0xFF2E1A47) 
                    : Colors.black.withOpacity(0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

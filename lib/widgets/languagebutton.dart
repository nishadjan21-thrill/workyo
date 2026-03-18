import 'package:flutter/material.dart';
import '../widgets/app_card.dart';

import '../theme/app_textstyles.dart';

class LanguageOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // 🌐 Text section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ✅ Selection UI
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF1E6CFF)
                    : Colors.white.withValues(alpha: 0.1),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.circle_outlined,
                color: isSelected ? Colors.white : Colors.white54,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
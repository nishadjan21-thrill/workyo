import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: Colors.transparent,
        

        
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.card.withValues(alpha: 0.9),
            AppColors.card,
            Colors.black.withValues(alpha: 0.9),
          ],
        ),

        
       
        
      ),

      child: Stack(
        children: [
          // ✨ Glossy shine layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey,
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // 🔲 Actual content
          Container(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
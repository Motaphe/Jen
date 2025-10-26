import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BottomNav extends StatelessWidget {
  final String currentScreen;
  final Function(String) onNavigate;

  const BottomNav({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.mantle,
        boxShadow: [
          BoxShadow(
            color: AppColors.crust.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            screenKey: 'home',
            isActive: currentScreen == 'home',
          ),
          _buildNavItem(
            icon: Icons.book,
            label: 'Journal',
            screenKey: 'journal',
            isActive: currentScreen == 'journal',
          ),
          _buildNavItem(
            icon: Icons.mood,
            label: 'Mood',
            screenKey: 'mood',
            isActive: currentScreen == 'mood',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String screenKey,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onNavigate(screenKey),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.lavender : AppColors.overlay0,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.lavender : AppColors.overlay0,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

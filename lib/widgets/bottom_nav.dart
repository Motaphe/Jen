import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final backgroundColor = colorScheme.surface;
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.4 : 0.12);
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withValues(alpha: isDark ? 0.6 : 0.65);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
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
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
          _buildNavItem(
            icon: Icons.book,
            label: 'Journal',
            screenKey: 'journal',
            isActive: currentScreen == 'journal',
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
          _buildNavItem(
            icon: Icons.mood,
            label: 'Mood',
            screenKey: 'mood',
            isActive: currentScreen == 'mood',
            activeColor: activeColor,
            inactiveColor: inactiveColor,
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
    required Color activeColor,
    required Color inactiveColor,
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
              color: isActive ? activeColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

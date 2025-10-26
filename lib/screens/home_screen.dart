import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/preferences_helper.dart';

class HomeScreen extends StatelessWidget {
  final String? userName;
  final Function(String) onNavigate;
  final Function(String?) onUpdateName;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.onNavigate,
    required this.onUpdateName,
  });

  Future<void> _showEditNameDialog(BuildContext context) async {
    final nameController = TextEditingController(text: userName ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Edit Name',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: const TextStyle(color: AppColors.overlay0),
                filled: true,
                fillColor: AppColors.base,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (value) {
                Navigator.pop(context, value.trim());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.overlay1),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              Navigator.pop(context, name.isEmpty ? null : name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lavender,
              foregroundColor: AppColors.base,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      HapticFeedback.lightImpact();
      if (result.isEmpty) {
        await PreferencesHelper.setUserName('');
        onUpdateName(null);
      } else {
        await PreferencesHelper.setUserName(result);
        onUpdateName(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome back',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showEditNameDialog(context),
                child: Row(
                  children: [
                    Text(
                      userName ?? 'Jen',
                      style: AppTextStyles.heading1,
                    ),
                    if (userName != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.edit,
                        size: 20,
                        color: AppColors.overlay1,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      title: 'Affirmations',
                      subtitle: 'Daily motivation',
                      icon: Icons.auto_awesome,
                      color: AppColors.lavender,
                      onTap: () => onNavigate('affirmations'),
                    ),
                    _buildFeatureCard(
                      title: 'Journal',
                      subtitle: 'Your thoughts',
                      icon: Icons.book,
                      color: AppColors.blue,
                      onTap: () => onNavigate('journal'),
                    ),
                    _buildFeatureCard(
                      title: 'Mood Tracker',
                      subtitle: 'Track emotions',
                      icon: Icons.mood,
                      color: AppColors.green,
                      onTap: () => onNavigate('mood'),
                    ),
                    _buildFeatureCard(
                      title: 'Breathing',
                      subtitle: 'Relax & breathe',
                      icon: Icons.air,
                      color: AppColors.teal,
                      onTap: () => onNavigate('breathing'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildLockdownCard(
                onTap: () => onNavigate('lockdown'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockdownCard({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mauve.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_clock,
                  color: AppColors.mauve,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lockdown Mode',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Focus time without distractions',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.overlay1,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/database_helper.dart';
import '../models/water_entry.dart';

/// Water intake tracker with 8-glass daily goal and periodic reminders.
/// Uses timer to prompt hydration with haptic feedback.
class WaterReminderScreen extends StatefulWidget {
  final VoidCallback onBack;

  const WaterReminderScreen({super.key, required this.onBack});

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen> {
  Timer? _reminderTimer;
  List<WaterEntry> _todayEntries = [];
  bool _isLoading = true;
  final int _targetGlasses = 8; // Daily hydration goal

  @override
  void initState() {
    super.initState();
    _loadTodayEntries();
    _startReminderTimer();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTodayEntries() async {
    final entries = await DatabaseHelper.instance.getWaterEntriesForDate(DateTime.now());
    setState(() {
      _todayEntries = entries;
      _isLoading = false;
    });
  }

  void _startReminderTimer() {
    // Reminder every 2 hours (7200 seconds)
    _reminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
      if (mounted) {
        _showWaterReminder();
      }
    });
  }

  void _showWaterReminder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.local_drink,
              color: AppColors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Water Reminder',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        content: Text(
          'Time to hydrate! Have you had a glass of water?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logWater(false);
            },
            child: const Text(
              'Not Yet',
              style: TextStyle(color: AppColors.overlay1),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              await _logWater(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.base,
            ),
            child: const Text('Yes, I Did!'),
          ),
        ],
      ),
    );
  }

  Future<void> _logWater(bool confirmed) async {
    final entry = WaterEntry(
      timestamp: DateTime.now(),
      confirmed: confirmed,
    );

    await DatabaseHelper.instance.createWaterEntry(entry);
    await _loadTodayEntries();

    if (mounted && confirmed) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Great job! ${_todayEntries.where((e) => e.confirmed).length} glasses today'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.blue,
        ),
      );
    }
  }

  Future<void> _manualLog() async {
    HapticFeedback.lightImpact();
    await _logWater(true);
  }

  int get _confirmedCount => _todayEntries.where((e) => e.confirmed).length;
  double get _progress => (_confirmedCount / _targetGlasses).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.base : AppColors.latteBase,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.base : AppColors.latteBase,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.text : AppColors.latteText,
          ),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Water Reminder',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? AppColors.text : AppColors.latteText,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.blue,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Progress circle
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.surface0 : AppColors.latteSurface0,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: _progress,
                              strokeWidth: 12,
                              backgroundColor: isDark ? AppColors.surface1 : AppColors.latteSurface1,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.blue,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_drink,
                                size: 48,
                                color: AppColors.blue,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$_confirmedCount / $_targetGlasses',
                                style: AppTextStyles.heading1.copyWith(
                                  fontSize: 32,
                                  color: isDark ? AppColors.text : AppColors.latteText,
                                ),
                              ),
                              Text(
                                'glasses today',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Manual log button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _manualLog,
                        icon: const Icon(Icons.add),
                        label: const Text('Log Water Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: AppColors.base,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface0 : AppColors.latteSurface0,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Hydration Tips',
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: 16,
                                  color: isDark ? AppColors.text : AppColors.latteText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Stay hydrated throughout the day! Aim for 8 glasses of water. You\'ll receive reminders every 2 hours.',
                            style: AppTextStyles.bodySecondary.copyWith(
                              color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Today's log
                    if (_todayEntries.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Today\'s Log',
                          style: AppTextStyles.heading3.copyWith(
                            color: isDark ? AppColors.text : AppColors.latteText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todayEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _todayEntries[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surface0 : AppColors.latteSurface0,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  entry.confirmed
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: entry.confirmed
                                      ? AppColors.green
                                      : AppColors.overlay1,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.confirmed
                                        ? 'Drank water'
                                        : 'Reminder dismissed',
                                    style: AppTextStyles.body.copyWith(
                                      color: isDark ? AppColors.text : AppColors.latteText,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTime(entry.timestamp),
                                  style: AppTextStyles.caption.copyWith(
                                    color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

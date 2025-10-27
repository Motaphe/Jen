import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/database_helper.dart';
import '../models/lockdown_entry.dart';
import 'lockdown_history_screen.dart';

class LockdownScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LockdownScreen({super.key, required this.onBack});

  @override
  State<LockdownScreen> createState() => _LockdownScreenState();
}

class _LockdownScreenState extends State<LockdownScreen> {
  bool _isActive = false;
  int _selectedMinutes = 15;
  int _remainingSeconds = 0;
  Timer? _timer;
  String? _taskName;
  DateTime? _startTime;

  final List<int> _timeOptions = [5, 15, 30, 60];

  void _toggleLockdown() {
    if (_isActive) {
      _showStopConfirmation();
    } else {
      _showTaskNameDialog();
    }
  }

  Future<void> _showTaskNameDialog() async {
    final taskController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'What are you focusing on?',
          style: AppTextStyles.heading3,
        ),
        content: TextField(
          controller: taskController,
          autofocus: true,
          style: const TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            hintText: 'e.g., Study, Work, Meditate (optional)',
            hintStyle: const TextStyle(color: AppColors.overlay0),
            filled: true,
            fillColor: AppColors.base,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text(
              'Skip',
              style: TextStyle(color: AppColors.overlay1),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final task = taskController.text.trim();
              Navigator.pop(context, task);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mauve,
              foregroundColor: AppColors.base,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (result != null) {
      _startLockdown(result.isEmpty ? null : result);
    }
  }

  void _startLockdown(String? taskName) {
    setState(() {
      _isActive = true;
      _remainingSeconds = _selectedMinutes * 60;
      _taskName = taskName;
      _startTime = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _completeLockdown();
        }
      });
    });
  }

  Future<void> _completeLockdown() async {
    _timer?.cancel();

    final entry = LockdownEntry(
      startTime: _startTime!,
      durationMinutes: _selectedMinutes,
      completed: true,
      taskName: _taskName,
    );

    await DatabaseHelper.instance.createLockdownEntry(entry);

    setState(() {
      _isActive = false;
      _remainingSeconds = 0;
      _taskName = null;
      _startTime = null;
    });

    if (mounted) {
      _showCompletionDialog();
    }
  }

  Future<void> _showStopConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface0,
        title: Text(
          'End Early?',
          style: AppTextStyles.heading3,
        ),
        content: Text(
          'Are you sure you want to end this focus session early?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Continue',
              style: TextStyle(color: AppColors.green),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'End Session',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _cancelLockdown();
    }
  }

  Future<void> _cancelLockdown() async {
    _timer?.cancel();

    final entry = LockdownEntry(
      startTime: _startTime!,
      durationMinutes: _selectedMinutes,
      completed: false,
      taskName: _taskName,
    );

    await DatabaseHelper.instance.createLockdownEntry(entry);

    setState(() {
      _isActive = false;
      _remainingSeconds = 0;
      _taskName = null;
      _startTime = null;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface0,
        title: Text(
          'Lockdown Complete!',
          style: AppTextStyles.heading3,
        ),
        content: Text(
          'Great job staying focused! 🎉',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: AppTextStyles.body.copyWith(
                color: AppColors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Lockdown Mode',
          style: AppTextStyles.heading3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.text),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LockdownHistoryScreen(
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
            tooltip: 'View History',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isActive ? Icons.lock : Icons.lock_clock,
                    size: 80,
                    color: _isActive ? AppColors.mauve : AppColors.overlay0,
                  ),
                  const SizedBox(height: 32),
                  if (_isActive) ...[
                    Text(
                      'Focus Mode Active',
                      style: AppTextStyles.heading2,
                    ),
                    if (_taskName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _taskName!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mauve,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 64,
                        color: AppColors.mauve,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Stay focused on your task',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ] else ...[
                    Text(
                      'Select Duration',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: _timeOptions.map((minutes) {
                        return _buildTimeOption(minutes);
                      }).toList(),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface0,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.mauve,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'What is Lockdown Mode?',
                                  style: AppTextStyles.heading3.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Lockdown mode helps you stay focused by encouraging you to minimize distractions. Use this time to be present and mindful.',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _toggleLockdown,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isActive ? AppColors.red : AppColors.mauve,
                  foregroundColor: AppColors.base,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isActive ? 'End Lockdown' : 'Start Lockdown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOption(int minutes) {
    final isSelected = _selectedMinutes == minutes;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMinutes = minutes;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mauve.withValues(alpha: 0.3) : AppColors.surface0,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.mauve : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$minutes',
              style: AppTextStyles.heading2.copyWith(
                color: isSelected ? AppColors.mauve : AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'minutes',
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.mauve : AppColors.overlay1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/database_helper.dart';
import '../models/lockdown_entry.dart';

class LockdownHistoryScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LockdownHistoryScreen({super.key, required this.onBack});

  @override
  State<LockdownHistoryScreen> createState() => _LockdownHistoryScreenState();
}

class _LockdownHistoryScreenState extends State<LockdownHistoryScreen> {
  List<LockdownEntry> _entries = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final db = DatabaseHelper.instance;
    final entries = await db.getAllLockdownEntries();
    final stats = await db.getLockdownStats();

    setState(() {
      _entries = entries;
      _stats = stats;
      _isLoading = false;
    });
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
          'Focus History',
          style: AppTextStyles.heading3,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.mauve,
              ),
            )
          : Column(
              children: [
                // Stats Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface0,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Stats',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Sessions',
                              '${_stats['totalSessions'] ?? 0}',
                              Icons.task_alt,
                              AppColors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Completed',
                              '${_stats['completedSessions'] ?? 0}',
                              Icons.check_circle,
                              AppColors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Focus',
                              '${_stats['totalFocusMinutes'] ?? 0} min',
                              Icons.timer,
                              AppColors.mauve,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Success Rate',
                              '${(_stats['completionRate'] ?? 0).toStringAsFixed(0)}%',
                              Icons.trending_up,
                              AppColors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // History List
                Expanded(
                  child: _entries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: AppColors.overlay0,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No sessions yet',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.overlay0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a focus session to see it here',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];
                            return _buildHistoryCard(entry);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.base,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(LockdownEntry entry) {
    final dateStr = _formatDate(entry.startTime);
    final timeStr = DateFormat('h:mm a').format(entry.startTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.completed
              ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: entry.completed
                  ? AppColors.green.withValues(alpha: 0.2)
                  : AppColors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              entry.completed ? Icons.check_circle : Icons.cancel,
              color: entry.completed ? AppColors.green : AppColors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.taskName != null) ...[
                  Text(
                    entry.taskName!,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '${entry.durationMinutes} minutes',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr at $timeStr',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            entry.completed ? 'Done' : 'Ended',
            style: AppTextStyles.caption.copyWith(
              color: entry.completed ? AppColors.green : AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}

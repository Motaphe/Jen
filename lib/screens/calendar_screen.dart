import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/database_helper.dart';

enum ActivityType { journal, mood, lockdown, water, breathing }

class CalendarActivity {
  final ActivityType type;
  final DateTime date;
  final String title;
  final String? subtitle;
  final dynamic data;

  CalendarActivity({
    required this.type,
    required this.date,
    required this.title,
    this.subtitle,
    this.data,
  });
}

class CalendarScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CalendarScreen({super.key, required this.onBack});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<CalendarActivity>> _activitiesByDay = {};
  bool _isLoading = true;
  bool _isCalendarVisible = false;
  late DateTime _selectedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    final db = DatabaseHelper.instance;

    // Load all data
    final journals = await db.getAllJournalEntries();
    final moods = await db.getAllMoodEntries();
    final lockdowns = await db.getAllLockdownEntries();
    final waters = await db.getAllWaterEntries();
    final breathings = await db.getAllBreathingEntries();

    List<CalendarActivity> activities = [];

    // Convert journals
    for (var journal in journals) {
      activities.add(CalendarActivity(
        type: ActivityType.journal,
        date: journal.date,
        title: journal.title,
        subtitle: journal.content.length > 50
            ? '${journal.content.substring(0, 50)}...'
            : journal.content,
        data: journal,
      ));
    }

    // Convert moods
    for (var mood in moods) {
      String moodText = _getMoodText(mood.mood);
      activities.add(CalendarActivity(
        type: ActivityType.mood,
        date: mood.date,
        title: 'Mood: $moodText',
        subtitle: mood.note,
        data: mood,
      ));
    }

    // Convert lockdowns
    for (var lockdown in lockdowns) {
      activities.add(CalendarActivity(
        type: ActivityType.lockdown,
        date: lockdown.startTime,
        title: lockdown.taskName ?? 'Focus Session',
        subtitle:
            '${lockdown.durationMinutes} min - ${lockdown.completed ? "Completed" : "Incomplete"}',
        data: lockdown,
      ));
    }

    // Convert water entries (group by day)
    Map<String, int> waterByDay = {};
    for (var water in waters) {
      if (water.confirmed) {
        String dayKey = DateFormat('yyyy-MM-dd').format(water.timestamp);
        waterByDay[dayKey] = (waterByDay[dayKey] ?? 0) + 1;
      }
    }
    waterByDay.forEach((dayKey, count) {
      DateTime day = DateTime.parse(dayKey);
      activities.add(CalendarActivity(
        type: ActivityType.water,
        date: day,
        title: 'Hydration',
        subtitle: '$count glasses of water',
      ));
    });

    // Convert breathing sessions
    for (var breathing in breathings) {
      if (breathing.completed) {
        activities.add(CalendarActivity(
          type: ActivityType.breathing,
          date: breathing.startTime,
          title: 'Breathing Exercise',
          subtitle: '${breathing.durationSeconds} seconds',
          data: breathing,
        ));
      }
    }

    // Sort by date (newest first)
    activities.sort((a, b) => b.date.compareTo(a.date));

    final Map<DateTime, List<CalendarActivity>> grouped = {};
    for (final activity in activities) {
      final day = _dateOnly(activity.date);
      grouped.putIfAbsent(day, () => []).add(activity);
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => b.date.compareTo(a.date));
    }

    setState(() {
      _activitiesByDay = grouped;
      _isLoading = false;
    });
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _getMoodText(int mood) {
    switch (mood) {
      case 5:
        return 'Very Happy 😄';
      case 4:
        return 'Happy 😊';
      case 3:
        return 'Neutral 😐';
      case 2:
        return 'Sad 😔';
      case 1:
        return 'Very Sad 😢';
      default:
        return 'Unknown';
    }
  }

  Color _getActivityColor(ActivityType type, bool isDark) {
    switch (type) {
      case ActivityType.journal:
        return AppColors.blue;
      case ActivityType.mood:
        return AppColors.yellow;
      case ActivityType.lockdown:
        return AppColors.mauve;
      case ActivityType.water:
        return AppColors.teal;
      case ActivityType.breathing:
        return AppColors.green;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.journal:
        return Icons.book;
      case ActivityType.mood:
        return Icons.mood;
      case ActivityType.lockdown:
        return Icons.lock;
      case ActivityType.water:
        return Icons.local_drink;
      case ActivityType.breathing:
        return Icons.air;
    }
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7;
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;

    final List<DateTime?> days = [];
    for (int i = 0; i < startOffset; i++) {
      days.add(null);
    }
    for (int day = 0; day < daysInMonth; day++) {
      days.add(DateTime(_selectedMonth.year, _selectedMonth.month, day + 1));
    }
    while (days.length < totalCells) {
      days.add(null);
    }
    return days;
  }

  List<CalendarActivity> _activitiesForDate(DateTime date) {
    return _activitiesByDay[_dateOnly(date)] ?? [];
  }

  bool _hasActivities(DateTime date) {
    return _activitiesByDay.containsKey(_dateOnly(date));
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
        1,
      );
      if (_selectedDate.year != _selectedMonth.year ||
          _selectedDate.month != _selectedMonth.month) {
        _selectedDate = _selectedMonth;
      }
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = _dateOnly(date);
      _selectedMonth = DateTime(date.year, date.month, 1);
      _isCalendarVisible = false;
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    setState(() {
      _selectedDate = todayDate;
      _selectedMonth = DateTime(todayDate.year, todayDate.month, 1);
      _isCalendarVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final days = _buildCalendarDays();
    final today = _dateOnly(DateTime.now());
    final selectedActivities = _activitiesForDate(_selectedDate);
    final selectedDateLabel = DateFormat('EEEE, MMMM d').format(_selectedDate);
    final bool isTodaySelected = DateUtils.isSameDay(_selectedDate, today);
    const weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

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
          'Activity Calendar',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? AppColors.text : AppColors.latteText,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.lavender,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedDateLabel,
                              style: AppTextStyles.heading3.copyWith(
                                color: isDark ? AppColors.text : AppColors.latteText,
                              ),
                            ),
                          ),
                          if (isTodaySelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lavender.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Today',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lavender,
                                ),
                              ),
                            ),
                          if (!isTodaySelected)
                            TextButton(
                              onPressed: _jumpToToday,
                              child: const Text('Jump to Today'),
                            ),
                        ],
                      ),
                      if (!_isCalendarVisible) ...[
                        const SizedBox(height: 6),
                        Text(
                          selectedActivities.isEmpty
                              ? 'No activities logged'
                              : '${selectedActivities.length} ${selectedActivities.length == 1 ? "activity" : "activities"} tracked',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _isCalendarVisible
                        ? OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isCalendarVisible = false;
                              });
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Hide Calendar'),
                          )
                        : FilledButton.icon(
                            onPressed: () {
                              setState(() {
                                _isCalendarVisible = true;
                                _selectedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
                              });
                            },
                            icon: const Icon(Icons.calendar_month),
                            label: const Text('Show Calendar'),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_isCalendarVisible)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMonthSelector(isDark),
                          const SizedBox(height: 12),
                          _buildWeekdayLabels(isDark, weekdayLabels),
                          const SizedBox(height: 6),
                          _buildCalendarGrid(days, isDark, today),
                          const SizedBox(height: 16),
                          _buildLegend(isDark),
                          const SizedBox(height: 16),
                          Text(
                            'Select a day above to view its detailed log.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: selectedActivities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_note,
                                  size: 56,
                                  color: isDark ? AppColors.overlay0 : AppColors.latteOverlay0,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nothing logged for this day yet.',
                                  style: AppTextStyles.body.copyWith(
                                    color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap “Show Calendar” to view another date.',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isDark ? AppColors.overlay1 : AppColors.latteOverlay1,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: selectedActivities.length,
                            itemBuilder: (context, index) {
                              final activity = selectedActivities[index];
                              return _buildActivityCard(activity, isDark);
                            },
                          ),
                  ),
              ],
            ),
    );
  }

  Widget _buildMonthSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface0 : AppColors.latteSurface0,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: isDark ? AppColors.text : AppColors.latteText,
            ),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: AppTextStyles.heading3.copyWith(
              color: isDark ? AppColors.text : AppColors.latteText,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.text : AppColors.latteText,
            ),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels(bool isDark, List<String> labels) {
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(List<DateTime?> days, bool isDark, DateTime today) {
    const double spacing = 6;
    final int weekCount = (days.length / 7).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalSpacing = spacing * 6;
        final double cellSize = (constraints.maxWidth - totalSpacing) / 7;

        return Column(
          children: List.generate(weekCount, (weekIndex) {
            return Padding(
              padding: EdgeInsets.only(bottom: weekIndex == weekCount - 1 ? 0 : spacing),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final date = days[(weekIndex * 7) + dayIndex];
                  return Padding(
                    padding: EdgeInsets.only(right: dayIndex == 6 ? 0 : spacing),
                    child: SizedBox(
                      width: cellSize,
                      height: cellSize,
                      child: date == null
                          ? const SizedBox.shrink()
                          : _buildCalendarCell(date, isDark, today),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCalendarCell(DateTime date, bool isDark, DateTime today) {
    final isSelected = DateUtils.isSameDay(date, _selectedDate);
    final isToday = DateUtils.isSameDay(date, today);
    final hasActivities = _hasActivities(date);

    final Color baseBackground = isDark ? AppColors.surface0 : AppColors.latteSurface0;
    final Color backgroundColor = isSelected ? AppColors.lavender : baseBackground;
    final Color textColor =
        isSelected ? AppColors.base : (isDark ? AppColors.text : AppColors.latteText);

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? (isSelected ? AppColors.mauve : AppColors.lavender)
                : Colors.transparent,
            width: isToday ? 2 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.lavender.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: AppTextStyles.body.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            if (hasActivities)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.base : AppColors.lavender,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Journal', ActivityType.journal, isDark),
        _buildLegendItem('Mood', ActivityType.mood, isDark),
        _buildLegendItem('Focus', ActivityType.lockdown, isDark),
        _buildLegendItem('Water', ActivityType.water, isDark),
        _buildLegendItem('Breathing', ActivityType.breathing, isDark),
      ],
    );
  }

  Widget _buildLegendItem(String label, ActivityType type, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getActivityIcon(type),
          size: 16,
          color: _getActivityColor(type, isDark),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(CalendarActivity activity, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface0 : AppColors.latteSurface0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getActivityColor(activity.type, isDark).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type, isDark).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type, isDark),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.text : AppColors.latteText,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(activity.date),
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                      ),
                    ),
                  ],
                ),
                if (activity.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/mood_entry.dart';

class MoodTrackerScreen extends StatefulWidget {
  final List<MoodEntry> moodHistory;
  final Function(List<MoodEntry>) setMoodHistory;

  const MoodTrackerScreen({
    super.key,
    required this.moodHistory,
    required this.setMoodHistory,
  });

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int? selectedMood;
  DateTime selectedDate = DateTime.now();

  void _saveMood() {
    if (selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    final newEntry = MoodEntry(
      mood: selectedMood!,
      date: selectedDate,
    );

    setState(() {
      widget.moodHistory.add(newEntry);
      widget.setMoodHistory(widget.moodHistory);
      selectedMood = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mood logged successfully'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  List<MoodEntry> _getLastWeekMoods() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return widget.moodHistory
        .where((entry) => entry.date.isAfter(weekAgo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    final weekMoods = _getLastWeekMoods();

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.base,
        elevation: 0,
        title: Text(
          'Mood Tracker',
          style: AppTextStyles.heading3,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling today?',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d').format(selectedDate),
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 32),
            _buildMoodSelector(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.base,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log Mood',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Your Week',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            if (weekMoods.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No mood data yet.\nStart tracking to see your trends!',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface0,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildMoodChart(weekMoods),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMoodButton(1, '😢', 'Very Sad', AppColors.moodVerySad),
        _buildMoodButton(2, '😕', 'Sad', AppColors.moodSad),
        _buildMoodButton(3, '😐', 'Okay', AppColors.moodNeutral),
        _buildMoodButton(4, '🙂', 'Good', AppColors.moodHappy),
        _buildMoodButton(5, '😄', 'Great', AppColors.moodVeryHappy),
      ],
    );
  }

  Widget _buildMoodButton(int mood, String emoji, String label, Color color) {
    final isSelected = selectedMood == mood;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = mood;
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.3) : AppColors.surface0,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? color : AppColors.overlay1,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart(List<MoodEntry> moods) {
    if (moods.isEmpty) return const SizedBox();

    final spots = moods
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.mood.toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.surface1,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= moods.length) return const Text('');
                final date = moods[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('E').format(date)[0],
                    style: AppTextStyles.caption,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const moodEmojis = ['', '😢', '😕', '😐', '🙂', '😄'];
                if (value < 1 || value > 5) return const Text('');
                return Text(
                  moodEmojis[value.toInt()],
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (moods.length - 1).toDouble(),
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.green,
                  strokeWidth: 2,
                  strokeColor: AppColors.base,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.green.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

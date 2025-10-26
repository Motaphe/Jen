import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'models/journal_entry.dart';
import 'models/mood_entry.dart';
import 'screens/home_screen.dart';
import 'screens/affirmations_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/breathing_screen.dart';
import 'screens/lockdown_screen.dart';
import 'widgets/bottom_nav.dart';

void main() {
  runApp(const JenApp());
}

class JenApp extends StatelessWidget {
  const JenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.base,
        colorScheme: ColorScheme.dark(
          primary: AppColors.lavender,
          surface: AppColors.surface0,
          error: AppColors.red,
        ),
        useMaterial3: true,
      ),
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String currentScreen = 'home';

  // Sample data for Milestone 1
  List<JournalEntry> journalEntries = [
    JournalEntry(
      id: 1,
      title: 'A peaceful morning',
      content: 'Today I woke up feeling grateful for another day. The sunrise was beautiful and I took time to meditate.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    JournalEntry(
      id: 2,
      title: 'Reflections on growth',
      content: 'Learning to be present in each moment has been transformative. I\'m noticing the small joys more.',
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  List<MoodEntry> moodHistory = [
    MoodEntry(mood: 4, date: DateTime.now().subtract(const Duration(days: 6))),
    MoodEntry(mood: 3, date: DateTime.now().subtract(const Duration(days: 5))),
    MoodEntry(mood: 5, date: DateTime.now().subtract(const Duration(days: 4))),
    MoodEntry(mood: 4, date: DateTime.now().subtract(const Duration(days: 3))),
    MoodEntry(mood: 4, date: DateTime.now().subtract(const Duration(days: 2))),
    MoodEntry(mood: 5, date: DateTime.now().subtract(const Duration(days: 1))),
    MoodEntry(mood: 4, date: DateTime.now()),
  ];

  void setJournalEntries(List<JournalEntry> entries) {
    setState(() {
      journalEntries = entries;
    });
  }

  void setMoodHistory(List<MoodEntry> history) {
    setState(() {
      moodHistory = history;
    });
  }

  Widget renderScreen() {
    switch (currentScreen) {
      case 'home':
        return HomeScreen(onNavigate: (screen) {
          setState(() {
            currentScreen = screen;
          });
        });
      case 'affirmations':
        return AffirmationsScreen(onBack: () {
          setState(() {
            currentScreen = 'home';
          });
        });
      case 'journal':
        return JournalScreen(
          entries: journalEntries,
          setEntries: setJournalEntries,
        );
      case 'mood':
        return MoodTrackerScreen(
          moodHistory: moodHistory,
          setMoodHistory: setMoodHistory,
        );
      case 'breathing':
        return BreathingScreen(onBack: () {
          setState(() {
            currentScreen = 'home';
          });
        });
      case 'lockdown':
        return LockdownScreen(onBack: () {
          setState(() {
            currentScreen = 'home';
          });
        });
      default:
        return HomeScreen(onNavigate: (screen) {
          setState(() {
            currentScreen = screen;
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: renderScreen(),
      bottomNavigationBar: ['home', 'journal', 'mood'].contains(currentScreen)
          ? BottomNav(
              currentScreen: currentScreen,
              onNavigate: (screen) {
                setState(() {
                  currentScreen = screen;
                });
              },
            )
          : null,
    );
  }
}

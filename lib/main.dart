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
import 'services/database_helper.dart';

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
  List<JournalEntry> journalEntries = [];
  List<MoodEntry> moodHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;

    // Load journal entries
    final entries = await db.getAllJournalEntries();

    // Load mood entries
    final moods = await db.getAllMoodEntries();

    setState(() {
      journalEntries = entries;
      moodHistory = moods;
      isLoading = false;
    });
  }

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

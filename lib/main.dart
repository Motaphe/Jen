import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'constants/colors.dart';
import 'models/journal_entry.dart';
import 'models/mood_entry.dart';
import 'screens/home_screen.dart';
import 'screens/affirmations_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/breathing_screen.dart';
import 'screens/lockdown_screen.dart';
import 'screens/water_reminder_screen.dart';
import 'screens/calendar_screen.dart';
import 'widgets/bottom_nav.dart';
import 'services/database_helper.dart';
import 'services/preferences_helper.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const JenApp(),
    ),
  );
}

class JenApp extends StatelessWidget {
  const JenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Jen',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainApp(),
        );
      },
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
  String? userName;

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

    // Check if first launch
    final isFirstLaunch = await PreferencesHelper.isFirstLaunch();

    // Get user name if exists
    final name = await PreferencesHelper.getUserName();

    setState(() {
      journalEntries = entries;
      moodHistory = moods;
      userName = name;
      isLoading = false;
    });

    // Show welcome dialog if first launch
    if (isFirstLaunch && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
    }
  }

  Future<void> _showWelcomeDialog() async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Welcome to Jen',
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
            const Text(
              'Your journey to mindfulness and peace begins here.',
              style: TextStyle(
                color: AppColors.subtext0,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What should we call you?',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
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
                if (value.trim().isNotEmpty) {
                  Navigator.pop(context, value.trim());
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, '');
            },
            child: const Text(
              'Skip',
              style: TextStyle(color: AppColors.overlay1),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              Navigator.pop(context, name.isEmpty ? '' : name);
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
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result.isNotEmpty) {
        await PreferencesHelper.setUserName(result);
        setState(() {
          userName = result;
        });
      }
      await PreferencesHelper.setFirstLaunchComplete();
    }
  }

  void updateUserName(String? newName) {
    setState(() {
      userName = newName;
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
        return HomeScreen(
          userName: userName,
          onNavigate: (screen) {
            setState(() {
              currentScreen = screen;
            });
          },
          onUpdateName: updateUserName,
        );
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
      case 'water':
        return WaterReminderScreen(onBack: () {
          setState(() {
            currentScreen = 'home';
          });
        });
      case 'calendar':
        return CalendarScreen(onBack: () {
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
        return HomeScreen(
          userName: userName,
          onNavigate: (screen) {
            setState(() {
              currentScreen = screen;
            });
          },
          onUpdateName: updateUserName,
        );
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

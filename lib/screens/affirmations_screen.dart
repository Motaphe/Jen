import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/database_helper.dart';
import 'favorites_screen.dart';

class AffirmationsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AffirmationsScreen({super.key, required this.onBack});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  int currentIndex = 0;
  bool _isSaving = false;

  final List<String> affirmations = [
    "I am capable of achieving great things.",
    "I choose peace and calm in every moment.",
    "My mind is clear and focused.",
    "I release stress and embrace serenity.",
    "I am worthy of love and happiness.",
    "Today I choose to be present.",
    "I trust in my journey.",
    "I am grateful for this moment.",
    "I have the power to create change.",
    "I am enough, just as I am.",
    "Every breath I take fills me with peace.",
    "I am growing and evolving each day.",
    "My potential is limitless.",
    "I choose to see the good in every situation.",
    "I am in control of my thoughts and emotions.",
    "I deserve rest and relaxation.",
    "My inner peace is my superpower.",
    "I am resilient and can handle challenges.",
    "I radiate positive energy.",
    "I am exactly where I need to be.",
    "My past does not define my future.",
    "I celebrate my progress, no matter how small.",
    "I am surrounded by abundance.",
    "I choose to focus on what I can control.",
    "My mind is a garden; I choose what to plant.",
    "I am patient with myself and my journey.",
    "I trust the timing of my life.",
    "I am worthy of my dreams and goals.",
    "I release what no longer serves me.",
    "I am creating the life I desire.",
    "My mistakes are opportunities to learn.",
    "I am confident in my abilities.",
    "I choose joy and gratitude today.",
    "I am at peace with who I am becoming.",
    "My presence makes a difference.",
    "I am open to new possibilities.",
    "I trust myself to make good decisions.",
    "I am deserving of compassion and kindness.",
    "I find balance in all areas of my life.",
    "I am the author of my own story.",
  ];

  void nextAffirmation() {
    setState(() {
      currentIndex = (currentIndex + 1) % affirmations.length;
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
          'Daily Affirmations',
          style: AppTextStyles.heading3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.red),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
            tooltip: 'View Favorites',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface0,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: AppColors.lavender,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      affirmations[currentIndex],
                      style: GoogleFonts.merriweather(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: AppColors.text,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '${currentIndex + 1} of ${affirmations.length}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: _isSaving ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Immediate haptic feedback
                        HapticFeedback.mediumImpact();

                        // Visual feedback
                        setState(() {
                          _isSaving = true;
                        });

                        final messenger = ScaffoldMessenger.of(context);
                        final db = DatabaseHelper.instance;
                        await db.saveFavoriteAffirmation(
                          affirmations[currentIndex],
                        );

                        // Reset animation state
                        setState(() {
                          _isSaving = false;
                        });

                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: const Text('Saved to favorites'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.green,
                            ),
                          );
                        }
                      },
                      icon: Icon(_isSaving ? Icons.favorite : Icons.favorite_border),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaving ? AppColors.green : AppColors.surface1,
                        foregroundColor: _isSaving ? AppColors.base : AppColors.text,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: nextAffirmation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lavender,
                      foregroundColor: AppColors.base,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/database_helper.dart';
import 'favorites_screen.dart';

/// Daily affirmations screen with random quote selection and favorites system.
/// Displays motivational quotes with haptic feedback and like/unlike functionality.
class AffirmationsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AffirmationsScreen({super.key, required this.onBack});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  static const List<String> _allAffirmations = [
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

  final Random _random = Random();
  late List<String> _affirmationDeck;
  int _currentIndex = 0;
  bool _isSaving = false;
  bool _isLiked = false;

  String get _currentAffirmation => _affirmationDeck[_currentIndex];

  @override
  void initState() {
    super.initState();
    _refreshDeck();
    _checkIfLiked();
  }

  void _refreshDeck({String? previous}) {
    _affirmationDeck = List<String>.from(_allAffirmations);
    _affirmationDeck.shuffle(_random);

    if (previous != null && _affirmationDeck.length > 1 && _affirmationDeck.first == previous) {
      final swapIndex = 1 + _random.nextInt(_affirmationDeck.length - 1);
      final temp = _affirmationDeck[0];
      _affirmationDeck[0] = _affirmationDeck[swapIndex];
      _affirmationDeck[swapIndex] = temp;
    }

    _currentIndex = 0;
  }

  Future<void> _checkIfLiked() async {
    final liked = await DatabaseHelper.instance.isAffirmationLiked(
      _currentAffirmation,
    );
    setState(() {
      _isLiked = liked;
    });
  }

  void nextAffirmation() async {
    final previousAffirmation = _currentAffirmation;
    setState(() {
      _currentIndex++;
      if (_currentIndex >= _affirmationDeck.length) {
        _refreshDeck(previous: previousAffirmation);
      }
      if (_affirmationDeck.length > 1 && _affirmationDeck[_currentIndex] == previousAffirmation) {
        _currentIndex = (_currentIndex + 1) % _affirmationDeck.length;
      }
    });
    await _checkIfLiked();
  }

  Future<void> _toggleLike() async {
    // Immediate haptic feedback
    HapticFeedback.mediumImpact();

    // Visual feedback
    setState(() {
      _isSaving = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final db = DatabaseHelper.instance;

    if (_isLiked) {
      // Unlike
      await db.unlikeAffirmation(_currentAffirmation);
      setState(() {
        _isLiked = false;
        _isSaving = false;
      });

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Removed from favorites'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.overlay1,
          ),
        );
      }
    } else {
      // Like
      await db.saveFavoriteAffirmation(_currentAffirmation);
      setState(() {
        _isLiked = true;
        _isSaving = false;
      });

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Added to favorites'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

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
          'Daily Affirmations',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? AppColors.text : AppColors.latteText,
          ),
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
                  color: isDark ? AppColors.surface0 : AppColors.latteSurface1,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.transparent : AppColors.latteSurface2,
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.22)
                          : AppColors.latteOverlay0.withValues(alpha: 0.2),
                      blurRadius: 28,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isLiked
                            ? Container(
                                key: const ValueKey('saved_badge'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surface1
                                      : AppColors.latteSurface1,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      color: AppColors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Saved',
                                      style: AppTextStyles.caption.copyWith(
                                        color: isDark
                                            ? AppColors.text
                                            : AppColors.latteText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(
                                key: ValueKey('saved_badge_hidden'),
                                height: 0,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: AppColors.lavender,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _currentAffirmation,
                      style: GoogleFonts.merriweather(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.text : AppColors.latteText,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '${_currentIndex + 1} of ${_affirmationDeck.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.subtext0 : AppColors.latteSubtext0,
                      ),
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
                      onPressed: _toggleLike,
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? AppColors.red : null,
                      ),
                      label: const Text('Like'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLiked
                            ? AppColors.red.withValues(alpha: isDark ? 0.25 : 0.2)
                            : (isDark
                                ? AppColors.surface1
                                : AppColors.latteSurface2),
                        foregroundColor:
                            isDark ? AppColors.text : AppColors.latteText,
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
                      backgroundColor:
                          isDark ? AppColors.lavender : AppColors.lavender.withValues(alpha: 0.92),
                      foregroundColor: isDark ? AppColors.base : AppColors.latteText,
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

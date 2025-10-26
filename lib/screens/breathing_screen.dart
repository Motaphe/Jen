import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class BreathingScreen extends StatefulWidget {
  final VoidCallback onBack;

  const BreathingScreen({super.key, required this.onBack});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _timer;
  bool _isRunning = false;
  int _secondsRemaining = 0;
  final int _totalSeconds = 240; // 4 minutes default
  String _breathPhase = 'Tap to start';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (!_isRunning) return; // Don't update if not running

      if (status == AnimationStatus.completed) {
        setState(() {
          _breathPhase = 'Exhale';
        });
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _breathPhase = 'Inhale';
        });
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleBreathing() {
    if (_isRunning) {
      _stopBreathing();
    } else {
      _startBreathing();
    }
  }

  void _startBreathing() {
    setState(() {
      _isRunning = true;
      _secondsRemaining = _totalSeconds;
      _breathPhase = 'Inhale';
    });

    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _stopBreathing();
        }
      });
    });
  }

  void _stopBreathing() {
    _timer?.cancel();
    _animationController.stop();
    _animationController.reset();
    setState(() {
      _isRunning = false;
      _breathPhase = 'Tap to start';
      _secondsRemaining = 0;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
          'Breathing Exercise',
          style: AppTextStyles.heading3,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRunning && _secondsRemaining > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.teal,
                  ),
                ),
              ),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.teal.withValues(alpha: 0.6),
                          AppColors.teal.withValues(alpha: 0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            Text(
              _breathPhase,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: _toggleBreathing,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning ? AppColors.red : AppColors.teal,
                foregroundColor: AppColors.base,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isRunning ? 'Stop' : 'Start',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!_isRunning) ...[
              const SizedBox(height: 32),
              Text(
                'Follow the circle',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'Inhale as it grows, exhale as it shrinks',
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

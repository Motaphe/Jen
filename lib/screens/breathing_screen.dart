import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/database_helper.dart';
import '../models/breathing_entry.dart';

/// Guided breathing exercise screen with audio cues and visual animations.
/// Runs 60-second sessions using 4-4-4 breathing pattern (inhale-hold-exhale).
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
  late final AudioPlayer _audioPlayer;
  Timer? _countdownTimer;
  bool _isRunning = false;
  bool _sessionCompletedNaturally = false;
  int _secondsRemaining = 0;
  final int _totalSeconds = 60; // 1 minute session
  String _breathPhase = 'Tap to start';
  DateTime? _startTime;
  Completer<void>? _cancelSignal; // For canceling async breathing flow

  // Breathing timing constants (4-4-4 pattern)
  static const Duration _introPause = Duration(seconds: 3);
  static const Duration _inhaleDuration = Duration(seconds: 4);
  static const Duration _holdDuration = Duration(seconds: 4);
  static const Duration _exhaleDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _inhaleDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    if (_cancelSignal != null && !_cancelSignal!.isCompleted) {
      _cancelSignal!.complete();
    }
    _countdownTimer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    if (_isRunning) {
      unawaited(_stopBreathing());
    } else {
      _startBreathing();
    }
  }

  void _startBreathing() {
    _sessionCompletedNaturally = false;

    if (_cancelSignal != null && !_cancelSignal!.isCompleted) {
      _cancelSignal!.complete();
    }
    _cancelSignal = Completer<void>();

    _countdownTimer?.cancel();
    _animationController.stop();
    _animationController.value = 0.0;

    setState(() {
      _isRunning = true;
      _secondsRemaining = _totalSeconds;
      _breathPhase = 'Close your eyes and relax';
      _startTime = DateTime.now();
    });

    unawaited(_runBreathingFlow());
  }

  Future<void> _stopBreathing() async {
    if (!_isRunning) return;

    setState(() {
      _isRunning = false;
      _breathPhase = 'Tap to start';
    });

    await _handleSessionEnd(completed: false);
  }

  /// Orchestrates full breathing session: intro + inhale/hold/exhale cycles.
  /// Loops until 60 seconds elapsed or user cancels via _cancelSignal.
  Future<void> _runBreathingFlow() async {
    await _playIntro();
    if (!_shouldContinue) {
      return;
    }

    while (_shouldContinue) {
      await _runTimedPhase(
        label: 'Inhale',
        audioAsset: 'audio/inhale.mp3',
        duration: _inhaleDuration,
        onStart: () {
          _animationController.duration = _inhaleDuration;
          _animationController.forward(from: 0.0);
        },
      );

      if (!_shouldContinue) break;

      await _runTimedPhase(
        label: 'Hold',
        audioAsset: 'audio/hold.mp3',
        duration: _holdDuration,
        onStart: () {
          _animationController.stop();
          _animationController.value = 1.0;
        },
      );

      if (!_shouldContinue) break;

      await _runTimedPhase(
        label: 'Exhale',
        audioAsset: 'audio/exhale.mp3',
        duration: _exhaleDuration,
        onStart: () {
          _animationController.duration = _exhaleDuration;
          _animationController.reverse(from: 1.0);
        },
      );
    }

    if (!_isRunning) {
      return;
    }

    if (_sessionCompletedNaturally) {
      if (mounted) {
        setState(() {
          _breathPhase = 'You may now open your eyes';
        });
      }
      await _playAudioCue('audio/outro.mp3', waitForCompletion: true);
      if (!_isRunning) return;
      await _handleSessionEnd(completed: true);
    }
  }

  Future<void> _playIntro() async {
    if (!_isRunning) return;

    await _playAudioCue('audio/intro.mp3', waitForCompletion: true);
    if (!_isRunning) return;

    await _waitFor(_introPause);
    if (!_isRunning) return;

    _startCountdownTimer();
  }

  Future<void> _runTimedPhase({
    required String label,
    required String audioAsset,
    required Duration duration,
    required VoidCallback onStart,
  }) async {
    if (!_isRunning) return;

    if (mounted) {
      setState(() {
        _breathPhase = label;
      });
    }

    await _playAudioCue(audioAsset);
    if (!_isRunning) return;

    onStart();
    await _waitFor(duration);
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isRunning) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        setState(() {
          _secondsRemaining = 0;
        });
        _sessionCompletedNaturally = true;
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _handleSessionEnd({required bool completed}) async {
    if (_cancelSignal != null && !_cancelSignal!.isCompleted) {
      _cancelSignal!.complete();
    }
    _cancelSignal = null;

    _countdownTimer?.cancel();
    _countdownTimer = null;

    try {
      await _audioPlayer.stop();
    } catch (_) {
      // Safely ignore audio stop issues.
    }

    _animationController.stop();
    await _animationController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    final startTime = _startTime;
    final elapsedSeconds = startTime != null
        ? DateTime.now().difference(startTime).inSeconds
        : 0;

    if (!mounted) {
      return;
    }

    setState(() {
      _isRunning = false;
      _breathPhase = completed ? 'Complete!' : 'Tap to start';
      _secondsRemaining = 0;
      _startTime = null;
      _sessionCompletedNaturally = false;
    });

    if (startTime != null) {
      await _logSession(
        startTime,
        completed ? _totalSeconds : elapsedSeconds,
        completed,
      );
    }

    if (completed && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _breathPhase = 'Tap to start';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Great breathing session!'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.teal,
          ),
        );
      });
    }
  }

  Future<void> _playAudioCue(
    String assetPath, {
    bool waitForCompletion = false,
  }) async {
    if (!_isRunning) return;

    StreamSubscription<void>? completionSub;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
      if (waitForCompletion) {
        final completer = Completer<void>();
        completionSub = _audioPlayer.onPlayerComplete.listen(
          (_) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onError: (_) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
        );

        final waiters = <Future<void>>[completer.future];
        final cancelFuture = _cancelSignal?.future;
        if (cancelFuture != null) {
          waiters.add(cancelFuture);
        }
        await Future.any(waiters);
      }
    } catch (_) {
      // Silently ignore playback issues to keep the session flowing.
    } finally {
      await completionSub?.cancel();
    }
  }

  Future<void> _waitFor(Duration duration) async {
    if (duration <= Duration.zero) return;

    final cancelFuture = _cancelSignal?.future;
    if (cancelFuture != null) {
      await Future.any([Future.delayed(duration), cancelFuture]);
    } else {
      await Future.delayed(duration);
    }
  }

  bool get _shouldContinue => _isRunning && _secondsRemaining > 0;

  Future<void> _logSession(
    DateTime startTime,
    int durationSeconds,
    bool completed,
  ) async {
    final entry = BreathingEntry(
      startTime: startTime,
      durationSeconds: durationSeconds,
      completed: completed,
    );

    await DatabaseHelper.instance.createBreathingEntry(entry);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
          'Breathing Exercise',
          style: AppTextStyles.heading3.copyWith(
            color: isDark ? AppColors.text : AppColors.latteText,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer at top (only when running)
            SizedBox(
              height: 60,
              child: _isRunning && _secondsRemaining > 0
                  ? Text(
                      _formatTime(_secondsRemaining),
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.teal,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // Animated circle
            SizedBox(
              height: 240,
              width: 240,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                child: Container(
                  width: 160,
                  height: 160,
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
                        color: AppColors.teal.withValues(alpha: 0.25),
                        blurRadius: 30,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                ),
                builder: (context, child) {
                  return Center(
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // Phase instruction
            SizedBox(
              height: 60,
              child: Text(
                _breathPhase,
                style: AppTextStyles.heading1.copyWith(color: AppColors.teal),
              ),
            ),

            const SizedBox(height: 48),

            // Control button
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

            // Instructions (only when not running)
            SizedBox(
              height: 100,
              child: !_isRunning
                  ? Column(
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          'Follow the prompts',
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: isDark
                                ? AppColors.subtext0
                                : AppColors.latteSubtext0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inhale as it grows, hold steady, exhale as it shrinks',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.subtext0
                                : AppColors.latteSubtext0,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

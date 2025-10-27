import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../services/database_helper.dart';
import '../models/lockdown_entry.dart';
import 'lockdown_history_screen.dart';

class LockdownScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LockdownScreen({super.key, required this.onBack});

  @override
  State<LockdownScreen> createState() => _LockdownScreenState();
}

class _LockdownScreenState extends State<LockdownScreen> {
  bool _isActive = false;
  int _selectedMinutes = 15;
  int _remainingSeconds = 0;
  Timer? _timer;
  String? _taskName;
  DateTime? _startTime;
  late final AudioPlayer _lofiPlayer;
  StreamSubscription<void>? _playerCompleteSubscription;
  bool _lofiEnabled = false;
  bool _isPlayingMusic = false;
  int _currentTrackIndex = 0;
  List<String> _shuffledTracks = [];
  String? _lastTrack;

  final List<int> _timeOptions = [5, 15, 30, 60];
  final List<String> _lofiTracks = List.generate(
    10,
    (index) => 'audio/lofi/${index + 1}.mp3',
  );

  @override
  void initState() {
    super.initState();
    _lofiPlayer = AudioPlayer();
    unawaited(_lofiPlayer.setReleaseMode(ReleaseMode.stop));
    _playerCompleteSubscription = _lofiPlayer.onPlayerComplete.listen((event) {
      if (!_isActive || !_lofiEnabled || !_isPlayingMusic) {
        return;
      }
      unawaited(_playNextTrack());
    });
  }

  void _toggleLockdown() {
    if (_isActive) {
      _showStopConfirmation();
    } else {
      _showTaskNameDialog();
    }
  }

  Future<void> _showTaskNameDialog() async {
    final taskController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('What are you focusing on?', style: AppTextStyles.heading3),
        content: TextField(
          controller: taskController,
          autofocus: true,
          style: const TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            hintText: 'e.g., Study, Work, Meditate (optional)',
            hintStyle: const TextStyle(color: AppColors.overlay0),
            filled: true,
            fillColor: AppColors.base,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text(
              'Skip',
              style: TextStyle(color: AppColors.overlay1),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final task = taskController.text.trim();
              Navigator.pop(context, task);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mauve,
              foregroundColor: AppColors.base,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (result != null) {
      _startLockdown(result.isEmpty ? null : result);
    }
  }

  void _startLockdown(String? taskName) {
    setState(() {
      _isActive = true;
      _remainingSeconds = _selectedMinutes * 60;
      _taskName = taskName;
      _startTime = DateTime.now();
    });

    if (_lofiEnabled) {
      _lastTrack = null;
      _initializePlaylist();
      unawaited(_playNextTrack());
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _completeLockdown();
        }
      });
    });
  }

  Future<void> _completeLockdown() async {
    _timer?.cancel();
    await _stopMusic();

    final entry = LockdownEntry(
      startTime: _startTime!,
      durationMinutes: _selectedMinutes,
      completed: true,
      taskName: _taskName,
    );

    await DatabaseHelper.instance.createLockdownEntry(entry);

    setState(() {
      _isActive = false;
      _remainingSeconds = 0;
      _taskName = null;
      _startTime = null;
    });

    if (mounted) {
      _showCompletionDialog();
    }
  }

  Future<void> _showStopConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface0,
        title: Text('End Early?', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to end this focus session early?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Continue',
              style: TextStyle(color: AppColors.green),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'End Session',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _cancelLockdown();
    }
  }

  Future<void> _cancelLockdown() async {
    _timer?.cancel();
    await _stopMusic();

    final entry = LockdownEntry(
      startTime: _startTime!,
      durationMinutes: _selectedMinutes,
      completed: false,
      taskName: _taskName,
    );

    await DatabaseHelper.instance.createLockdownEntry(entry);

    setState(() {
      _isActive = false;
      _remainingSeconds = 0;
      _taskName = null;
      _startTime = null;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface0,
        title: Text('Lockdown Complete!', style: AppTextStyles.heading3),
        content: Text(
          'Great job staying focused! 🎉',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done',
              style: AppTextStyles.body.copyWith(
                color: AppColors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLofiEnabled() async {
    final newValue = !_lofiEnabled;
    setState(() {
      _lofiEnabled = newValue;
    });

    if (!newValue) {
      await _stopMusic();
    } else {
      if (_isActive) {
        _initializePlaylist();
        unawaited(_playNextTrack());
      } else {
        _resetPlaylist();
      }
    }
  }

  Future<void> _toggleMute() async {
    if (!_lofiEnabled) return;

    if (_isPlayingMusic) {
      try {
        await _lofiPlayer.pause();
      } catch (_) {
        // Ignore pause issues.
      }
      if (mounted) {
        setState(() {
          _isPlayingMusic = false;
        });
      }
    } else {
      try {
        await _lofiPlayer.resume();
        if (mounted) {
          setState(() {
            _isPlayingMusic = true;
          });
        }
      } catch (_) {
        if (_isActive) {
          await _playNextTrack();
        }
      }
    }
  }

  void _initializePlaylist() {
    _shuffledTracks = List<String>.from(_lofiTracks)..shuffle();
    if (_lastTrack != null &&
        _shuffledTracks.length > 1 &&
        _shuffledTracks.first == _lastTrack) {
      _shuffledTracks.shuffle();
      if (_shuffledTracks.first == _lastTrack) {
        final first = _shuffledTracks.removeAt(0);
        _shuffledTracks.insert(1, first);
      }
    }
    _currentTrackIndex = 0;
  }

  void _resetPlaylist() {
    _shuffledTracks = [];
    _currentTrackIndex = 0;
  }

  Future<void> _playNextTrack() async {
    if (!_lofiEnabled || !_isActive) return;

    if (_shuffledTracks.isEmpty ||
        _currentTrackIndex >= _shuffledTracks.length) {
      _initializePlaylist();
    }

    if (_shuffledTracks.isEmpty) return;

    final track = _shuffledTracks[_currentTrackIndex];
    _currentTrackIndex++;

    if (mounted && !_isPlayingMusic) {
      setState(() {
        _isPlayingMusic = true;
      });
    }

    try {
      await _lofiPlayer.stop();
      await _lofiPlayer.play(AssetSource(track));
      _lastTrack = track;
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPlayingMusic = false;
        });
      }
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _lofiPlayer.stop();
    } catch (_) {
      // Ignore stop issues.
    }
    _resetPlaylist();
    _lastTrack = null;
    if (mounted) {
      setState(() {
        _isPlayingMusic = false;
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    unawaited(_lofiPlayer.dispose());
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _handleWillPop() async {
    if (_isActive) {
      // Show warning that this will count as a failed session
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface0,
          title: Text('Exit Lockdown?', style: AppTextStyles.heading3),
          content: Text(
            'Exiting now will count as a failed session. Are you sure you want to give up?',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Stay Focused',
                style: TextStyle(color: AppColors.green),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Give Up',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        ),
      );

      if (result == true) {
        await _cancelLockdown();
        return true;
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_isActive) {
          final shouldLeave = await _handleWillPop();
          if (shouldLeave && mounted) {
            widget.onBack();
          }
        } else {
          widget.onBack();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.base : AppColors.latteBase,
        appBar: _isActive
            ? null
            : AppBar(
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
                  'Lockdown Mode',
                  style: AppTextStyles.heading3.copyWith(
                    color: isDark ? AppColors.text : AppColors.latteText,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.history,
                      color: isDark ? AppColors.text : AppColors.latteText,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LockdownHistoryScreen(
                            onBack: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                    tooltip: 'View History',
                  ),
                ],
              ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: _isActive
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isActive) ...[
                      const SizedBox(height: 16),
                      if (_lofiEnabled)
                        Align(
                          alignment: Alignment.topRight,
                          child: _buildActiveLofiControl(isDark),
                        ),
                      if (_lofiEnabled) const SizedBox(height: 24),
                    ],
                    Icon(
                      _isActive ? Icons.lock : Icons.lock_clock,
                      size: 80,
                      color: _isActive
                          ? AppColors.mauve
                          : (isDark
                                ? AppColors.overlay0
                                : AppColors.latteOverlay0),
                    ),
                    const SizedBox(height: 32),
                    if (_isActive) ...[
                      Text(
                        'Focus Mode Active',
                        style: AppTextStyles.heading2.copyWith(
                          color: isDark ? AppColors.text : AppColors.latteText,
                        ),
                      ),
                      if (_taskName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _taskName!,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.mauve,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 64,
                          color: AppColors.mauve,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Stay focused on your task',
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: isDark
                              ? AppColors.subtext0
                              : AppColors.latteSubtext0,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Select Duration',
                        style: AppTextStyles.heading2.copyWith(
                          color: isDark ? AppColors.text : AppColors.latteText,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: _timeOptions.map((minutes) {
                          return _buildTimeOption(minutes);
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      _buildLofiToggle(isDark),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surface0
                              : AppColors.latteSurface0,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.mauve,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'What is Lockdown Mode?',
                                    style: AppTextStyles.heading3.copyWith(
                                      fontSize: 16,
                                      color: isDark
                                          ? AppColors.text
                                          : AppColors.latteText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Lockdown mode helps you stay focused by encouraging you to minimize distractions. Use this time to be present and mindful.',
                              style: AppTextStyles.bodySecondary.copyWith(
                                color: isDark
                                    ? AppColors.subtext0
                                    : AppColors.latteSubtext0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isActive ? null : _toggleLockdown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isActive
                        ? (isDark
                              ? AppColors.surface1
                              : AppColors.latteSurface1)
                        : AppColors.mauve,
                    foregroundColor: _isActive
                        ? (isDark
                              ? AppColors.subtext0
                              : AppColors.latteSubtext0)
                        : AppColors.base,
                    disabledBackgroundColor: isDark
                        ? AppColors.surface1
                        : AppColors.latteSurface1,
                    disabledForegroundColor: isDark
                        ? AppColors.subtext0
                        : AppColors.latteSubtext0,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isActive ? 'Lockdown Active' : 'Start Lockdown',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_isActive) ...[
                const SizedBox(height: 12),
                Text(
                  'Complete the timer to unlock. Leaving the app counts as a failed session.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.subtext0
                        : AppColors.latteSubtext0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOption(int minutes) {
    final isSelected = _selectedMinutes == minutes;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMinutes = minutes;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.mauve.withValues(alpha: 0.3)
              : (isDark ? AppColors.surface0 : AppColors.latteSurface0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.mauve : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$minutes',
              style: AppTextStyles.heading2.copyWith(
                color: isSelected
                    ? AppColors.mauve
                    : (isDark ? AppColors.text : AppColors.latteText),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'minutes',
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? AppColors.mauve
                    : (isDark ? AppColors.overlay1 : AppColors.latteOverlay1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLofiToggle(bool isDark) {
    final isEnabled = _lofiEnabled;
    final iconColor = isEnabled
        ? AppColors.mauve
        : (isDark ? AppColors.overlay0 : AppColors.latteOverlay0);
    final backgroundColor = isEnabled
        ? AppColors.mauve.withValues(alpha: 0.18)
        : (isDark ? AppColors.surface0 : AppColors.latteSurface0);

    return GestureDetector(
      onTap: () => _toggleLofiEnabled(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? AppColors.mauve : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isEnabled ? Icons.volume_up : Icons.volume_off,
              color: iconColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lofi',
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 16,
                      color: isDark ? AppColors.text : AppColors.latteText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gentle beats to keep you in flow',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.subtext0
                          : AppColors.latteSubtext0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isEnabled ? AppColors.mauve : iconColor,
                  width: 2,
                ),
                color: isEnabled ? AppColors.mauve : Colors.transparent,
              ),
              child: isEnabled
                  ? const Icon(Icons.check, size: 16, color: AppColors.base)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveLofiControl(bool isDark) {
    final isPlaying = _isPlayingMusic;
    final color = isPlaying
        ? AppColors.mauve
        : (isDark ? AppColors.overlay0 : AppColors.latteOverlay0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isPlaying
                ? AppColors.mauve.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.volume_up : Icons.volume_off,
              color: color,
            ),
            tooltip: isPlaying ? 'Mute lofi' : 'Play lofi',
            onPressed: _toggleMute,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Lofi',
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

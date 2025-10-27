class BreathingEntry {
  final int? id;
  final DateTime startTime;
  final int durationSeconds;
  final bool completed;

  BreathingEntry({
    this.id,
    required this.startTime,
    required this.durationSeconds,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'duration_seconds': durationSeconds,
      'completed': completed ? 1 : 0,
    };
  }

  factory BreathingEntry.fromMap(Map<String, dynamic> map) {
    return BreathingEntry(
      id: map['id'] as int?,
      startTime: DateTime.parse(map['start_time'] as String),
      durationSeconds: map['duration_seconds'] as int,
      completed: (map['completed'] as int) == 1,
    );
  }
}

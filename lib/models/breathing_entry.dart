/// Represents a breathing exercise session record.
/// Tracks 60-second guided breathing cycles (inhale/hold/exhale).
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

  /// Converts entry to map for SQLite storage.
  /// Boolean stored as integer (0/1) due to SQLite limitations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'duration_seconds': durationSeconds,
      'completed': completed ? 1 : 0,
    };
  }

  /// Creates entry from SQLite query result.
  factory BreathingEntry.fromMap(Map<String, dynamic> map) {
    return BreathingEntry(
      id: map['id'] as int?,
      startTime: DateTime.parse(map['start_time'] as String),
      durationSeconds: map['duration_seconds'] as int,
      completed: (map['completed'] as int) == 1,
    );
  }
}

/// Represents a focused work session with optional lofi background music.
/// Timer-based feature for deep work with optional task labeling.
class LockdownEntry {
  final int? id;
  final DateTime startTime;
  final int durationMinutes;
  final bool completed;
  final String? taskName;

  LockdownEntry({
    this.id,
    required this.startTime,
    required this.durationMinutes,
    required this.completed,
    this.taskName,
  });

  /// Converts entry to map for SQLite storage.
  /// Boolean stored as integer (0/1) due to SQLite limitations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'completed': completed ? 1 : 0,
      'task_name': taskName,
    };
  }

  /// Creates entry from SQLite query result.
  factory LockdownEntry.fromMap(Map<String, dynamic> map) {
    return LockdownEntry(
      id: map['id'] as int?,
      startTime: DateTime.parse(map['start_time'] as String),
      durationMinutes: map['duration_minutes'] as int,
      completed: (map['completed'] as int) == 1,
      taskName: map['task_name'] as String?,
    );
  }
}

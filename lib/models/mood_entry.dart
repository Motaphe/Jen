/// Represents a mood tracking entry with optional contextual note.
/// Mood is rated on a 1-5 scale and visualized in chart format.
class MoodEntry {
  final int? id;
  final int mood; // 1-5 scale: 1=very bad, 5=excellent
  final DateTime date;
  final String? note;

  MoodEntry({
    this.id,
    required this.mood,
    required this.date,
    this.note,
  });

  /// Converts entry to map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  /// Creates entry from SQLite query result.
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      mood: map['mood'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}

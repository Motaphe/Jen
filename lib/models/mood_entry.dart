class MoodEntry {
  final int? id;
  final int mood; // 1-5 scale
  final DateTime date;
  final String? note;

  MoodEntry({
    this.id,
    required this.mood,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      mood: map['mood'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}

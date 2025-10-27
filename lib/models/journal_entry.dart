/// Represents a journal entry for user reflections and thoughts.
/// Stored in SQLite and displayed in the journal screen with date filtering.
class JournalEntry {
  final int? id;
  final String title;
  final String content;
  final DateTime date;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  /// Converts entry to map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }

  /// Creates entry from SQLite query result.
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
    );
  }
}

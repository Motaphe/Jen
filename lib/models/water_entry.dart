/// Represents a single water intake confirmation (1 glass = 8oz).
/// Daily goal is 8 glasses, tracked via simple timestamp logging.
class WaterEntry {
  final int? id;
  final DateTime timestamp;
  final bool confirmed;

  WaterEntry({
    this.id,
    required this.timestamp,
    required this.confirmed,
  });

  /// Converts entry to map for SQLite storage.
  /// Boolean stored as integer (0/1) due to SQLite limitations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'confirmed': confirmed ? 1 : 0,
    };
  }

  /// Creates entry from SQLite query result.
  factory WaterEntry.fromMap(Map<String, dynamic> map) {
    return WaterEntry(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      confirmed: (map['confirmed'] as int) == 1,
    );
  }
}

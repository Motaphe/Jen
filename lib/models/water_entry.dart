class WaterEntry {
  final int? id;
  final DateTime timestamp;
  final bool confirmed;

  WaterEntry({
    this.id,
    required this.timestamp,
    required this.confirmed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'confirmed': confirmed ? 1 : 0,
    };
  }

  factory WaterEntry.fromMap(Map<String, dynamic> map) {
    return WaterEntry(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      confirmed: (map['confirmed'] as int) == 1,
    );
  }
}

class ZikrEvent {
  final String id;
  final String text;
  final String source;
  final DateTime timestamp;
  final int count;

  ZikrEvent({
    required this.id,
    required this.text,
    required this.source,
    required this.timestamp,
    this.count = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'source': source,
    'timestamp': timestamp.toIso8601String(),
    'count': count,
  };

  factory ZikrEvent.fromJson(Map<String, dynamic> json) {
    return ZikrEvent(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      source: json['source'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      count: json['count'] ?? 1,
    );
  }

  factory ZikrEvent.create({
    required String text,
    required String source,
    int count = 1,
  }) {
    final now = DateTime.now();
    return ZikrEvent(
      id: now.microsecondsSinceEpoch.toString(),
      text: text,
      source: source,
      timestamp: now,
      count: count,
    );
  }
}
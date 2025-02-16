class TasbihRecord {
  final DateTime date;
  final int count;
  final String type;

  TasbihRecord({
    required this.date,
    required this.count,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'count': count,
      'type': type,
    };
  }

  factory TasbihRecord.fromJson(Map<String, dynamic> json) {
    return TasbihRecord(
      date: DateTime.parse(json['date']),
      count: json['count'],
      type: json['type'],
    );
  }
}

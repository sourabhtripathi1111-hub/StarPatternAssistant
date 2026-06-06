import 'dart:convert';

class SavedPattern {
  final String id;
  final String name;
  final String note;
  final int detectedCount;
  final String confidence;
  final int? lastSeenRound;
  final DateTime createdAt;

  SavedPattern({
    required this.id,
    required this.name,
    required this.note,
    this.detectedCount = 1,
    this.confidence = 'Low',
    this.lastSeenRound,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'note': note,
        'detectedCount': detectedCount,
        'confidence': confidence,
        'lastSeenRound': lastSeenRound,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedPattern.fromMap(Map<String, dynamic> map) => SavedPattern(
        id: map['id'] as String,
        name: map['name'] as String,
        note: map['note'] as String? ?? '',
        detectedCount: map['detectedCount'] as int? ?? 1,
        confidence: map['confidence'] as String? ?? 'Low',
        lastSeenRound: map['lastSeenRound'] as int?,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  String toJson() => jsonEncode(toMap());
  factory SavedPattern.fromJson(String source) => SavedPattern.fromMap(jsonDecode(source));
}

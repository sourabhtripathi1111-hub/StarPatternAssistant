import 'dart:convert';

enum ResultType {
  purpleX5,
  orangeX5,
  lightGreenX5,
  tealGreenX5,
  pinkX10,
  yellowX15,
  purpleX25,
  pinkPurpleX50,
  unknown,
}

enum FamilyType {
  greenSmall,
  yellowBig,
  purplePink,
  pinkBig,
  unknown,
}

extension ResultTypeLabel on ResultType {
  String get label {
    switch (this) {
      case ResultType.purpleX5:
        return 'Purple x5';
      case ResultType.orangeX5:
        return 'Orange x5';
      case ResultType.lightGreenX5:
        return 'Light Green x5';
      case ResultType.tealGreenX5:
        return 'Teal/Green x5';
      case ResultType.pinkX10:
        return 'Pink x10';
      case ResultType.yellowX15:
        return 'Yellow x15';
      case ResultType.purpleX25:
        return 'Purple x25';
      case ResultType.pinkPurpleX50:
        return 'Pink/Purple x50';
      case ResultType.unknown:
        return 'Unknown';
    }
  }

  int get multiplier {
    switch (this) {
      case ResultType.purpleX5:
      case ResultType.orangeX5:
      case ResultType.lightGreenX5:
      case ResultType.tealGreenX5:
        return 5;
      case ResultType.pinkX10:
        return 10;
      case ResultType.yellowX15:
        return 15;
      case ResultType.purpleX25:
        return 25;
      case ResultType.pinkPurpleX50:
        return 50;
      case ResultType.unknown:
        return 0;
    }
  }

  FamilyType get family {
    switch (this) {
      case ResultType.lightGreenX5:
      case ResultType.tealGreenX5:
        return FamilyType.greenSmall;
      case ResultType.orangeX5:
      case ResultType.yellowX15:
      case ResultType.purpleX25:
        return FamilyType.yellowBig;
      case ResultType.purpleX5:
      case ResultType.pinkX10:
        return FamilyType.purplePink;
      case ResultType.pinkPurpleX50:
        return FamilyType.pinkBig;
      case ResultType.unknown:
        return FamilyType.unknown;
    }
  }

  static ResultType fromLabel(String value) {
    return ResultType.values.firstWhere(
      (e) => e.label == value || e.name == value,
      orElse: () => ResultType.unknown,
    );
  }
}

extension FamilyTypeLabel on FamilyType {
  String get label {
    switch (this) {
      case FamilyType.greenSmall:
        return 'Green/Small';
      case FamilyType.yellowBig:
        return 'Yellow/Big';
      case FamilyType.purplePink:
        return 'Purple/Pink';
      case FamilyType.pinkBig:
        return 'Pink/Big';
      case FamilyType.unknown:
        return 'Unknown';
    }
  }
}

class RoundRecord {
  final int roundNo;
  final ResultType result;
  final DateTime capturedAt;
  final String patternFound;
  final String riskLevel;
  final String watchSignal;
  final String note;
  final String missCountJson;

  RoundRecord({
    required this.roundNo,
    required this.result,
    required this.capturedAt,
    this.patternFound = '',
    this.riskLevel = 'Low',
    this.watchSignal = 'Wait',
    this.note = '',
    this.missCountJson = '{}',
  });

  FamilyType get family => result.family;

  RoundRecord copyWith({
    int? roundNo,
    ResultType? result,
    DateTime? capturedAt,
    String? patternFound,
    String? riskLevel,
    String? watchSignal,
    String? note,
    String? missCountJson,
  }) {
    return RoundRecord(
      roundNo: roundNo ?? this.roundNo,
      result: result ?? this.result,
      capturedAt: capturedAt ?? this.capturedAt,
      patternFound: patternFound ?? this.patternFound,
      riskLevel: riskLevel ?? this.riskLevel,
      watchSignal: watchSignal ?? this.watchSignal,
      note: note ?? this.note,
      missCountJson: missCountJson ?? this.missCountJson,
    );
  }

  Map<String, dynamic> toMap() => {
        'roundNo': roundNo,
        'result': result.name,
        'capturedAt': capturedAt.toIso8601String(),
        'patternFound': patternFound,
        'riskLevel': riskLevel,
        'watchSignal': watchSignal,
        'note': note,
        'missCountJson': missCountJson,
      };

  factory RoundRecord.fromMap(Map<String, dynamic> map) {
    return RoundRecord(
      roundNo: map['roundNo'] as int,
      result: ResultType.values.firstWhere((e) => e.name == (map['result'] as String? ?? ''), orElse: () => ResultType.unknown),
      capturedAt: DateTime.tryParse(map['capturedAt'] as String? ?? '') ?? DateTime.now(),
      patternFound: map['patternFound'] as String? ?? '',
      riskLevel: map['riskLevel'] as String? ?? 'Low',
      watchSignal: map['watchSignal'] as String? ?? 'Wait',
      note: map['note'] as String? ?? '',
      missCountJson: map['missCountJson'] as String? ?? '{}',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory RoundRecord.fromJson(String source) => RoundRecord.fromMap(jsonDecode(source));
}

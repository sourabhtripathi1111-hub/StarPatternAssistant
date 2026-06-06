class PatternSignal {
  final String patternName;
  final String watchSignal;
  final String riskLevel;
  final String reason;
  final double confidence;
  final bool aiRecheckNeeded;

  const PatternSignal({
    required this.patternName,
    required this.watchSignal,
    required this.riskLevel,
    required this.reason,
    this.confidence = 0.5,
    this.aiRecheckNeeded = false,
  });

  PatternSignal copyWith({
    String? patternName,
    String? watchSignal,
    String? riskLevel,
    String? reason,
    double? confidence,
    bool? aiRecheckNeeded,
  }) {
    return PatternSignal(
      patternName: patternName ?? this.patternName,
      watchSignal: watchSignal ?? this.watchSignal,
      riskLevel: riskLevel ?? this.riskLevel,
      reason: reason ?? this.reason,
      confidence: confidence ?? this.confidence,
      aiRecheckNeeded: aiRecheckNeeded ?? this.aiRecheckNeeded,
    );
  }
}

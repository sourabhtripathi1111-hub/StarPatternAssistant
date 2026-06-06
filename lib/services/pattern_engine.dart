import '../models/pattern_signal.dart';
import '../models/round_record.dart';

class PatternEngine {
  PatternSignal analyze(List<RoundRecord> allRecords, {int wrongPredictionStreak = 0}) {
    final records = [...allRecords]..sort((a, b) => a.roundNo.compareTo(b.roundNo));
    if (records.isEmpty) {
      return const PatternSignal(
        patternName: 'No Data',
        watchSignal: 'Wait',
        riskLevel: 'Low',
        reason: 'Abhi data nahi hai.',
        confidence: 0.1,
      );
    }

    final recent = records.length > 20 ? records.sublist(records.length - 20) : records;
    final last = recent.last;

    if (wrongPredictionStreak >= 2) {
      return const PatternSignal(
        patternName: 'Local Pattern Failed',
        watchSignal: 'Wait',
        riskLevel: 'High',
        reason: '2 prediction galat hui. External AI recheck needed.',
        confidence: 0.15,
        aiRecheckNeeded: true,
      );
    }
    if (wrongPredictionStreak == 1) {
      return const PatternSignal(
        patternName: 'Pattern Weak',
        watchSignal: 'Wait',
        riskLevel: 'Medium',
        reason: '1 prediction galat hui. Caution mode.',
        confidence: 0.35,
      );
    }

    final sameRun = _countSameResultRun(recent);
    final familyRun = _countSameFamilyRun(recent);

    if (last.result == ResultType.pinkPurpleX50) {
      return const PatternSignal(
        patternName: 'x50 Rare Trigger',
        watchSignal: 'Green Watch',
        riskLevel: 'Medium',
        reason: 'x50 rare hai. Data ke hisab se iske baad often small/green return watch.',
        confidence: 0.62,
      );
    }

    if (last.result == ResultType.purpleX25) {
      return const PatternSignal(
        patternName: 'x25 Return-to-Small',
        watchSignal: 'Small/Green Watch',
        riskLevel: 'Medium',
        reason: 'x25 ke baad aksar small x5 side return dekha gaya.',
        confidence: 0.61,
      );
    }

    if (sameRun >= 4) {
      return PatternSignal(
        patternName: 'Same Result 4-Run',
        watchSignal: _oppositeWatch(last.family),
        riskLevel: 'High',
        reason: '${last.result.label} $sameRun baar repeat. Break risk high.',
        confidence: 0.70,
      );
    }

    if (sameRun == 3) {
      return PatternSignal(
        patternName: 'Same Result 3-Run',
        watchSignal: _oppositeWatch(last.family),
        riskLevel: 'Medium',
        reason: '${last.result.label} 3 baar repeat. Break watch.',
        confidence: 0.63,
      );
    }

    if (familyRun >= 5) {
      return PatternSignal(
        patternName: 'Family Cluster Break',
        watchSignal: _oppositeWatch(last.family),
        riskLevel: 'High',
        reason: '${last.family.label} family $familyRun baar cluster. Family break risk.',
        confidence: 0.68,
      );
    }

    final p321 = _detect321(recent);
    if (p321 != null) return p321;

    final p2221 = _detect2221(recent);
    if (p2221 != null) return p2221;

    final p121 = _detect121(recent);
    if (p121 != null) return p121;

    final mirror = _detectAabBba(recent);
    if (mirror != null) return mirror;

    final boundary = _detectBigBoundary(recent);
    if (boundary != null) return boundary;

    final substitute = _detectSubstitute(recent);
    if (substitute != null) return substitute;

    return PatternSignal(
      patternName: 'Family Balance Watch',
      watchSignal: _defaultWatchAfter(last.family),
      riskLevel: 'Low',
      reason: 'Latest family ${last.family.label}. Balance ke hisab se next watch set.',
      confidence: 0.52,
    );
  }

  int _countSameResultRun(List<RoundRecord> records) {
    if (records.isEmpty) return 0;
    final last = records.last.result;
    int count = 0;
    for (final r in records.reversed) {
      if (r.result == last) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  int _countSameFamilyRun(List<RoundRecord> records) {
    if (records.isEmpty) return 0;
    final last = records.last.family;
    int count = 0;
    for (final r in records.reversed) {
      if (r.family == last) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  PatternSignal? _detect321(List<RoundRecord> records) {
    if (records.length < 6) return null;
    final r = records.sublist(records.length - 6).map((e) => e.family).toList();
    if (r[0] == r[1] && r[1] == r[2] && r[3] == r[4] && r[2] != r[3] && r[4] != r[5]) {
      return const PatternSignal(
        patternName: '3-2-1 Pattern',
        watchSignal: 'Break/Next Chain Watch',
        riskLevel: 'Medium',
        reason: '3 same family, phir 2 same family, phir 1 different family pattern mila.',
        confidence: 0.67,
      );
    }
    return null;
  }

  PatternSignal? _detect2221(List<RoundRecord> records) {
    if (records.length < 7) return null;
    final r = records.sublist(records.length - 7).map((e) => e.family).toList();
    if (r[0] == r[1] && r[2] == r[3] && r[4] == r[5] && r[5] != r[6]) {
      return const PatternSignal(
        patternName: '2-2-2-1 Pattern',
        watchSignal: 'Pattern Break Watch',
        riskLevel: 'Medium',
        reason: '2-2-2 ke baad 1 alag family mila. New chain start ho sakti hai.',
        confidence: 0.64,
      );
    }
    return null;
  }

  PatternSignal? _detect121(List<RoundRecord> records) {
    if (records.length < 4) return null;
    final r = records.sublist(records.length - 4).map((e) => e.family).toList();
    if (r[0] == r[3] && r[1] == r[2] && r[0] != r[1]) {
      return const PatternSignal(
        patternName: '1-2-1 Balance',
        watchSignal: 'Mirror Continue Watch',
        riskLevel: 'Low',
        reason: 'A-B-B-A type balance/mirror pattern mila.',
        confidence: 0.60,
      );
    }
    return null;
  }

  PatternSignal? _detectAabBba(List<RoundRecord> records) {
    if (records.length < 6) return null;
    final r = records.sublist(records.length - 6).map((e) => e.family).toList();
    if (r[0] == r[1] && r[2] == r[3] && r[3] == r[4] && r[5] == r[0] && r[0] != r[2]) {
      return const PatternSignal(
        patternName: 'AAB-BBA Mirror',
        watchSignal: 'Pattern Complete / Risk Watch',
        riskLevel: 'Medium',
        reason: 'AAB → BBA hidden mirror jaisa structure mila.',
        confidence: 0.66,
      );
    }
    return null;
  }

  PatternSignal? _detectBigBoundary(List<RoundRecord> records) {
    if (records.length < 5) return null;
    final r = records.sublist(records.length - 5);
    final firstBig = _isBig(r.first.family);
    final lastBig = _isBig(r.last.family);
    final middleSame = r[1].family == r[2].family && r[2].family == r[3].family;
    if (firstBig && lastBig && middleSame) {
      return const PatternSignal(
        patternName: 'Big Boundary + Middle 3 Block',
        watchSignal: 'Break Watch',
        riskLevel: 'Medium',
        reason: 'Dono side big family aur beech me 3 same family block.',
        confidence: 0.63,
      );
    }
    return null;
  }

  PatternSignal? _detectSubstitute(List<RoundRecord> records) {
    if (records.length < 3) return null;
    final last3 = records.sublist(records.length - 3);
    final hasYellowSub = last3.any((e) => e.result == ResultType.orangeX5) &&
        last3.any((e) => e.result == ResultType.yellowX15 || e.result == ResultType.purpleX25);
    final hasPurpleSub = last3.any((e) => e.result == ResultType.purpleX5) &&
        last3.any((e) => e.result == ResultType.pinkX10 || e.result == ResultType.pinkPurpleX50);
    if (hasYellowSub || hasPurpleSub) {
      return PatternSignal(
        patternName: 'Substitute Active',
        watchSignal: hasYellowSub ? 'Yellow/Big Watch' : 'Purple/Pink Watch',
        riskLevel: 'Medium',
        reason: hasYellowSub
            ? 'Yellow x5 ki jagah x15/x25 substitute active.'
            : 'Purple ki jagah x10/x50 substitute active.',
        confidence: 0.58,
      );
    }
    return null;
  }

  bool _isBig(FamilyType family) => family == FamilyType.yellowBig || family == FamilyType.pinkBig || family == FamilyType.purplePink;

  String _oppositeWatch(FamilyType family) {
    switch (family) {
      case FamilyType.greenSmall:
        return 'Yellow/Big or Purple Watch';
      case FamilyType.yellowBig:
        return 'Green/Small Watch';
      case FamilyType.purplePink:
        return 'Green/Yellow Watch';
      case FamilyType.pinkBig:
        return 'Green/Small Watch';
      case FamilyType.unknown:
        return 'Wait';
    }
  }

  String _defaultWatchAfter(FamilyType family) {
    switch (family) {
      case FamilyType.greenSmall:
        return 'Green Continue / Yellow Watch';
      case FamilyType.yellowBig:
        return 'Green/Small Watch';
      case FamilyType.purplePink:
        return 'Yellow/Big Watch';
      case FamilyType.pinkBig:
        return 'Green/Small Watch';
      case FamilyType.unknown:
        return 'Wait';
    }
  }
}

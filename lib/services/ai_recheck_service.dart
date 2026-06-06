import '../models/round_record.dart';

class AiRecheckService {
  /// Version 1 stub: no internet/API call yet.
  /// Later this can connect to external AI only with user permission.
  Future<String> buildAiPrompt(List<RoundRecord> records, String failureReason) async {
    final recent = records.length > 100 ? records.sublist(records.length - 100) : records;
    final lines = recent.map((r) => '${r.roundNo}: ${r.result.label}, ${r.family.label}').join('\n');
    return '''
StarMaker pattern recheck needed.
Reason: $failureReason

Recent rounds:
$lines

Tasks:
1. Identify current family pattern.
2. Detect break/substitute/mirror risk.
3. Give watch signal only, no auto betting.
''';
  }
}

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/round_record.dart';

class ExportService {
  String _escape(String value) {
    final v = value.replaceAll('"', '""');
    return '"$v"';
  }

  Future<File> exportCsv(List<RoundRecord> records) async {
    final sorted = [...records]..sort((a, b) => a.roundNo.compareTo(b.roundNo));
    final buffer = StringBuffer();
    buffer.writeln('Round No,Result,Multiplier,Family,Pattern Found,Risk Level,Watch Signal,Miss Count,Time,Note');
    for (final r in sorted) {
      buffer.writeln([
        r.roundNo.toString(),
        _escape(r.result.label),
        r.result.multiplier.toString(),
        _escape(r.family.label),
        _escape(r.patternFound),
        _escape(r.riskLevel),
        _escape(r.watchSignal),
        _escape(r.missCountJson),
        _escape(DateFormat('yyyy-MM-dd HH:mm:ss').format(r.capturedAt)),
        _escape(r.note),
      ].join(','));
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/StarMaker_Master_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');
    await file.writeAsString(buffer.toString());
    return file;
  }

  Future<void> shareCsv(List<RoundRecord> records) async {
    final file = await exportCsv(records);
    await Share.shareXFiles([XFile(file.path)], text: 'StarMaker pattern data CSV');
  }
}

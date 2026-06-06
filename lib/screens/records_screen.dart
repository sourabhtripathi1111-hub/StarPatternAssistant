import 'package:flutter/material.dart';
import '../models/round_record.dart';
import '../services/storage_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _storage = StorageService();
  List<RoundRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await _storage.loadRecords();
    setState(() => _records = records.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Round Data')),
      body: ListView.separated(
        itemCount: _records.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final r = _records[index];
          return ListTile(
            title: Text('${r.roundNo} — ${r.result.label}'),
            subtitle: Text('${r.family.label} | ${r.patternFound}\nRisk: ${r.riskLevel} | Watch: ${r.watchSignal}'),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/pattern_signal.dart';
import '../models/round_record.dart';
import '../models/saved_pattern.dart';
import '../services/ai_recheck_service.dart';
import '../services/export_service.dart';
import '../services/pattern_engine.dart';
import '../services/storage_service.dart';
import '../widgets/signal_card.dart';
import 'pattern_library_screen.dart';
import 'records_screen.dart';
import 'live_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  final _engine = PatternEngine();
  final _export = ExportService();
  final _ai = AiRecheckService();

  List<RoundRecord> _records = [];
  PatternSignal _signal = const PatternSignal(patternName: 'Loading', watchSignal: 'Wait', riskLevel: 'Low', reason: 'Loading data...');
  int _wrongStreak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await _storage.loadRecords();
    final wrong = await _storage.getWrongPredictionStreak();
    final signal = _engine.analyze(records, wrongPredictionStreak: wrong);
    setState(() {
      _records = records;
      _wrongStreak = wrong;
      _signal = signal;
      _loading = false;
    });
  }

  int get _nextRound {
    if (_records.isEmpty) return 1;
    return _records.map((e) => e.roundNo).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> _quickAdd(ResultType result) async {
    final analyzedBefore = _engine.analyze(_records, wrongPredictionStreak: _wrongStreak);
    final previousPrediction = analyzedBefore.watchSignal.toLowerCase();
    final actualFamily = result.family.label.toLowerCase();

    int newWrongStreak = _wrongStreak;
    if (_records.isNotEmpty) {
      final matched = previousPrediction.contains('wait') ||
          previousPrediction.contains('break') ||
          (previousPrediction.contains('green') && actualFamily.contains('green')) ||
          (previousPrediction.contains('yellow') && actualFamily.contains('yellow')) ||
          (previousPrediction.contains('purple') && actualFamily.contains('purple')) ||
          (previousPrediction.contains('pink') && actualFamily.contains('pink')) ||
          (previousPrediction.contains('small') && (actualFamily.contains('green') || actualFamily.contains('purple')));
      newWrongStreak = matched ? 0 : (_wrongStreak + 1);
    }

    final tempRecord = RoundRecord(roundNo: _nextRound, result: result, capturedAt: DateTime.now());
    final newList = [..._records, tempRecord];
    final signal = _engine.analyze(newList, wrongPredictionStreak: newWrongStreak);
    final record = tempRecord.copyWith(
      patternFound: signal.patternName,
      riskLevel: signal.riskLevel,
      watchSignal: signal.watchSignal,
      note: signal.reason,
    );

    await _storage.addRecord(record);
    await _storage.setWrongPredictionStreak(newWrongStreak);
    await _storage.setLastPrediction(signal.watchSignal);
    await _load();
  }

  Future<void> _saveCurrentPattern() async {
    final lastRound = _records.isNotEmpty ? _records.last.roundNo : null;
    await _storage.savePattern(SavedPattern(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _signal.patternName,
      note: _signal.reason,
      confidence: _signal.confidence > 0.65 ? 'High' : _signal.confidence > 0.45 ? 'Medium' : 'Low',
      lastSeenRound: lastRound,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pattern saved')));
  }

  Future<void> _exportCsv() async {
    if (_records.isEmpty) return;
    await _export.shareCsv(_records);
  }

  Future<void> _showAiPrompt() async {
    final prompt = await _ai.buildAiPrompt(_records, _signal.reason);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Recheck Prompt'),
        content: SingleChildScrollView(child: Text(prompt)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _resetWrongStreak() async {
    await _storage.setWrongPredictionStreak(0);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final last = _records.isNotEmpty ? _records.last : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Star Pattern Assistant V2'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                SignalCard(signal: _signal),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: Text('Current Round: ${last?.roundNo ?? 0}'),
                    subtitle: Text('Last Result: ${last?.result.label ?? 'No data'}\nWrong Prediction Streak: $_wrongStreak'),
                    trailing: _signal.aiRecheckNeeded ? const Icon(Icons.psychology, color: Colors.red) : const Icon(Icons.insights),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Quick Add Result', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ResultType.values.where((e) => e != ResultType.unknown).map((r) {
                    return FilledButton.tonal(onPressed: () => _quickAdd(r), child: Text(r.label));
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(onPressed: _saveCurrentPattern, icon: const Icon(Icons.bookmark_add), label: const Text('Save Pattern')),
                    FilledButton.icon(onPressed: _exportCsv, icon: const Icon(Icons.file_download), label: const Text('Export/Share CSV')),
                    FilledButton.icon(onPressed: _showAiPrompt, icon: const Icon(Icons.psychology), label: const Text('AI Recheck')),
                    OutlinedButton.icon(onPressed: _resetWrongStreak, icon: const Icon(Icons.restart_alt), label: const Text('Reset Wrong Streak')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordsScreen())), child: const Text('View Data'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatternLibraryScreen())), child: const Text('Pattern Library'))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveAssistantScreen())), icon: const Icon(Icons.visibility), label: const Text('Live Overlay V2'))),
                  ],
                ),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Version 1: manual quick add + pattern engine + save/export.\nVersion 2 me live screen capture, overlay, OCR/image matching add hoga.',
                    ),
                  ),
                )
              ],
            ),
    );
  }
}

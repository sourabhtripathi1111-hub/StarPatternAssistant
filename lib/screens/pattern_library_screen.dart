import 'package:flutter/material.dart';
import '../models/saved_pattern.dart';
import '../services/storage_service.dart';

class PatternLibraryScreen extends StatefulWidget {
  const PatternLibraryScreen({super.key});

  @override
  State<PatternLibraryScreen> createState() => _PatternLibraryScreenState();
}

class _PatternLibraryScreenState extends State<PatternLibraryScreen> {
  final _storage = StorageService();
  List<SavedPattern> _patterns = [];

  final List<String> _defaultPatterns = const [
    'Same Repeat',
    'Family Repeat',
    '3-2-1 Pattern',
    '2-2-2-1 Pattern',
    '1-2-1 Pattern',
    '1-2-1-2-1 Zigzag',
    'AAB-BBA Mirror',
    'Big Boundary + Middle 3 Block',
    'Substitute Pattern',
    'Yellow/Big vs Purple Balance',
    'Green Cluster Break',
    'Big Cluster Break',
    'x25 Return-to-Small',
    'x50 Bait Risk',
    'New Learned Pattern',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _storage.loadPatterns();
    setState(() => _patterns = p.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pattern Library')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('Default Pattern Rules', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._defaultPatterns.map((p) => Card(child: ListTile(title: Text(p), subtitle: const Text('Built-in rule')))),
          const SizedBox(height: 16),
          Text('Saved/Learned Patterns', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_patterns.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('No saved pattern yet.'))),
          ..._patterns.map((p) => Card(
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text('${p.note}\nConfidence: ${p.confidence} | Last Seen: ${p.lastSeenRound ?? '-'}'),
                  isThreeLine: true,
                ),
              )),
        ],
      ),
    );
  }
}

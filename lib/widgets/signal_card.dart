import 'package:flutter/material.dart';
import '../models/pattern_signal.dart';

class SignalCard extends StatelessWidget {
  final PatternSignal signal;
  const SignalCard({super.key, required this.signal});

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.red.shade100;
      case 'medium':
        return Colors.orange.shade100;
      default:
        return Colors.green.shade100;
    }
  }

  String _emoji(String watch) {
    final w = watch.toLowerCase();
    if (w.contains('green')) return '🟢';
    if (w.contains('yellow') || w.contains('big')) return '🟡';
    if (w.contains('purple') || w.contains('pink')) return '🟣';
    if (w.contains('wait') || w.contains('risk')) return '🔴';
    return '⚠️';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _riskColor(signal.riskLevel),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_emoji(signal.watchSignal)} WATCH: ${signal.watchSignal}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Pattern: ${signal.patternName}'),
            Text('Risk: ${signal.riskLevel}'),
            Text('Confidence: ${(signal.confidence * 100).round()}%'),
            const SizedBox(height: 8),
            Text('Reason: ${signal.reason}'),
            if (signal.aiRecheckNeeded) ...[
              const SizedBox(height: 8),
              const Text('External AI recheck needed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}

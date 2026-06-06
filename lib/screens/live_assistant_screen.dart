
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/round_record.dart';
import '../services/live_capture_service.dart';
import '../services/pattern_engine.dart';
import '../services/storage_service.dart';
import '../widgets/signal_card.dart';

class LiveAssistantScreen extends StatefulWidget {
  const LiveAssistantScreen({super.key});

  @override
  State<LiveAssistantScreen> createState() => _LiveAssistantScreenState();
}

class _LiveAssistantScreenState extends State<LiveAssistantScreen> {
  final _live = LiveCaptureService();
  final _storage = StorageService();
  final _engine = PatternEngine();
  bool _overlayAllowed = false;
  bool _running = false;
  bool _autoTest = false;
  Timer? _timer;
  String _status = 'Live mode ready. Start karne se pehle overlay permission check karo.';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final allowed = await _live.hasOverlayPermission();
    if (!mounted) return;
    setState(() => _overlayAllowed = allowed);
  }

  Future<void> _requestPermission() async {
    await _live.requestOverlayPermission();
    setState(() => _status = 'Permission screen khuli hai. Allow karke wapas aao, phir Check dabao.');
  }

  Future<void> _start() async {
    final res = await _live.startLiveAssistant();
    setState(() {
      _running = res.ok;
      _status = res.message;
    });
    await _pushCurrentSignalToOverlay();
  }

  Future<void> _stop() async {
    final res = await _live.stopLiveAssistant();
    _timer?.cancel();
    setState(() {
      _running = false;
      _autoTest = false;
      _status = res.message;
    });
  }

  Future<void> _captureOnce() async {
    final res = await _live.captureOnce();
    setState(() => _status = res.message);
    await _pushCurrentSignalToOverlay();
  }

  Future<void> _pushCurrentSignalToOverlay() async {
    final records = await _storage.loadRecords();
    final wrong = await _storage.getWrongPredictionStreak();
    final signal = _engine.analyze(records, wrongPredictionStreak: wrong);
    await _live.updateOverlay(watch: signal.watchSignal, risk: signal.riskLevel, reason: signal.reason);
    if (mounted) setState(() {});
  }

  Future<void> _toggleAutoTest() async {
    if (_autoTest) {
      _timer?.cancel();
      setState(() => _autoTest = false);
      return;
    }
    setState(() => _autoTest = true);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _captureOnce());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_storage.loadRecords(), _storage.getWrongPredictionStreak()]),
      builder: (context, snapshot) {
        final records = snapshot.hasData ? snapshot.data![0] as List<RoundRecord> : <RoundRecord>[];
        final wrong = snapshot.hasData ? snapshot.data![1] as int : 0;
        final signal = _engine.analyze(records, wrongPredictionStreak: wrong);
        return Scaffold(
          appBar: AppBar(title: const Text('Live Overlay Assistant V2')),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              SignalCard(signal: signal),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overlay Permission: ${_overlayAllowed ? 'Allowed' : 'Not Allowed'}'),
                      Text('Live Running: ${_running ? 'Yes' : 'No'}'),
                      const SizedBox(height: 8),
                      Text(_status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(onPressed: _checkPermission, icon: const Icon(Icons.verified), label: const Text('Check Permission')),
                  FilledButton.tonalIcon(onPressed: _requestPermission, icon: const Icon(Icons.open_in_new), label: const Text('Allow Overlay')),
                  FilledButton.icon(onPressed: _running ? null : _start, icon: const Icon(Icons.play_arrow), label: const Text('Start Live')),
                  FilledButton.tonalIcon(onPressed: _running ? _stop : null, icon: const Icon(Icons.stop), label: const Text('Stop')),
                  OutlinedButton.icon(onPressed: _captureOnce, icon: const Icon(Icons.camera_alt), label: const Text('Capture Once')),
                  OutlinedButton.icon(onPressed: _toggleAutoTest, icon: const Icon(Icons.timer), label: Text(_autoTest ? 'Stop Auto Test' : 'Auto Test 5s')),
                ],
              ),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'V2 me native Android method-channel base add hai. Real full screen-capture/OCR/image-matching ke liye next Android service module add karna hoga. Auto betting nahi hai.',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


import 'package:flutter/services.dart';

class LiveCaptureResult {
  final bool ok;
  final String message;
  final Map<String, dynamic>? data;

  const LiveCaptureResult({required this.ok, required this.message, this.data});

  factory LiveCaptureResult.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const LiveCaptureResult(ok: false, message: 'No response');
    return LiveCaptureResult(
      ok: map['ok'] == true,
      message: (map['message'] ?? '').toString(),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
    );
  }
}

class LiveCaptureService {
  static const MethodChannel _channel = MethodChannel('star_pattern_assistant/live');

  Future<bool> hasOverlayPermission() async {
    final result = await _channel.invokeMethod<bool>('hasOverlayPermission');
    return result ?? false;
  }

  Future<void> requestOverlayPermission() async {
    await _channel.invokeMethod('requestOverlayPermission');
  }

  Future<LiveCaptureResult> startLiveAssistant() async {
    final response = await _channel.invokeMethod<Map<dynamic, dynamic>>('startLiveAssistant');
    return LiveCaptureResult.fromMap(response);
  }

  Future<LiveCaptureResult> stopLiveAssistant() async {
    final response = await _channel.invokeMethod<Map<dynamic, dynamic>>('stopLiveAssistant');
    return LiveCaptureResult.fromMap(response);
  }

  Future<LiveCaptureResult> captureOnce() async {
    final response = await _channel.invokeMethod<Map<dynamic, dynamic>>('captureOnce');
    return LiveCaptureResult.fromMap(response);
  }

  Future<void> updateOverlay({required String watch, required String risk, required String reason}) async {
    await _channel.invokeMethod('updateOverlay', {
      'watch': watch,
      'risk': risk,
      'reason': reason,
    });
  }
}

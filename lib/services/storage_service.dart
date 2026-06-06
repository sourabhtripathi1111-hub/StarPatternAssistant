import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/round_record.dart';
import '../models/saved_pattern.dart';

class StorageService {
  static const _recordsKey = 'round_records_v1';
  static const _patternsKey = 'saved_patterns_v1';
  static const _wrongStreakKey = 'wrong_prediction_streak_v1';
  static const _lastPredictionKey = 'last_prediction_v1';

  Future<List<RoundRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_recordsKey) ?? [];
    return list.map(RoundRecord.fromJson).toList()..sort((a, b) => a.roundNo.compareTo(b.roundNo));
  }

  Future<void> saveRecords(List<RoundRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recordsKey, records.map((e) => e.toJson()).toList());
  }

  Future<void> addRecord(RoundRecord record) async {
    final records = await loadRecords();
    records.removeWhere((e) => e.roundNo == record.roundNo);
    records.add(record);
    await saveRecords(records);
  }

  Future<List<SavedPattern>> loadPatterns() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_patternsKey) ?? [];
    return list.map(SavedPattern.fromJson).toList();
  }

  Future<void> savePattern(SavedPattern pattern) async {
    final prefs = await SharedPreferences.getInstance();
    final patterns = await loadPatterns();
    patterns.add(pattern);
    await prefs.setStringList(_patternsKey, patterns.map((e) => e.toJson()).toList());
  }

  Future<int> getWrongPredictionStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_wrongStreakKey) ?? 0;
  }

  Future<void> setWrongPredictionStreak(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_wrongStreakKey, value);
  }

  Future<String?> getLastPrediction() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPredictionKey);
  }

  Future<void> setLastPrediction(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPredictionKey, value);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordsKey);
    await prefs.remove(_patternsKey);
    await prefs.remove(_wrongStreakKey);
    await prefs.remove(_lastPredictionKey);
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zikr_event.dart';
import '../services/stats_service.dart';

class ZikrController extends ChangeNotifier {
  static final ZikrController instance = ZikrController._();
  ZikrController._();

  List<ZikrEvent> events = [];

  // دعم الكود القديم
  List<dynamic> allZikr = [];
  List<String> get leafTexts => events.map((e) => e.text).toList();
  List<String> get completedZikr => events.map((e) => e.text).toList();
  int get total => events.length;

  Future<void> loadFromStorage() async => load();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("zikr_events") ?? [];

    events = data.map((e) => ZikrEvent.fromJson(jsonDecode(e))).toList();

    allZikr = events.map((e) => e.text).toList();

    StatsService.loadFromController(events);
    notifyListeners();
  }

  Future<void> add(String text, {String source = "tasbih"}) async {
    final event = ZikrEvent.create(
      text: text,
      source: source,
    );

    events.add(event);
    allZikr.add(text);

    await StatsService.recordZikr(event);

    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = events.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList("zikr_events", data);
  }

  Future<void> reset() async {
    events.clear();
    allZikr.clear();
    await _save();
    notifyListeners();
  }
}
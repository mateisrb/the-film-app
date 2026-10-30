import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/camera_profile.dart';
import '../models/film_stock.dart';
import '../models/field_roll.dart';

class StorageService {
  static const _rollsKey = 'the_film_app_rolls_v1';
  static const _camerasKey = 'the_film_app_cameras_v1';
  static const _lensesKey = 'the_film_app_lenses_v1';
  static const _stocksKey = 'the_film_app_stocks_v1';

  static Future<List<FieldRoll>> loadRolls() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_rollsKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => FieldRoll.fromJson(e)).toList();
      } catch (_) {}
    }
    return [
      FieldRoll(
        id: 'roll-01',
        name: 'Roll #01 - Street Notes',
        cameraName: 'Leica M6',
        filmStockName: 'Kodak Portra 400',
        ratedIso: 400,
        createdAt: DateTime.now(),
      ),
    ];
  }

  static Future<void> saveRolls(List<FieldRoll> rolls) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(rolls.map((r) => r.toJson()).toList());
    await prefs.setString(_rollsKey, jsonStr);
  }

  static Future<List<CameraProfile>> loadCameras() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_camerasKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => CameraProfile.fromJson(e)).toList();
      } catch (_) {}
    }
    return defaultCameras;
  }

  static Future<void> saveCameras(List<CameraProfile> cameras) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(cameras.map((c) => c.toJson()).toList());
    await prefs.setString(_camerasKey, jsonStr);
  }

  static Future<List<LensProfile>> loadLenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_lensesKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => LensProfile.fromJson(e)).toList();
      } catch (_) {}
    }
    return defaultLenses;
  }

  static Future<void> saveLenses(List<LensProfile> lenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(lenses.map((l) => l.toJson()).toList());
    await prefs.setString(_lensesKey, jsonStr);
  }

  static Future<List<FilmStock>> loadFilmStocks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_stocksKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => FilmStock.fromJson(e)).toList();
      } catch (_) {}
    }
    return defaultFilmStocks;
  }

  static Future<void> saveFilmStocks(List<FilmStock> stocks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(stocks.map((s) => s.toJson()).toList());
    await prefs.setString(_stocksKey, jsonStr);
  }
}

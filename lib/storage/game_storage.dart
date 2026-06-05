import 'package:hive_flutter/hive_flutter.dart';

import '../models/building.dart';
import '../models/resource.dart';
import 'hive_adapters.dart';

/// Wraps Hive for persisting the game's [Resources] and [Building] list.
///
/// Call [init] once at startup (after `Hive.initFlutter()` or instead of it —
/// [init] performs both). Adapters are registered idempotently.
class GameStorage {
  GameStorage._();

  static const String _boxName = 'frozen_wasteland_save';
  static const String _resourcesKey = 'resources';
  static const String _buildingsKey = 'buildings';
  static const String _lastSaveKey = 'lastSave';

  static late Box _box;
  static bool _initialized = false;

  /// Initializes Hive, registers adapters, and opens the save box.
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _registerAdapters();
    _box = await Hive.openBox(_boxName);
    _initialized = true;
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTypeIds.resources)) {
      Hive.registerAdapter(ResourcesAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.buildingType)) {
      Hive.registerAdapter(BuildingTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIds.building)) {
      Hive.registerAdapter(BuildingAdapter());
    }
  }

  // --- Resources -----------------------------------------------------------
  static Future<void> saveResources(Resources resources) async {
    await _box.put(_resourcesKey, resources);
    await _box.put(_lastSaveKey, DateTime.now().toIso8601String());
  }

  static Resources? loadResources() {
    final value = _box.get(_resourcesKey);
    return value is Resources ? value : null;
  }

  // --- Buildings -----------------------------------------------------------
  static Future<void> saveBuildings(List<Building> buildings) async {
    await _box.put(_buildingsKey, buildings);
    await _box.put(_lastSaveKey, DateTime.now().toIso8601String());
  }

  static List<Building> loadBuildings() {
    final value = _box.get(_buildingsKey);
    if (value is List) {
      return value.whereType<Building>().toList();
    }
    return const [];
  }

  // --- Meta ----------------------------------------------------------------
  static DateTime? get lastSave {
    final raw = _box.get(_lastSaveKey);
    return raw is String ? DateTime.tryParse(raw) : null;
  }

  static bool get hasSave => _box.containsKey(_resourcesKey);

  static Future<void> clear() async => _box.clear();
}

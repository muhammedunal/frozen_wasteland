import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flame/components.dart';

import '../models/building.dart';
import '../models/game_state.dart';
import 'api_service.dart';

/// A placeholder backend for testing / offline play.
///
/// Stores saved games in-memory by default. If a [storageFile] is provided it
/// also persists to a local JSON file (works in unit tests via `dart:io`,
/// no plugins required). An artificial [latency] simulates network delay, and
/// [failTimes] can force the first N calls to fail (to exercise retry logic).
class MockApiService implements GameApi {
  final Map<String, Map<String, dynamic>> _store = {};
  final File? storageFile;
  final Duration latency;

  /// Number of leading calls that should throw a transient error.
  int failTimes;

  MockApiService({
    this.storageFile,
    this.latency = Duration.zero,
    this.failTimes = 0,
  }) {
    _loadFromFile();
  }

  void _loadFromFile() {
    final f = storageFile;
    if (f != null && f.existsSync()) {
      try {
        final decoded = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        decoded.forEach((k, v) {
          _store[k] = Map<String, dynamic>.from(v as Map);
        });
      } catch (_) {
        // Corrupt file — start fresh.
      }
    }
  }

  Future<void> _persist() async {
    final f = storageFile;
    if (f != null) {
      await f.writeAsString(jsonEncode(_store));
    }
  }

  Future<void> _simulate() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (failTimes > 0) {
      failTimes--;
      throw const ApiException('Simulated network failure',
          kind: ApiErrorKind.network);
    }
  }

  @override
  Future<void> saveGame(String userId, GameState state) async {
    await _simulate();
    _store[userId] = state.toJson();
    await _persist();
  }

  @override
  Future<GameState> loadGame(String userId) async {
    await _simulate();
    final json = _store[userId];
    if (json == null) {
      throw ApiException('No save for "$userId"',
          statusCode: 404, kind: ApiErrorKind.notFound);
    }
    return GameState.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<List<Building>> fetchLeaderboard() async {
    await _simulate();
    // Deterministic sample leaderboard data.
    return [
      Building(
        id: 'lb_1',
        type: BuildingType.barn,
        gridPosition: Vector2(0, 0),
        level: 5,
      ),
      Building(
        id: 'lb_2',
        type: BuildingType.house,
        gridPosition: Vector2(1, 1),
        level: 3,
      ),
      Building(
        id: 'lb_3',
        type: BuildingType.tree,
        gridPosition: Vector2(2, 2),
        level: 1,
      ),
    ];
  }

  /// Test helper: whether a save exists for [userId].
  bool hasSave(String userId) => _store.containsKey(userId);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/building.dart';
import '../models/game_state.dart';
import '../services/api_service.dart';
import '../services/mock_api_service.dart';
import 'game_state_provider.dart';

/// Toggle: when true the app talks to the in-memory [MockApiService] instead of
/// the real [ApiService] (Dio). Defaults to mock so the app runs without a
/// live backend; override in `ProviderScope` for production.
final useMockApiProvider = Provider<bool>((ref) => true);

/// The backend client (real or mock) used across the app.
final apiServiceProvider = Provider<GameApi>((ref) {
  return ref.watch(useMockApiProvider)
      ? MockApiService()
      : ApiService();
});

/// The current user id (wire to real auth later).
final userIdProvider = Provider<String>((ref) => 'local-player');

/// Saves the current [GameState] to the backend. Read via
/// `ref.read(saveGameProvider.future)` to trigger and await the result.
final saveGameProvider = FutureProvider.autoDispose<void>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final userId = ref.watch(userIdProvider);
  final state = ref.watch(gameStateProvider);
  await api.saveGame(userId, state);
});

/// Loads the saved [GameState] for the current user.
final loadGameProvider = FutureProvider.autoDispose<GameState>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final userId = ref.watch(userIdProvider);
  return api.loadGame(userId);
});

/// Fetches the leaderboard.
final leaderboardProvider =
    FutureProvider.autoDispose<List<Building>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchLeaderboard();
});

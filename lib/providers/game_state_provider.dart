import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_state.dart';
import '../models/resource.dart';
import '../storage/game_storage.dart';
import 'building_provider.dart';
import 'resource_provider.dart';

/// Drives the overall game phase (menu, playing, paused, etc.).
class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier(this._ref) : super(GameState());

  final Ref _ref;

  void startGame() {
    _ref.read(resourceProvider.notifier).reset();
    _ref.read(buildingProvider.notifier).clear();
    state = GameState.initial(
      startingResources: _ref.read(resourceProvider),
    );
  }

  void pause() {
    if (state.phase == GamePhase.playing) {
      state = state.copyWith(phase: GamePhase.paused);
    }
  }

  void resume() {
    if (state.phase == GamePhase.paused) {
      state = state.copyWith(phase: GamePhase.playing);
    }
  }

  void toMenu() {
    state = state.copyWith(phase: GamePhase.menu);
  }

  void gameOver() {
    state = state.copyWith(phase: GamePhase.gameOver);
  }

  /// Mirrors resource changes coming from the Flame layer into game state.
  void syncResources(Resources resources) {
    state = state.copyWith(resources: resources);
  }

  void tickTime(double dt) {
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + dt);
  }

  /// Persists resources + buildings to Hive and stamps [GameState.lastSave].
  Future<void> save() async {
    await GameStorage.saveResources(state.resources);
    await GameStorage.saveBuildings(state.buildings);
    state = state.copyWith(lastSave: DateTime.now());
  }
}

/// Global game-state provider.
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier(ref);
});

/// Convenience selector exposing just the current [GamePhase].
final gamePhaseProvider = Provider<GamePhase>((ref) {
  return ref.watch(gameStateProvider).phase;
});

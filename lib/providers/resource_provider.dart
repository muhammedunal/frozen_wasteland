import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/resource.dart';
import '../storage/game_storage.dart';

/// Holds and mutates the player's [Resources].
///
/// Because [Resources] is mutable, every public mutation produces a fresh copy
/// so Riverpod listeners are notified.
class ResourceNotifier extends StateNotifier<Resources> {
  ResourceNotifier([Resources? initial]) : super(initial ?? Resources());

  /// Replaces the whole snapshot (used to mirror the Flame game).
  void set(Resources resources) => state = resources;

  void produce(ResourceType type, int amount) {
    final next = state.copyWith();
    next.produce(type, amount);
    state = next;
  }

  void consume(ResourceType type, int amount) {
    final next = state.copyWith();
    next.consume(type, amount);
    state = next;
  }

  /// Attempts to spend [costs]; returns true on success.
  bool spend(Map<ResourceType, int> costs) {
    if (!state.canAfford(costs)) return false;
    final next = state.copyWith();
    next.spend(costs);
    state = next;
    return true;
  }

  void addPopulation(int delta) {
    final next = state.copyWith();
    next.addPopulation(delta);
    state = next;
  }

  void adjustHappiness(int delta) {
    final next = state.copyWith();
    next.adjustHappiness(delta);
    state = next;
  }

  /// Persists the current resources to Hive (best-effort).
  Future<void> persist() => GameStorage.saveResources(state);

  /// Loads persisted resources, if any.
  void loadFromStorage() {
    final loaded = GameStorage.loadResources();
    if (loaded != null) state = loaded;
  }

  void reset() => state = Resources();
}

/// The mutable resource notifier provider.
final resourceProvider =
    StateNotifierProvider<ResourceNotifier, Resources>((ref) {
  return ResourceNotifier();
});

/// Read-only convenience provider exposing just the current [Resources].
final resourcesProvider = Provider<Resources>((ref) {
  return ref.watch(resourceProvider);
});

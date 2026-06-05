import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/building.dart';

/// Manages the list of placed buildings and the current placement selection.
class BuildingNotifier extends StateNotifier<List<Building>> {
  BuildingNotifier() : super(const []);

  void addBuilding(Building building) {
    state = [...state, building];
  }

  void removeBuilding(String id) {
    state = state.where((b) => b.id != id).toList();
  }

  void updateBuilding(Building building) {
    state = [
      for (final b in state) if (b.id == building.id) building else b,
    ];
  }

  void replaceAll(List<Building> buildings) {
    state = List.unmodifiable(buildings);
  }

  void clear() => state = const [];
}

/// Provider for the placed-building list.
final buildingProvider =
    StateNotifierProvider<BuildingNotifier, List<Building>>((ref) {
  return BuildingNotifier();
});

/// The building type currently selected for placement (null = none).
final selectedBuildingTypeProvider =
    StateProvider<BuildingType?>((ref) => BuildingType.house);

/// Alias matching the UI naming in the spec.
final selectedBuildingProvider = selectedBuildingTypeProvider;

/// Whether the player is in "placement mode" (taps place the selected building).
final placementModeProvider = StateProvider<bool>((ref) => false);

/// Whether the game loop is paused.
final pausedProvider = StateProvider<bool>((ref) => false);

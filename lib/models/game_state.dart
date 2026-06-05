import 'animal.dart';
import 'building.dart';
import 'resource.dart';

/// High-level status of a game session.
enum GamePhase { menu, loading, playing, paused, gameOver }

/// Immutable aggregate of the whole game's runtime state.
class GameState {
  final GamePhase phase;
  final Resources resources;
  final List<Building> buildings;
  final List<Animal> animals;

  /// Elapsed in-game time in seconds.
  final double elapsedSeconds;

  /// Timestamp of the last persistence write.
  final DateTime lastSave;

  /// Currently selected building type for placement (null = none).
  final BuildingType? selectedBuildingType;

  GameState({
    this.phase = GamePhase.menu,
    Resources? resources,
    this.buildings = const [],
    this.animals = const [],
    this.elapsedSeconds = 0.0,
    DateTime? lastSave,
    this.selectedBuildingType,
  })  : resources = resources ?? Resources(),
        lastSave = lastSave ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Convenience factory for a fresh playable state.
  factory GameState.initial({Resources? startingResources}) {
    return GameState(
      phase: GamePhase.playing,
      resources: startingResources ?? Resources(),
      buildings: const [],
      animals: const [],
      elapsedSeconds: 0.0,
      lastSave: DateTime.now(),
    );
  }

  GameState copyWith({
    GamePhase? phase,
    Resources? resources,
    List<Building>? buildings,
    List<Animal>? animals,
    double? elapsedSeconds,
    DateTime? lastSave,
    BuildingType? selectedBuildingType,
    bool clearSelectedBuilding = false,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      resources: resources ?? this.resources,
      buildings: buildings ?? this.buildings,
      animals: animals ?? this.animals,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      lastSave: lastSave ?? this.lastSave,
      selectedBuildingType: clearSelectedBuilding
          ? null
          : (selectedBuildingType ?? this.selectedBuildingType),
    );
  }

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'resources': resources.toJson(),
        'buildings': buildings.map((b) => b.toJson()).toList(),
        'animals': animals.map((a) => a.toJson()).toList(),
        'elapsedSeconds': elapsedSeconds,
        'lastSave': lastSave.toIso8601String(),
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        phase: GamePhase.values.firstWhere(
          (p) => p.name == json['phase'],
          orElse: () => GamePhase.menu,
        ),
        resources: Resources.fromJson(
            Map<String, dynamic>.from(json['resources'] as Map)),
        buildings: (json['buildings'] as List<dynamic>? ?? [])
            .map((e) => Building.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        animals: (json['animals'] as List<dynamic>? ?? [])
            .map((e) => Animal.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        elapsedSeconds: (json['elapsedSeconds'] ?? 0.0).toDouble(),
        lastSave: DateTime.tryParse(json['lastSave'] as String? ?? '') ??
            DateTime.now(),
      );
}

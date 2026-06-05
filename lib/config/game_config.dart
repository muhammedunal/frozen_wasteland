/// Tunable gameplay configuration values.
///
/// Keeping these separate from [GameConstants] lets designers balance the game
/// without touching engine-level constants.
class GameConfig {
  GameConfig._();

  // ---------------------------------------------------------------------------
  // Economy
  // ---------------------------------------------------------------------------
  /// Starting amount of each resource for a new game.
  static const int startingWood = 50;
  static const int startingFood = 50;
  static const int startingStone = 30;

  /// Interval (seconds) at which resources are produced automatically.
  static const double resourceTickSeconds = 5.0;

  // ---------------------------------------------------------------------------
  // Buildings
  // ---------------------------------------------------------------------------
  /// Build cost lookup by building type id.
  static const Map<String, Map<String, int>> buildCosts = {
    'house': {'wood': 20, 'stone': 10},
    'barn': {'wood': 30, 'stone': 5},
    'storage': {'wood': 15, 'stone': 20},
    'campfire': {'wood': 10},
  };

  /// Time (seconds) required to finish constructing a building.
  static const double buildTimeSeconds = 8.0;

  // ---------------------------------------------------------------------------
  // Animals
  // ---------------------------------------------------------------------------
  /// Maximum number of wandering animals allowed on the map.
  static const int maxAnimals = 8;

  /// Seconds an animal idles before choosing a new wander target.
  static const double animalIdleSeconds = 2.0;

  // ---------------------------------------------------------------------------
  // Difficulty
  // ---------------------------------------------------------------------------
  /// Whether automatic resource generation is enabled.
  static const bool autoProduceResources = true;

  /// Global gameplay speed multiplier.
  static const double gameSpeed = 1.0;
}

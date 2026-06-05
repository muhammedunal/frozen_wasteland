/// The consumable / produceable resource kinds.
///
/// Note: `population` and `happiness` are tracked separately on [Resources]
/// because they have bounded semantics (caps, 0-100 range) that don't fit the
/// simple add/subtract model used by [Resources.consume] / [Resources.produce].
enum ResourceType { food, wood, stone, coin }

extension ResourceTypeX on ResourceType {
  String get id {
    switch (this) {
      case ResourceType.food:
        return 'food';
      case ResourceType.wood:
        return 'wood';
      case ResourceType.stone:
        return 'stone';
      case ResourceType.coin:
        return 'coin';
    }
  }

  String get label {
    switch (this) {
      case ResourceType.food:
        return 'Food';
      case ResourceType.wood:
        return 'Wood';
      case ResourceType.stone:
        return 'Stone';
      case ResourceType.coin:
        return 'Coin';
    }
  }

  static ResourceType fromId(String id) {
    return ResourceType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => ResourceType.food,
    );
  }
}

/// Mutable container for the player's economy.
///
/// Stockpiled resources (food/wood/stone/coin) are mutated via
/// [consume] / [produce]; [population] and [happiness] have dedicated helpers
/// because they are bounded.
class Resources {
  int food;
  int wood;
  int stone;
  int coin;

  int population;
  int maxPopulation;

  /// 0-100.
  int happiness;

  /// Storage cap for food (drives the "x/max" UI display).
  int maxFood;

  Resources({
    this.food = 100,
    this.wood = 50,
    this.stone = 30,
    this.coin = 0,
    this.population = 0,
    this.maxPopulation = 10,
    this.happiness = 50,
    this.maxFood = 200,
  });

  // --- Stockpile access ----------------------------------------------------
  int amountOf(ResourceType type) {
    switch (type) {
      case ResourceType.food:
        return food;
      case ResourceType.wood:
        return wood;
      case ResourceType.stone:
        return stone;
      case ResourceType.coin:
        return coin;
    }
  }

  void _set(ResourceType type, int value) {
    switch (type) {
      case ResourceType.food:
        food = value;
        break;
      case ResourceType.wood:
        wood = value;
        break;
      case ResourceType.stone:
        stone = value;
        break;
      case ResourceType.coin:
        coin = value;
        break;
    }
  }

  // --- Mutators ------------------------------------------------------------
  /// Removes [amount] of [type] (clamped at zero).
  void consume(ResourceType type, int amount) {
    final next = (amountOf(type) - amount).clamp(0, 1 << 31);
    _set(type, next);
  }

  /// Adds [amount] of [type]. Food respects [maxFood].
  void produce(ResourceType type, int amount) {
    var next = amountOf(type) + amount;
    if (type == ResourceType.food) {
      next = next.clamp(0, maxFood);
    }
    _set(type, next);
  }

  /// Whether the stockpile can cover [costs].
  bool canAfford(Map<ResourceType, int> costs) {
    for (final entry in costs.entries) {
      if (amountOf(entry.key) < entry.value) return false;
    }
    return true;
  }

  /// Deducts [costs] if affordable; returns true on success.
  bool spend(Map<ResourceType, int> costs) {
    if (!canAfford(costs)) return false;
    for (final entry in costs.entries) {
      consume(entry.key, entry.value);
    }
    return true;
  }

  // --- Population & happiness ----------------------------------------------
  /// Adds [delta] settlers, clamped to [0, maxPopulation].
  void addPopulation(int delta) {
    population = (population + delta).clamp(0, maxPopulation);
  }

  /// Adjusts happiness, clamped to [0, 100].
  void adjustHappiness(int delta) {
    happiness = (happiness + delta).clamp(0, 100);
  }

  bool get isAtPopulationCap => population >= maxPopulation;

  Resources copyWith({
    int? food,
    int? wood,
    int? stone,
    int? coin,
    int? population,
    int? maxPopulation,
    int? happiness,
    int? maxFood,
  }) {
    return Resources(
      food: food ?? this.food,
      wood: wood ?? this.wood,
      stone: stone ?? this.stone,
      coin: coin ?? this.coin,
      population: population ?? this.population,
      maxPopulation: maxPopulation ?? this.maxPopulation,
      happiness: happiness ?? this.happiness,
      maxFood: maxFood ?? this.maxFood,
    );
  }

  Map<String, dynamic> toJson() => {
        'food': food,
        'wood': wood,
        'stone': stone,
        'coin': coin,
        'population': population,
        'maxPopulation': maxPopulation,
        'happiness': happiness,
        'maxFood': maxFood,
      };

  factory Resources.fromJson(Map<String, dynamic> json) => Resources(
        food: (json['food'] ?? 100) as int,
        wood: (json['wood'] ?? 50) as int,
        stone: (json['stone'] ?? 30) as int,
        coin: (json['coin'] ?? 0) as int,
        population: (json['population'] ?? 0) as int,
        maxPopulation: (json['maxPopulation'] ?? 10) as int,
        happiness: (json['happiness'] ?? 50) as int,
        maxFood: (json['maxFood'] ?? 200) as int,
      );

  @override
  String toString() =>
      'Resources(food: $food/$maxFood, wood: $wood, stone: $stone, '
      'coin: $coin, pop: $population/$maxPopulation, happy: $happiness%)';
}

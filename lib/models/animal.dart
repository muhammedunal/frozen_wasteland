import 'package:flame/components.dart';

/// The species of a wandering animal.
enum AnimalType { bear, reindeer, wolf, elk, fox }

/// Behavioural state used by the animal AI state machine.
enum AnimalState { idle, walking, eating }

extension AnimalTypeX on AnimalType {
  String get id {
    switch (this) {
      case AnimalType.bear:
        return 'bear';
      case AnimalType.reindeer:
        return 'reindeer';
      case AnimalType.wolf:
        return 'wolf';
      case AnimalType.elk:
        return 'elk';
      case AnimalType.fox:
        return 'fox';
    }
  }

  String get displayName {
    switch (this) {
      case AnimalType.bear:
        return 'Bear';
      case AnimalType.reindeer:
        return 'Reindeer';
      case AnimalType.wolf:
        return 'Wolf';
      case AnimalType.elk:
        return 'Elk';
      case AnimalType.fox:
        return 'Fox';
    }
  }

  /// Movement speed multiplier per species (1.0 = base).
  double get speedFactor {
    switch (this) {
      case AnimalType.fox:
        return 1.6;
      case AnimalType.wolf:
        return 1.4;
      case AnimalType.reindeer:
        return 1.1;
      case AnimalType.elk:
        return 0.9;
      case AnimalType.bear:
        return 0.7;
    }
  }

  static AnimalType fromId(String id) {
    return AnimalType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => AnimalType.reindeer,
    );
  }
}

/// Data + lightweight per-frame logic for an animal.
///
/// Movement (smooth lerp between tiles) lives in the Flame `AnimalComponent`;
/// this model owns intrinsic state: position, health, hunger, and the current
/// [AnimalState]. [update] advances hunger over time.
class Animal {
  final String id;
  final AnimalType type;

  /// Current (possibly fractional) grid position; x = col, y = row.
  Vector2 gridPosition;

  int health;

  /// 0 (full) .. 100 (starving).
  int hunger;

  AnimalState state;

  /// Rate at which hunger rises per second.
  final double hungerRate;

  Animal({
    required this.id,
    required this.type,
    required this.gridPosition,
    this.health = 100,
    this.hunger = 0,
    this.state = AnimalState.idle,
    this.hungerRate = 4.0,
  });

  /// Hunger level above which the animal will seek food.
  static const int hungryThreshold = 60;

  /// Hunger level at/below which eating is considered finished.
  static const int satedThreshold = 10;

  bool get isHungry => hunger >= hungryThreshold;
  bool get isDead => health <= 0;

  int get col => gridPosition.x.round();
  int get row => gridPosition.y.round();

  /// Advances intrinsic state. Movement is handled by the component.
  void update(double dt) {
    // Hunger climbs over time (faster while walking, slower when idle).
    final multiplier = switch (state) {
      AnimalState.walking => 1.3,
      AnimalState.idle => 1.0,
      AnimalState.eating => 0.0,
    };
    hunger = (hunger + (hungerRate * multiplier * dt)).round().clamp(0, 100);

    // Starvation damages health once fully hungry.
    if (hunger >= 100) {
      health = (health - (5 * dt).ceil()).clamp(0, 100);
    }
  }

  /// Reduces hunger while eating; returns true once sated.
  bool eat(double dt, {double rate = 25.0}) {
    hunger = (hunger - (rate * dt)).round().clamp(0, 100);
    return hunger <= satedThreshold;
  }

  void takeDamage(int damage) {
    health = (health - damage).clamp(0, 100);
  }

  void heal(int amount) {
    health = (health + amount).clamp(0, 100);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.id,
        'col': col,
        'row': row,
        'health': health,
        'hunger': hunger,
        'state': state.name,
      };

  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
        id: json['id'] as String,
        type: AnimalTypeX.fromId(json['type'] as String),
        gridPosition: Vector2(
          (json['col'] as num).toDouble(),
          (json['row'] as num).toDouble(),
        ),
        health: (json['health'] ?? 100) as int,
        hunger: (json['hunger'] ?? 0) as int,
        state: AnimalState.values.firstWhere(
          (s) => s.name == json['state'],
          orElse: () => AnimalState.idle,
        ),
      );

  @override
  String toString() =>
      'Animal(${type.id} @ $col,$row hp:$health hunger:$hunger $state)';
}

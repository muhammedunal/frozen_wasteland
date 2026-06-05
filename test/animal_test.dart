import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frozen_wasteland/models/animal.dart';
import 'package:frozen_wasteland/models/building.dart';
import 'package:frozen_wasteland/game/utils/pathfinding.dart';

void main() {
  group('Animal model', () {
    Animal makeAnimal({int hunger = 0, AnimalState state = AnimalState.idle}) {
      return Animal(
        id: 'a1',
        type: AnimalType.fox,
        gridPosition: Vector2(2, 2),
        hunger: hunger,
        state: state,
      );
    }

    test('hunger increases over time while idle', () {
      final a = makeAnimal();
      a.update(1.0); // hungerRate 4.0 * idle 1.0 * 1s
      expect(a.hunger, greaterThan(0));
      expect(a.hunger, lessThanOrEqualTo(5));
    });

    test('walking increases hunger faster than idle', () {
      final idle = makeAnimal(state: AnimalState.idle);
      final walking = makeAnimal(state: AnimalState.walking);
      idle.update(1.0);
      walking.update(1.0);
      expect(walking.hunger, greaterThan(idle.hunger));
    });

    test('eating reduces hunger and reports sated', () {
      final a = makeAnimal(hunger: 80, state: AnimalState.eating);
      final satedEarly = a.eat(1.0); // -25
      expect(a.hunger, 55);
      expect(satedEarly, isFalse);
      // Eat until sated.
      var sated = false;
      for (var i = 0; i < 10 && !sated; i++) {
        sated = a.eat(1.0);
      }
      expect(sated, isTrue);
      expect(a.hunger, lessThanOrEqualTo(Animal.satedThreshold));
    });

    test('isHungry crosses the threshold', () {
      final a = makeAnimal(hunger: Animal.hungryThreshold - 1);
      expect(a.isHungry, isFalse);
      a.hunger = Animal.hungryThreshold;
      expect(a.isHungry, isTrue);
    });

    test('takeDamage and starvation lower health', () {
      final a = makeAnimal();
      a.takeDamage(30);
      expect(a.health, 70);

      final starving = makeAnimal(hunger: 100);
      starving.update(2.0);
      expect(starving.health, lessThan(100));
    });

    test('round-trips through JSON', () {
      final a = makeAnimal(hunger: 42, state: AnimalState.walking);
      final restored = Animal.fromJson(a.toJson());
      expect(restored.type, AnimalType.fox);
      expect(restored.hunger, 42);
      expect(restored.state, AnimalState.walking);
      expect(restored.col, 2);
      expect(restored.row, 2);
    });
  });

  group('Pathfinding (A*) to food', () {
    test('routes around a building obstacle', () {
      // A wall blocking the direct path between (0,1) and (2,1).
      final buildings = [
        Building(
          id: 'w1',
          type: BuildingType.wall,
          gridPosition: Vector2(1, 1),
        ),
      ];
      final path = Pathfinding.findPath(
        const GridNode(0, 1),
        const GridNode(2, 1),
        buildings,
      );
      expect(path, isNotEmpty);
      expect(path.first, const GridNode(0, 1));
      expect(path.last, const GridNode(2, 1));
      // The blocked tile must not be on the path.
      expect(path.contains(const GridNode(1, 1)), isFalse);
    });

    test('returns empty when goal is unreachable (fully walled)', () {
      // Surround the goal (1,1) on all 4 sides.
      final buildings = [
        Building(id: 'a', type: BuildingType.wall, gridPosition: Vector2(0, 1)),
        Building(id: 'b', type: BuildingType.wall, gridPosition: Vector2(2, 1)),
        Building(id: 'c', type: BuildingType.wall, gridPosition: Vector2(1, 0)),
        Building(id: 'd', type: BuildingType.wall, gridPosition: Vector2(1, 2)),
      ];
      final path = Pathfinding.findPath(
        const GridNode(5, 5),
        const GridNode(1, 1),
        buildings,
      );
      expect(path, isEmpty);
    });
  });
}

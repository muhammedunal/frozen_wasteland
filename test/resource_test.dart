import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frozen_wasteland/models/resource.dart';
import 'package:frozen_wasteland/models/building.dart';
import 'package:frozen_wasteland/models/game_state.dart';
import 'package:frozen_wasteland/providers/resource_provider.dart';

void main() {
  group('Resources model', () {
    test('starts with sensible defaults', () {
      final r = Resources();
      expect(r.food, 100);
      expect(r.population, 0);
      expect(r.maxPopulation, 10);
      expect(r.happiness, 50);
      expect(r.coin, 0);
    });

    test('consume clamps at zero', () {
      final r = Resources(wood: 5);
      r.consume(ResourceType.wood, 10);
      expect(r.wood, 0);
    });

    test('produce respects food cap', () {
      final r = Resources(food: 190, maxFood: 200);
      r.produce(ResourceType.food, 50);
      expect(r.food, 200);
    });

    test('canAfford / spend', () {
      final r = Resources(wood: 20, stone: 10);
      const cost = {ResourceType.wood: 20, ResourceType.stone: 10};
      expect(r.canAfford(cost), isTrue);
      expect(r.spend(cost), isTrue);
      expect(r.wood, 0);
      expect(r.stone, 0);
      expect(r.canAfford(cost), isFalse);
    });

    test('population and happiness are bounded', () {
      final r = Resources(maxPopulation: 3);
      r.addPopulation(10);
      expect(r.population, 3);
      r.adjustHappiness(100);
      expect(r.happiness, 100);
      r.adjustHappiness(-1000);
      expect(r.happiness, 0);
    });

    test('round-trips through JSON', () {
      final r = Resources(
          food: 42, wood: 7, stone: 3, coin: 9, population: 2, happiness: 77);
      final restored = Resources.fromJson(r.toJson());
      expect(restored.food, 42);
      expect(restored.coin, 9);
      expect(restored.population, 2);
      expect(restored.happiness, 77);
    });
  });

  group('ResourceNotifier (Riverpod)', () {
    test('produce / consume notify new state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(resourceProvider.notifier);
      final before = container.read(resourceProvider).wood;

      notifier.produce(ResourceType.wood, 15);
      expect(container.read(resourceProvider).wood, before + 15);

      notifier.consume(ResourceType.wood, 5);
      expect(container.read(resourceProvider).wood, before + 10);
    });

    test('spend fails when unaffordable and succeeds when affordable', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(resourceProvider.notifier);

      final tooMuch = {ResourceType.coin: 99999};
      expect(notifier.spend(tooMuch), isFalse);

      notifier.produce(ResourceType.coin, 100);
      expect(notifier.spend({ResourceType.coin: 40}), isTrue);
      expect(container.read(resourceProvider).coin, 60);
    });

    test('resourcesProvider mirrors the notifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(resourceProvider.notifier).produce(ResourceType.food, 10);
      final mirrored = container.read(resourcesProvider);
      // Food respects cap (default 200); 100 + 10 = 110.
      expect(mirrored.food, 110);
    });
  });

  group('GameState serialization', () {
    test('toJson / fromJson preserves resources and buildings', () {
      final state = GameState.initial(
        startingResources: Resources(food: 80, wood: 12),
      ).copyWith(
        buildings: [
          Building(
            id: 'b1',
            type: BuildingType.house,
            gridPosition: Vector2(2, 3),
          ),
        ],
      );

      final restored = GameState.fromJson(state.toJson());
      expect(restored.resources.food, 80);
      expect(restored.resources.wood, 12);
      expect(restored.buildings.length, 1);
      expect(restored.buildings.first.type, BuildingType.house);
      expect(restored.buildings.first.col, 2);
      expect(restored.buildings.first.row, 3);
    });
  });
}

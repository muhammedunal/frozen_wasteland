import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frozen_wasteland/models/building.dart';
import 'package:frozen_wasteland/models/resource.dart';
import 'package:frozen_wasteland/providers/building_provider.dart';
import 'package:frozen_wasteland/providers/game_state_provider.dart';
import 'package:frozen_wasteland/screens/game_screen.dart';

void main() {
  group('ResourceHUD', () {
    testWidgets('renders live values from gameStateProvider', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Seed the game state with known resources.
      container.read(gameStateProvider.notifier).syncResources(
            Resources(food: 123, maxFood: 200, population: 4, happiness: 88),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: ResourceHUD()),
          ),
        ),
      );

      expect(find.textContaining('Food: 123/200'), findsOneWidget);
      expect(find.textContaining('Population: 4/10'), findsOneWidget);
      expect(find.textContaining('Happiness: 88%'), findsOneWidget);
    });
  });

  group('BuildingSelector', () {
    testWidgets('lists all building types with cost', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: BuildingSelector())),
        ),
      );

      // All six building types are shown.
      for (final type in BuildingType.values) {
        expect(find.text(type.displayName), findsOneWidget);
      }
      // House cost is rendered.
      expect(find.textContaining('20 Wood'), findsWidgets);
    });

    testWidgets('tapping a building selects it and enables placement mode',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: BuildingSelector()),
          ),
        ),
      );

      await tester.tap(find.text('Barn'));
      await tester.pump();

      expect(container.read(selectedBuildingProvider), BuildingType.barn);
      expect(container.read(placementModeProvider), isTrue);
    });
  });

  group('cost formatting', () {
    test('formats a multi-resource cost', () {
      final text = BuildingSelector.formatCost(
        {ResourceType.wood: 20, ResourceType.stone: 10},
      );
      expect(text, '20 Wood, 10 Stone');
    });

    test('formats an empty cost as Free', () {
      expect(BuildingSelector.formatCost(const {}), 'Free');
    });
  });
}

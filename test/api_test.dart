import 'dart:io';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frozen_wasteland/models/building.dart';
import 'package:frozen_wasteland/models/game_state.dart';
import 'package:frozen_wasteland/models/resource.dart';
import 'package:frozen_wasteland/providers/api_provider.dart';
import 'package:frozen_wasteland/services/api_service.dart';
import 'package:frozen_wasteland/services/mock_api_service.dart';
import 'package:frozen_wasteland/services/retry.dart';

GameState _sampleState() => GameState.initial(
      startingResources: Resources(food: 77, wood: 11, coin: 5),
    ).copyWith(
      buildings: [
        Building(
          id: 'b1',
          type: BuildingType.house,
          gridPosition: Vector2(3, 4),
          level: 2,
        ),
      ],
    );

void main() {
  group('MockApiService save / load', () {
    test('round-trips a GameState in memory', () async {
      final api = MockApiService();
      final state = _sampleState();

      await api.saveGame('u1', state);
      expect(api.hasSave('u1'), isTrue);

      final loaded = await api.loadGame('u1');
      expect(loaded.resources.food, 77);
      expect(loaded.resources.coin, 5);
      expect(loaded.buildings.length, 1);
      expect(loaded.buildings.first.type, BuildingType.house);
      expect(loaded.buildings.first.level, 2);
    });

    test('loading a missing user throws notFound', () async {
      final api = MockApiService();
      expect(
        () => api.loadGame('ghost'),
        throwsA(isA<ApiException>().having(
            (e) => e.kind, 'kind', ApiErrorKind.notFound)),
      );
    });

    test('persists to a local JSON file when provided', () async {
      final file = File(
          '${Directory.systemTemp.path}/fw_save_${DateTime.now().microsecondsSinceEpoch}.json');
      addTearDown(() {
        if (file.existsSync()) file.deleteSync();
      });

      final api1 = MockApiService(storageFile: file);
      await api1.saveGame('u1', _sampleState());
      expect(file.existsSync(), isTrue);

      // A fresh instance should read the persisted save back.
      final api2 = MockApiService(storageFile: file);
      final loaded = await api2.loadGame('u1');
      expect(loaded.resources.food, 77);
    });

    test('fetchLeaderboard returns entries', () async {
      final api = MockApiService();
      final lb = await api.fetchLeaderboard();
      expect(lb, isNotEmpty);
      expect(lb.first.level, 5);
    });
  });

  group('retry helper', () {
    test('retries transient failures then succeeds', () async {
      var calls = 0;
      final result = await retry<String>(
        () async {
          calls++;
          if (calls < 3) throw const ApiException('boom');
          return 'ok';
        },
        maxAttempts: 3,
        baseDelay: Duration.zero,
      );
      expect(result, 'ok');
      expect(calls, 3);
    });

    test('gives up after maxAttempts', () async {
      var calls = 0;
      await expectLater(
        retry<void>(
          () async {
            calls++;
            throw const ApiException('always fails');
          },
          maxAttempts: 3,
          baseDelay: Duration.zero,
        ),
        throwsA(isA<ApiException>()),
      );
      expect(calls, 3);
    });

    test('does not retry when retryIf is false', () async {
      var calls = 0;
      await expectLater(
        retry<void>(
          () async {
            calls++;
            throw StateError('fatal');
          },
          maxAttempts: 3,
          retryIf: (e) => e is ApiException,
          baseDelay: Duration.zero,
        ),
        throwsA(isA<StateError>()),
      );
      expect(calls, 1);
    });
  });

  group('api providers', () {
    test('apiServiceProvider yields the mock when useMockApi is true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(apiServiceProvider), isA<MockApiService>());
    });

    test('saveGameProvider + loadGameProvider via overridden mock', () async {
      final mock = MockApiService();
      final container = ProviderContainer(overrides: [
        apiServiceProvider.overrideWithValue(mock),
      ]);
      addTearDown(container.dispose);

      // saveGameProvider serializes the current gameStateProvider (defaults).
      await container.read(saveGameProvider.future);
      expect(mock.hasSave('local-player'), isTrue);

      final loaded = await container.read(loadGameProvider.future);
      expect(loaded, isA<GameState>());
    });
  });
}

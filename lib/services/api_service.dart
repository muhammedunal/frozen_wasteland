import 'dart:async';

import 'package:dio/dio.dart';

import '../models/building.dart';
import '../models/game_state.dart';
import 'retry.dart';

/// Abstraction over the backend so the app can swap between the real
/// [ApiService] (Dio) and a [MockApiService] for tests / offline play.
abstract class GameApi {
  Future<void> saveGame(String userId, GameState state);
  Future<GameState> loadGame(String userId);
  Future<List<Building>> fetchLeaderboard();
}

/// Normalized error type surfaced to the UI / providers.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorKind kind;
  final Object? cause;

  const ApiException(
    this.message, {
    this.statusCode,
    this.kind = ApiErrorKind.unknown,
    this.cause,
  });

  @override
  String toString() => 'ApiException($kind, code: $statusCode): $message';
}

enum ApiErrorKind { network, timeout, parsing, server, notFound, unknown }

/// Real backend client backed by Dio.
///
/// Features:
///  * 30s connect/receive timeouts.
///  * Up to 3 retries with exponential backoff for transient failures
///    (network + timeout + 5xx).
///  * JSON parsing guarded so malformed payloads become [ApiException]s.
class ApiService implements GameApi {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: timeout,
              receiveTimeout: timeout,
              sendTimeout: timeout,
              headers: {'Content-Type': 'application/json'},
            ));

  // --- Public API ----------------------------------------------------------
  @override
  Future<void> saveGame(String userId, GameState state) async {
    await _withRetry(() async {
      final res = await _dio.post(
        '/game/save',
        data: {
          'userId': userId,
          'state': state.toJson(),
        },
      );
      _ensureSuccess(res);
    });
  }

  @override
  Future<GameState> loadGame(String userId) async {
    return _withRetry(() async {
      final res = await _dio.get('/game/load', queryParameters: {
        'userId': userId,
      });
      _ensureSuccess(res);
      return _parse(() {
        final data = res.data as Map;
        final stateJson =
            Map<String, dynamic>.from((data['state'] ?? data) as Map);
        return GameState.fromJson(stateJson);
      });
    });
  }

  @override
  Future<List<Building>> fetchLeaderboard() async {
    return _withRetry(() async {
      final res = await _dio.get('/leaderboard');
      _ensureSuccess(res);
      return _parse(() {
        final list = (res.data as Map)['entries'] as List? ??
            (res.data as List?) ??
            const [];
        return list
            .map((e) => Building.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      });
    });
  }

  // --- Internals -----------------------------------------------------------
  void _ensureSuccess(Response res) {
    final code = res.statusCode ?? 0;
    if (code == 404) {
      throw ApiException('Resource not found',
          statusCode: code, kind: ApiErrorKind.notFound);
    }
    if (code < 200 || code >= 300) {
      throw ApiException('Server error',
          statusCode: code, kind: ApiErrorKind.server);
    }
  }

  T _parse<T>(T Function() body) {
    try {
      return body();
    } catch (e) {
      throw ApiException('Failed to parse response',
          kind: ApiErrorKind.parsing, cause: e);
    }
  }

  /// Runs [action], normalizing Dio errors and retrying transient failures
  /// (network / timeout / 5xx) up to [maxRetries] times with backoff.
  Future<T> _withRetry<T>(Future<T> Function() action) {
    return retry<T>(
      () async {
        try {
          return await action();
        } on DioException catch (e) {
          throw _mapDioError(e);
        }
      },
      maxAttempts: maxRetries,
      retryIf: (e) =>
          e is ApiException &&
          (e.kind == ApiErrorKind.network ||
              e.kind == ApiErrorKind.timeout ||
              e.kind == ApiErrorKind.server),
    );
  }

  ApiException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Request timed out',
            kind: ApiErrorKind.timeout, cause: e);
      case DioExceptionType.connectionError:
        return ApiException('Network error',
            kind: ApiErrorKind.network, cause: e);
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        return ApiException('Bad response',
            statusCode: code,
            kind: code == 404 ? ApiErrorKind.notFound : ApiErrorKind.server,
            cause: e);
      default:
        return ApiException('Unexpected error',
            kind: ApiErrorKind.unknown, cause: e);
    }
  }
}

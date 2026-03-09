import 'package:alszik_a_varos/core/domain/enums/game_phase.dart';
import 'package:alszik_a_varos/core/domain/enums/winner_type.dart';
import 'package:alszik_a_varos/features/game/application/game_notifier.dart';
import 'package:alszik_a_varos/features/game/data/game_api_service.dart';
import 'package:alszik_a_varos/features/room/data/room_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGameApiService extends GameApiService {
  _FakeGameApiService({required this.snapshot}) : super(Dio());

  Map<String, dynamic> snapshot;
  bool throwOnGet = false;

  @override
  Future<Response<dynamic>> getGameState(String gameId) async {
    if (throwOnGet) {
      throw Exception('network error');
    }

    return Response<dynamic>(
      data: snapshot,
      statusCode: 200,
      requestOptions: RequestOptions(path: '/games/$gameId/state'),
    );
  }
}

class _FakeRoomApiService extends RoomApiService {
  _FakeRoomApiService() : super(Dio());

  bool restartCalled = false;
  bool throwOnRestart = false;

  @override
  Future<Response<dynamic>> restartRoom(String code) async {
    restartCalled = true;
    if (throwOnRestart) {
      throw Exception('restart failed');
    }

    return Response<dynamic>(
      data: {'ok': true},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/rooms/$code/restart'),
    );
  }
}

Map<String, dynamic> _snapshot({
  GamePhase phase = GamePhase.voteResult,
  WinnerType winner = WinnerType.none,
}) {
  return {
    'room': {
      'id': 'room-1',
      'code': 'ABCD12',
      'status': 'in_game',
      'hostPlayerId': 'p1',
    },
    'players': [
      {
        'id': 'p1',
        'roomId': 'room-1',
        'name': 'Anna',
        'isHost': true,
        'isAlive': true,
        'sessionToken': 't1',
        'isConnected': true,
      },
      {
        'id': 'p2',
        'roomId': 'room-1',
        'name': 'Bela',
        'isHost': false,
        'isAlive': false,
        'sessionToken': 't2',
        'isConnected': true,
      },
    ],
    'game': {
      'id': 'game-1',
      'roomId': 'room-1',
      'phase': _phaseToSnake(phase),
      'dayNumber': 2,
      'winner': _winnerToSnake(winner),
      'alivePlayerIds': ['p1'],
    },
    'currentPlayerId': 'p1',
    'currentPlayerRole': {
      'gameId': 'game-1',
      'playerId': 'p1',
      'role': 'villager',
    },
    'latestVoteResult': {
      'dayNumber': 2,
      'isTie': false,
      'eliminatedPlayerId': 'p2',
      'eliminatedPlayerName': 'Bela',
      'alivePlayerIds': ['p1'],
    },
    'finalRoles': [
      {
        'playerId': 'p1',
        'playerName': 'Anna',
        'role': 'villager',
        'isAlive': true,
      },
      {
        'playerId': 'p2',
        'playerName': 'Bela',
        'role': 'killer',
        'isAlive': false,
      },
    ],
  };
}

String _phaseToSnake(GamePhase phase) {
  switch (phase) {
    case GamePhase.lobby:
      return 'lobby';
    case GamePhase.roleReveal:
      return 'role_reveal';
    case GamePhase.nightKiller:
      return 'night_killer';
    case GamePhase.nightDoctor:
      return 'night_doctor';
    case GamePhase.nightResolve:
      return 'night_resolve';
    case GamePhase.dayReveal:
      return 'day_reveal';
    case GamePhase.discussion:
      return 'discussion';
    case GamePhase.voting:
      return 'voting';
    case GamePhase.voteResult:
      return 'vote_result';
    case GamePhase.ended:
      return 'ended';
  }
}

String _winnerToSnake(WinnerType winner) {
  switch (winner) {
    case WinnerType.villagers:
      return 'villagers';
    case WinnerType.killers:
      return 'killers';
    case WinnerType.none:
      return 'none';
  }
}

void main() {
  group('GameNotifier', () {
    test('refresh updates game state from api snapshot', () async {
      final gameApi = _FakeGameApiService(snapshot: _snapshot());
      final roomApi = _FakeRoomApiService();
      final notifier = GameNotifier(gameApi: gameApi, roomApi: roomApi);

      await notifier.initialize(gameId: 'game-1');

      expect(notifier.state.gameId, 'game-1');
      expect(notifier.state.roomCode, 'ABCD12');
      expect(notifier.state.dayNumber, 2);
      expect(notifier.state.phase, GamePhase.voteResult);
      expect(notifier.state.alivePlayers.length, 1);
      expect(notifier.state.alivePlayers.first.name, 'Anna');
      expect(notifier.state.error, '');
    });

    test('refresh stores recoverable error on api failure', () async {
      final gameApi = _FakeGameApiService(snapshot: _snapshot())
        ..throwOnGet = true;
      final roomApi = _FakeRoomApiService();
      final notifier = GameNotifier(gameApi: gameApi, roomApi: roomApi);

      await notifier.initialize(gameId: 'game-1');

      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNotEmpty);
    });

    test('restartGame calls room api and clears restarting flag', () async {
      final gameApi = _FakeGameApiService(snapshot: _snapshot());
      final roomApi = _FakeRoomApiService();
      final notifier = GameNotifier(gameApi: gameApi, roomApi: roomApi);

      await notifier.initialize(gameId: 'game-1');
      await notifier.restartGame();

      expect(roomApi.restartCalled, true);
      expect(notifier.state.isRestarting, false);
      expect(notifier.state.restartError, '');
    });

    test('restartGame stores error when restart fails', () async {
      final gameApi = _FakeGameApiService(snapshot: _snapshot());
      final roomApi = _FakeRoomApiService()..throwOnRestart = true;
      final notifier = GameNotifier(gameApi: gameApi, roomApi: roomApi);

      await notifier.initialize(gameId: 'game-1');
      await notifier.restartGame();

      expect(roomApi.restartCalled, true);
      expect(notifier.state.isRestarting, false);
      expect(notifier.state.restartError, isNotEmpty);
    });
  });
}

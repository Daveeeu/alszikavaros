import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../../core/domain/enums/game_phase.dart';
import '../../../core/domain/enums/role.dart';
import '../../../core/domain/enums/winner_type.dart';
import '../../../core/domain/enums/room_status.dart';
import '../../game/domain/game_rules_service.dart';
import '../../game/domain/services/rule_models.dart';

class MockBackendState {
  MockBackendState._();

  static final MockBackendState instance = MockBackendState._();

  final Map<String, _RoomData> _roomsByCode = <String, _RoomData>{};
  final Map<String, _GameData> _gamesById = <String, _GameData>{};
  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();

  final Random _random = Random();
  final GameRulesService _rules = GameRulesService();

  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  Response<dynamic> createRoom(String playerName) {
    final roomCode = _randomCode();
    final roomId = _nextId('room');
    final hostId = _nextId('p');

    final room = _RoomData(
      id: roomId,
      code: roomCode,
      hostPlayerId: hostId,
      status: RoomStatus.waiting,
      players: <_PlayerData>[
        _PlayerData(
          id: hostId,
          name: playerName,
          isHost: true,
          isAlive: true,
          isConnected: true,
          sessionToken: _nextId('t'),
        ),
      ],
    );

    _roomsByCode[roomCode] = room;
    _emit('room.updated', roomCode: roomCode, payload: _roomStatePayload(room));

    return _ok(_roomStatePayload(room));
  }

  Response<dynamic> joinRoom(String playerName, String roomCode) {
    final room = _roomsByCode[roomCode];
    if (room == null) {
      return _notFound('Room not found');
    }

    final player = _PlayerData(
      id: _nextId('p'),
      name: playerName,
      isHost: false,
      isAlive: true,
      isConnected: true,
      sessionToken: _nextId('t'),
    );

    room.players.add(player);
    _emit('room.player_joined', roomCode: roomCode, payload: _playerPayload(player));
    _emit('room.updated', roomCode: roomCode, payload: _roomStatePayload(room));

    return _ok(_roomStatePayload(room));
  }

  Response<dynamic> getRoomState(String roomCode) {
    final room = _roomsByCode[roomCode];
    if (room == null) {
      return _notFound('Room not found');
    }

    return _ok(_roomStatePayload(room));
  }

  Response<dynamic> leaveRoom(String roomCode, String? playerId) {
    final room = _roomsByCode[roomCode];
    if (room == null) {
      return _notFound('Room not found');
    }

    if (playerId != null) {
      room.players.removeWhere((player) => player.id == playerId);
      _emit('room.player_left', roomCode: roomCode, payload: {'playerId': playerId});

      if (room.players.isNotEmpty &&
          room.players.every((player) => player.id != room.hostPlayerId)) {
        room.players.first.isHost = true;
        room.hostPlayerId = room.players.first.id;
      }
    }

    _emit('room.updated', roomCode: roomCode, payload: _roomStatePayload(room));
    return _ok(_roomStatePayload(room));
  }

  Response<dynamic> startGame(String roomCode) {
    final room = _roomsByCode[roomCode];
    if (room == null) {
      return _notFound('Room not found');
    }

    if (room.players.isEmpty) {
      return _badRequest('Cannot start game without players.');
    }

    room.status = RoomStatus.inGame;

    final gameId = _nextId('game');
    final playerIds = room.players.map((player) => player.id).toList(growable: false);

    Map<String, Role> assignments;
    if (playerIds.length == 6) {
      assignments = _rules.distributeRolesForSixPlayers(playerIds).assignments;
    } else {
      assignments = _fallbackRoleDistribution(playerIds);
    }

    final game = _GameData(
      id: gameId,
      roomCode: roomCode,
      roomId: room.id,
      dayNumber: 1,
      phase: GamePhase.roleReveal,
      winner: WinnerType.none,
      roleByPlayerId: assignments,
      alivePlayerIds: playerIds.toSet(),
      currentVoteTargets: <String, String>{},
      currentKillerTargets: <String, String>{},
    );

    _gamesById[gameId] = game;

    _emit('game.started', roomCode: roomCode, payload: {'gameId': gameId});
    _emit('game.phase_changed', roomCode: roomCode, payload: {
      'gameId': gameId,
      'phase': 'role_reveal',
    });

    return _ok({'gameId': gameId, 'roomCode': roomCode});
  }

  Response<dynamic> restartRoom(String roomCode) {
    final room = _roomsByCode[roomCode];
    if (room == null) {
      return _notFound('Room not found');
    }

    room.status = RoomStatus.waiting;

    final gameEntries = _gamesById.entries
        .where((entry) => entry.value.roomCode == roomCode)
        .toList(growable: false);
    for (final entry in gameEntries) {
      _gamesById.remove(entry.key);
    }

    _emit('room.updated', roomCode: roomCode, payload: _roomStatePayload(room));
    return _ok(_roomStatePayload(room));
  }

  Response<dynamic> getGameState(String gameId) {
    final game = _gamesById[gameId];
    if (game == null) {
      return _notFound('Game not found');
    }

    _maybeAutoAdvance(game);
    return _ok(_gameSnapshotPayload(game));
  }

  Response<dynamic> revealRole(String gameId, Map<String, dynamic> payload) {
    final game = _gamesById[gameId];
    if (game == null) {
      return _notFound('Game not found');
    }

    if (game.phase == GamePhase.roleReveal) {
      _setPhase(game, GamePhase.nightKiller);
    }

    final playerId = payload['playerId'] as String?;
    return _ok({
      'phase': _phaseToSnake(game.phase),
      'role': game.roleByPlayerId[playerId ?? '']?.name,
    });
  }

  Response<dynamic> submitNightAction(String gameId, Map<String, dynamic> payload) {
    final game = _gamesById[gameId];
    if (game == null) {
      return _notFound('Game not found');
    }

    final playerId = payload['playerId'] as String?;
    final targetId = payload['targetPlayerId'] as String?;
    if (playerId == null || targetId == null) {
      return _badRequest('Missing playerId or targetPlayerId.');
    }

    final role = game.roleByPlayerId[playerId];
    if (role == null) {
      return _badRequest('Unknown player role.');
    }

    if (game.phase == GamePhase.nightKiller && role == Role.killer) {
      game.currentKillerTargets[playerId] = targetId;
      final aliveKillers = game.alivePlayerIds
          .where((id) => game.roleByPlayerId[id] == Role.killer)
          .length;

      if (game.currentKillerTargets.length >= aliveKillers) {
        _setPhase(game, GamePhase.nightDoctor);
      }

      return _ok({'accepted': true});
    }

    if (game.phase == GamePhase.nightDoctor && role == Role.doctor) {
      game.doctorSavedTargetId = targetId;
      _resolveNight(game);
      _setPhase(game, GamePhase.dayReveal);
      return _ok({'accepted': true});
    }

    return _badRequest('Action not allowed in this phase.');
  }

  Response<dynamic> submitVote(String gameId, Map<String, dynamic> payload) {
    final game = _gamesById[gameId];
    if (game == null) {
      return _notFound('Game not found');
    }

    final voterId = payload['voterPlayerId'] as String?;
    final targetId = payload['targetPlayerId'] as String?;
    if (voterId == null || targetId == null) {
      return _badRequest('Missing voterPlayerId or targetPlayerId.');
    }

    game.currentVoteTargets[voterId] = targetId;

    final aliveCount = game.alivePlayerIds.length;
    if (game.currentVoteTargets.length >= aliveCount) {
      _resolveVotes(game);
      _setPhase(game, GamePhase.voteResult);
    }

    return _ok({'accepted': true});
  }

  void _resolveNight(_GameData game) {
    final result = _rules.resolveNight(
      killerTargets: game.currentKillerTargets.values.toList(growable: false),
      doctorSavedPlayerId: game.doctorSavedTargetId,
    );

    game.currentKillerTargets.clear();
    game.doctorSavedTargetId = null;

    if (result.eliminatedPlayerId != null) {
      game.alivePlayerIds.remove(result.eliminatedPlayerId);
      _markPlayerAlive(game.roomCode, result.eliminatedPlayerId!, false);
    }

    game.lastNightEliminatedPlayerId = result.eliminatedPlayerId;
    _checkWin(game);
  }

  void _resolveVotes(_GameData game) {
    final result = _rules.resolveVotes(
      voteTargets: game.currentVoteTargets.values.toList(growable: false),
    );

    game.currentVoteTargets.clear();

    if (result.eliminatedPlayerId != null) {
      game.alivePlayerIds.remove(result.eliminatedPlayerId);
      _markPlayerAlive(game.roomCode, result.eliminatedPlayerId!, false);
    }

    game.latestVoteResult = {
      'dayNumber': game.dayNumber,
      'isTie': result.isTie,
      'eliminatedPlayerId': result.eliminatedPlayerId,
      'eliminatedPlayerName': _playerNameById(game.roomCode, result.eliminatedPlayerId),
      'alivePlayerIds': game.alivePlayerIds.toList(growable: false),
    };

    _checkWin(game);
  }

  void _checkWin(_GameData game) {
    final statuses = game.roleByPlayerId.entries
        .map(
          (entry) => PlayerRoleStatus(
            playerId: entry.key,
            role: entry.value,
            isAlive: game.alivePlayerIds.contains(entry.key),
          ),
        )
        .toList(growable: false);

    final result = _rules.checkWinCondition(statuses);
    if (result.isGameEnded) {
      game.winner = result.winner;
      _setPhase(game, GamePhase.ended);
      _emit('game.ended', roomCode: game.roomCode, payload: {
        'gameId': game.id,
        'winner': _winnerToSnake(game.winner),
      });
    }
  }

  void _maybeAutoAdvance(_GameData game) {
    final elapsed = DateTime.now().difference(game.phaseChangedAt);

    if (game.phase == GamePhase.dayReveal && elapsed.inSeconds >= 5) {
      _setPhase(game, GamePhase.discussion);
      _emit('game.day_started', roomCode: game.roomCode, payload: {'gameId': game.id});
      return;
    }

    if (game.phase == GamePhase.discussion && elapsed.inSeconds >= 10) {
      _setPhase(game, GamePhase.voting);
      _emit('game.vote_started', roomCode: game.roomCode, payload: {'gameId': game.id});
      return;
    }

    if (game.phase == GamePhase.voteResult && elapsed.inSeconds >= 5) {
      if (game.winner == WinnerType.none) {
        game.dayNumber += 1;
        _setPhase(game, GamePhase.nightKiller);
      }
    }
  }

  void _setPhase(_GameData game, GamePhase phase) {
    game.phase = phase;
    game.phaseChangedAt = DateTime.now();

    _emit('game.phase_changed', roomCode: game.roomCode, payload: {
      'gameId': game.id,
      'phase': _phaseToSnake(phase),
    });
  }

  void _markPlayerAlive(String roomCode, String playerId, bool isAlive) {
    final room = _roomsByCode[roomCode];
    if (room == null) return;

    for (final player in room.players) {
      if (player.id == playerId) {
        player.isAlive = isAlive;
        break;
      }
    }
  }

  String? _playerNameById(String roomCode, String? playerId) {
    if (playerId == null) return null;
    final room = _roomsByCode[roomCode];
    if (room == null) return null;

    for (final player in room.players) {
      if (player.id == playerId) {
        return player.name;
      }
    }

    return null;
  }

  Map<String, Role> _fallbackRoleDistribution(List<String> playerIds) {
    final assignments = <String, Role>{};
    for (var i = 0; i < playerIds.length; i++) {
      if (i < 2) {
        assignments[playerIds[i]] = Role.killer;
      } else if (i == 2) {
        assignments[playerIds[i]] = Role.doctor;
      } else {
        assignments[playerIds[i]] = Role.villager;
      }
    }
    return assignments;
  }

  Map<String, dynamic> _roomStatePayload(_RoomData room) {
    return {
      'id': room.id,
      'code': room.code,
      'status': _roomStatusToSnake(room.status),
      'hostPlayerId': room.hostPlayerId,
      'players': room.players.map(_playerPayload).toList(growable: false),
    };
  }

  Map<String, dynamic> _gameSnapshotPayload(_GameData game) {
    final room = _roomsByCode[game.roomCode]!;
    final currentPlayerId = room.hostPlayerId;

    return {
      'room': _roomStatePayload(room),
      'players': room.players
          .map((player) => {
                'id': player.id,
                'roomId': room.id,
                'name': player.name,
                'isHost': player.isHost,
                'isAlive': player.isAlive,
                'sessionToken': player.sessionToken,
                'isConnected': player.isConnected,
              })
          .toList(growable: false),
      'game': {
        'id': game.id,
        'roomId': game.roomId,
        'phase': _phaseToSnake(game.phase),
        'dayNumber': game.dayNumber,
        'winner': _winnerToSnake(game.winner),
        'alivePlayerIds': game.alivePlayerIds.toList(growable: false),
      },
      'currentPlayerId': currentPlayerId,
      'currentPlayerRole': {
        'gameId': game.id,
        'playerId': currentPlayerId,
        'role': game.roleByPlayerId[currentPlayerId]!.name,
      },
      'latestVoteResult': game.latestVoteResult,
      'finalRoles': room.players
          .map((player) => {
                'playerId': player.id,
                'playerName': player.name,
                'role': game.roleByPlayerId[player.id]!.name,
                'isAlive': game.alivePlayerIds.contains(player.id),
              })
          .toList(growable: false),
    };
  }

  Map<String, dynamic> _playerPayload(_PlayerData player) {
    return {
      'id': player.id,
      'name': player.name,
      'isHost': player.isHost,
      'isAlive': player.isAlive,
      'isConnected': player.isConnected,
    };
  }

  void _emit(
    String eventName, {
    required String roomCode,
    required Map<String, dynamic> payload,
  }) {
    _eventsController.add({
      'event': eventName,
      'roomCode': roomCode,
      'payload': payload,
    });
  }

  Response<dynamic> _ok(dynamic data) {
    return Response<dynamic>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: '/mock'),
    );
  }

  Response<dynamic> _notFound(String message) {
    return Response<dynamic>(
      data: {'error': message},
      statusCode: 404,
      requestOptions: RequestOptions(path: '/mock'),
    );
  }

  Response<dynamic> _badRequest(String message) {
    return Response<dynamic>(
      data: {'error': message},
      statusCode: 400,
      requestOptions: RequestOptions(path: '/mock'),
    );
  }

  String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  String _nextId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(999)}';
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

  String _roomStatusToSnake(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return 'waiting';
      case RoomStatus.inGame:
        return 'in_game';
      case RoomStatus.finished:
        return 'finished';
    }
  }
}

class _RoomData {
  _RoomData({
    required this.id,
    required this.code,
    required this.hostPlayerId,
    required this.status,
    required this.players,
  });

  final String id;
  final String code;
  String hostPlayerId;
  RoomStatus status;
  final List<_PlayerData> players;
}

class _PlayerData {
  _PlayerData({
    required this.id,
    required this.name,
    required this.isHost,
    required this.isAlive,
    required this.isConnected,
    required this.sessionToken,
  });

  final String id;
  final String name;
  bool isHost;
  bool isAlive;
  bool isConnected;
  final String sessionToken;
}

class _GameData {
  _GameData({
    required this.id,
    required this.roomCode,
    required this.roomId,
    required this.dayNumber,
    required this.phase,
    required this.winner,
    required this.roleByPlayerId,
    required this.alivePlayerIds,
    required this.currentVoteTargets,
    required this.currentKillerTargets,
  }) : phaseChangedAt = DateTime.now();

  final String id;
  final String roomCode;
  final String roomId;
  int dayNumber;
  GamePhase phase;
  WinnerType winner;
  DateTime phaseChangedAt;

  final Map<String, Role> roleByPlayerId;
  final Set<String> alivePlayerIds;

  final Map<String, String> currentVoteTargets;
  final Map<String, String> currentKillerTargets;

  String? doctorSavedTargetId;
  String? lastNightEliminatedPlayerId;
  Map<String, dynamic>? latestVoteResult;
}

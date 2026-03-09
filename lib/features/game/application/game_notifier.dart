import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/domain/enums/game_phase.dart';
import '../../../core/domain/enums/winner_type.dart';
import '../../../core/network/app_dio_client.dart';
import '../../room/data/room_api_provider.dart';
import '../../room/data/room_api_service.dart';
import '../../room/domain/models/player.dart';
import '../data/game_api_service.dart';
import '../data/mock/mock_game_api_service.dart';
import '../domain/models/final_role_entry.dart';
import '../domain/models/game_snapshot.dart';
import '../domain/models/latest_vote_result.dart';

final gameApiServiceProvider = Provider<GameApiService>((ref) {
  if (AppConstants.useMockBackend) {
    return MockGameApiService();
  }

  return GameApiService(AppDioClient().dio);
});

final gameNotifierProvider =
    StateNotifierProvider.autoDispose<GameNotifier, GameState>(
  (ref) => GameNotifier(
    gameApi: ref.watch(gameApiServiceProvider),
    roomApi: ref.watch(roomApiServiceProvider),
  ),
);

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier({
    required GameApiService gameApi,
    required RoomApiService roomApi,
  })  : _gameApi = gameApi,
        _roomApi = roomApi,
        super(const GameState());

  final GameApiService _gameApi;
  final RoomApiService _roomApi;
  Timer? _pollingTimer;

  Future<void> initialize({required String gameId}) async {
    if (state.gameId == gameId && state.initialized) {
      return;
    }

    state = state.copyWith(gameId: gameId, initialized: true);
    await refresh();
  }

  void startPolling({Duration interval = const Duration(seconds: 3)}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) => refresh());
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> refresh() async {
    final gameId = state.gameId;
    if (gameId == null || gameId.isEmpty) return;

    state = state.copyWith(isLoading: true, error: '');

    try {
      final response = await _gameApi.getGameState(gameId);
      final payload = response.data;

      if (payload is! Map<String, dynamic>) {
        state = state.copyWith(
          isLoading: false,
          error: 'Érvénytelen játékállapot érkezett.',
        );
        return;
      }

      final snapshot = GameSnapshot.fromJson(payload);
      state = state.copyWith(
        isLoading: false,
        roomId: snapshot.room.id,
        roomCode: snapshot.room.code,
        phase: snapshot.game.phase,
        dayNumber: snapshot.game.dayNumber,
        winner: snapshot.game.winner,
        alivePlayers: snapshot.players.where((player) => player.isAlive).toList(),
        latestVoteResult: snapshot.latestVoteResult,
        finalRoles: snapshot.finalRoles,
        error: '',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Nem sikerült frissíteni a játékállapotot.',
      );
    }
  }

  Future<void> restartGame() async {
    if (state.isRestarting) return;

    final roomCode = state.roomCode;
    if (roomCode == null || roomCode.isEmpty) {
      state = state.copyWith(restartError: 'Hiányzó szobakód, nem indítható újra.');
      return;
    }

    state = state.copyWith(isRestarting: true, restartError: '');

    try {
      await _roomApi.restartRoom(roomCode);
      state = state.copyWith(isRestarting: false);
      await refresh();
    } catch (_) {
      state = state.copyWith(
        isRestarting: false,
        restartError: 'Nem sikerült újraindítani a játékot.',
      );
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

class GameState {
  const GameState({
    this.gameId,
    this.roomId,
    this.roomCode,
    this.phase,
    this.dayNumber = 1,
    this.winner = WinnerType.none,
    this.alivePlayers = const <Player>[],
    this.latestVoteResult,
    this.finalRoles = const <FinalRoleEntry>[],
    this.isLoading = false,
    this.error = '',
    this.initialized = false,
    this.isRestarting = false,
    this.restartError = '',
  });

  static const Object _noUpdate = Object();

  final String? gameId;
  final String? roomId;
  final String? roomCode;
  final GamePhase? phase;
  final int dayNumber;
  final WinnerType winner;
  final List<Player> alivePlayers;
  final LatestVoteResult? latestVoteResult;
  final List<FinalRoleEntry> finalRoles;
  final bool isLoading;
  final String error;
  final bool initialized;
  final bool isRestarting;
  final String restartError;

  GameState copyWith({
    String? gameId,
    String? roomId,
    String? roomCode,
    GamePhase? phase,
    int? dayNumber,
    WinnerType? winner,
    List<Player>? alivePlayers,
    Object? latestVoteResult = _noUpdate,
    List<FinalRoleEntry>? finalRoles,
    bool? isLoading,
    String? error,
    bool? initialized,
    bool? isRestarting,
    String? restartError,
  }) {
    return GameState(
      gameId: gameId ?? this.gameId,
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      phase: phase ?? this.phase,
      dayNumber: dayNumber ?? this.dayNumber,
      winner: winner ?? this.winner,
      alivePlayers: alivePlayers ?? this.alivePlayers,
      latestVoteResult: identical(latestVoteResult, _noUpdate)
          ? this.latestVoteResult
          : latestVoteResult as LatestVoteResult?,
      finalRoles: finalRoles ?? this.finalRoles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      initialized: initialized ?? this.initialized,
      isRestarting: isRestarting ?? this.isRestarting,
      restartError: restartError ?? this.restartError,
    );
  }
}

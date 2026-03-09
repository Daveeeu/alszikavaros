import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/route_paths.dart';
import '../../session/application/session_notifier.dart';
import '../data/room_api_provider.dart';
import 'room_notifier.dart';

final roomEntryControllerProvider =
    StateNotifierProvider<RoomEntryController, RoomEntryState>(
  (ref) => RoomEntryController(ref),
);

class RoomEntryController extends StateNotifier<RoomEntryState> {
  RoomEntryController(this._ref) : super(const RoomEntryState());

  final Ref _ref;

  void updatePlayerName(String value) {
    state = state.copyWith(playerName: value.trim(), errorMessage: '');
  }

  void updateRoomCode(String value) {
    state = state.copyWith(
      roomCode: value.trim().toUpperCase(),
      errorMessage: '',
    );
  }

  Future<String?> createRoom() async {
    if (!_isNameValid) {
      state = state.copyWith(errorMessage: 'Adj meg egy játékosnevet.');
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: '');

    try {
      final response = await _ref.read(roomApiServiceProvider).createRoom({
        'playerName': state.playerName,
      });

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Érvénytelen szerverválasz.',
        );
        return null;
      }

      final roomCode = (data['code'] as String?) ?? '';
      final players = (data['players'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);

      final hostPlayer = players.cast<Map<String, dynamic>>().firstWhere(
            (player) => player['isHost'] == true,
            orElse: () => <String, dynamic>{},
          );

      final playerId = (hostPlayer['id'] as String?) ?? _nextId('p');
      final token = _nextId('t');

      await _ref.read(sessionNotifierProvider.notifier).setPlayer(
            playerId: playerId,
            playerName: state.playerName,
            sessionToken: token,
          );

      _ref
          .read(roomNotifierProvider.notifier)
          .setCurrentRoom(roomCode: roomCode, isHost: true);

      state = state.copyWith(
        isSubmitting: false,
        roomCode: roomCode,
      );

      return RoutePaths.lobbyByCode(roomCode);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Nem sikerült létrehozni a szobát.',
      );
      return null;
    }
  }

  Future<String?> joinRoom() async {
    if (!_isNameValid) {
      state = state.copyWith(errorMessage: 'Adj meg egy játékosnevet.');
      return null;
    }

    if (state.roomCode.length < 4) {
      state = state.copyWith(errorMessage: 'A szobakód túl rövid.');
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: '');

    try {
      final response = await _ref.read(roomApiServiceProvider).joinRoom({
        'playerName': state.playerName,
        'roomCode': state.roomCode,
      });

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Érvénytelen szerverválasz.',
        );
        return null;
      }

      final roomCode = (data['code'] as String?) ?? state.roomCode;
      final players = (data['players'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);

      final joinedPlayer = players.cast<Map<String, dynamic>>().lastWhere(
            (player) => player['name'] == state.playerName,
            orElse: () => <String, dynamic>{},
          );

      final playerId = (joinedPlayer['id'] as String?) ?? _nextId('p');
      final token = _nextId('t');

      await _ref.read(sessionNotifierProvider.notifier).setPlayer(
            playerId: playerId,
            playerName: state.playerName,
            sessionToken: token,
          );

      _ref
          .read(roomNotifierProvider.notifier)
          .setCurrentRoom(roomCode: roomCode, isHost: false);

      state = state.copyWith(isSubmitting: false, roomCode: roomCode);
      return RoutePaths.lobbyByCode(roomCode);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Nem sikerült csatlakozni a szobához.',
      );
      return null;
    }
  }

  bool get _isNameValid => state.playerName.trim().length >= 2;

  String _nextId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}

class RoomEntryState {
  const RoomEntryState({
    this.playerName = '',
    this.roomCode = '',
    this.isSubmitting = false,
    this.errorMessage = '',
  });

  final String playerName;
  final String roomCode;
  final bool isSubmitting;
  final String errorMessage;

  RoomEntryState copyWith({
    String? playerName,
    String? roomCode,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return RoomEntryState(
      playerName: playerName ?? this.playerName,
      roomCode: roomCode ?? this.roomCode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

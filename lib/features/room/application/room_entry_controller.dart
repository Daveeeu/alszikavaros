import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
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
    _debug('createRoom:start name=${state.playerName}');

    try {
      final response = await _ref.read(roomApiServiceProvider).createRoom({
        'playerName': state.playerName,
      });

      final payload = _extractPayload(response.data);
      _debug('createRoom:rawResponse=${response.data}');
      if (payload == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Érvénytelen szerverválasz.',
        );
        return null;
      }

      final roomData = _extractRoomMap(payload);
      final roomCode = _extractRoomCode(payload, roomData);
      final players = (roomData['players'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);

      final hostPlayer = players.cast<Map<String, dynamic>>().firstWhere(
            (player) => player['isHost'] == true,
            orElse: () => <String, dynamic>{},
          );

      final playerId = (payload['playerId'] as String?) ??
          (hostPlayer['id'] as String?) ??
          _nextId('p');
      final token = (payload['sessionToken'] as String?) ?? _nextId('t');

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
      _debug('createRoom:success roomCode=$roomCode playerId=$playerId');

      return RoutePaths.lobbyByCode(roomCode);
    } on DioException catch (error) {
      final message =
          _extractDioError(error) ?? 'Nem sikerült létrehozni a szobát.';
      _debug('createRoom:dioError=$message details=${error.response?.data}');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message,
      );
      return null;
    } catch (error, stackTrace) {
      _debug('createRoom:error=$error\n$stackTrace');
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
    _debug(
        'joinRoom:start name=${state.playerName} roomCode=${state.roomCode}');

    try {
      final response = await _ref.read(roomApiServiceProvider).joinRoom({
        'playerName': state.playerName,
        'roomCode': state.roomCode,
      });

      final payload = _extractPayload(response.data);
      _debug('joinRoom:rawResponse=${response.data}');
      if (payload == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Érvénytelen szerverválasz.',
        );
        return null;
      }

      final roomData = _extractRoomMap(payload);
      final roomCode =
          _extractRoomCode(payload, roomData, fallback: state.roomCode);
      final players = (roomData['players'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);

      final joinedPlayer = players.cast<Map<String, dynamic>>().lastWhere(
            (player) => player['name'] == state.playerName,
            orElse: () => <String, dynamic>{},
          );

      final playerId = (payload['playerId'] as String?) ??
          (joinedPlayer['id'] as String?) ??
          _nextId('p');
      final token = (payload['sessionToken'] as String?) ?? _nextId('t');

      await _ref.read(sessionNotifierProvider.notifier).setPlayer(
            playerId: playerId,
            playerName: state.playerName,
            sessionToken: token,
          );

      _ref
          .read(roomNotifierProvider.notifier)
          .setCurrentRoom(roomCode: roomCode, isHost: false);

      state = state.copyWith(isSubmitting: false, roomCode: roomCode);
      _debug('joinRoom:success roomCode=$roomCode playerId=$playerId');
      return RoutePaths.lobbyByCode(roomCode);
    } on DioException catch (error) {
      final message =
          _extractDioError(error) ?? 'Nem sikerült csatlakozni a szobához.';
      _debug('joinRoom:dioError=$message details=${error.response?.data}');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: message,
      );
      return null;
    } catch (error, stackTrace) {
      _debug('joinRoom:error=$error\n$stackTrace');
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

  Map<String, dynamic>? _extractPayload(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    if (data['data'] is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>;
    }
    return data;
  }

  Map<String, dynamic> _extractRoomMap(Map<String, dynamic> payload) {
    final room = payload['room'];
    if (room is Map<String, dynamic>) return room;
    return payload;
  }

  String _extractRoomCode(
    Map<String, dynamic> payload,
    Map<String, dynamic> roomData, {
    String fallback = '',
  }) {
    return (roomData['code'] as String?) ??
        (payload['code'] as String?) ??
        fallback;
  }

  String? _extractDioError(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final dataError = responseData['error'];
      if (dataError is String && dataError.isNotEmpty) {
        return dataError;
      }
      if (dataError is Map<String, dynamic>) {
        final message = dataError['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
    }
    return error.message;
  }

  void _debug(String message) {
    if (!kDebugMode || !AppConstants.enableNetworkLogs) return;
    debugPrint('[ROOM_ENTRY] $message');
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

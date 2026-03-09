import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomNotifierProvider = StateNotifierProvider<RoomNotifier, RoomState>(
  (ref) => RoomNotifier(),
);

class RoomNotifier extends StateNotifier<RoomState> {
  RoomNotifier() : super(const RoomState());

  void setCurrentRoom({required String roomCode, required bool isHost}) {
    state = state.copyWith(currentRoomCode: roomCode, isHost: isHost);
  }

  void clearCurrentRoom() {
    state = const RoomState();
  }

  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();

    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}

class RoomState {
  const RoomState({this.currentRoomCode, this.isHost = false});

  final String? currentRoomCode;
  final bool isHost;

  RoomState copyWith({String? currentRoomCode, bool? isHost}) {
    return RoomState(
      currentRoomCode: currentRoomCode ?? this.currentRoomCode,
      isHost: isHost ?? this.isHost,
    );
  }
}

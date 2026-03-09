import 'package:flutter_riverpod/flutter_riverpod.dart';

final lobbyNotifierProvider = StateNotifierProvider<LobbyNotifier, LobbyState>(
  (ref) => LobbyNotifier(),
);

class LobbyNotifier extends StateNotifier<LobbyState> {
  LobbyNotifier() : super(const LobbyState());

  void setStarting(bool value) => state = state.copyWith(isStarting: value);
}

class LobbyState {
  const LobbyState({this.isStarting = false});

  final bool isStarting;

  LobbyState copyWith({bool? isStarting}) =>
      LobbyState(isStarting: isStarting ?? this.isStarting);
}

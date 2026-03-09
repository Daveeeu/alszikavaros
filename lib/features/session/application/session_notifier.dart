import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../data/session_repository.dart';
import '../data/session_repository_impl.dart';
import '../domain/session_state_status.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(
    secureStorage: ref.watch(secureStorageServiceProvider),
    preferences: ref.watch(preferencesServiceProvider),
  );
});

final sessionNotifierProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref.watch(sessionRepositoryProvider));
});

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._repository) : super(const SessionState());

  final SessionRepository _repository;

  Future<void> bootstrap() async {
    if (state.status == SessionStateStatus.loading) return;

    state =
        state.copyWith(status: SessionStateStatus.loading, errorMessage: '');

    try {
      final persisted = await _repository.readSession();
      if (persisted == null) {
        state = state.copyWith(status: SessionStateStatus.unauthenticated);
        return;
      }

      state = state.copyWith(
        playerId: persisted.playerId,
        playerName: persisted.playerName,
        sessionToken: persisted.sessionToken,
        status: SessionStateStatus.authenticated,
      );
    } catch (_) {
      state = state.copyWith(
        status: SessionStateStatus.failure,
        errorMessage: 'Nem sikerült betölteni a munkamenetet.',
      );
    }
  }

  Future<void> setPlayer({
    required String playerId,
    required String playerName,
    required String sessionToken,
  }) async {
    await _repository.saveSession(
      playerId: playerId,
      playerName: playerName,
      sessionToken: sessionToken,
    );

    state = state.copyWith(
      playerId: playerId,
      playerName: playerName,
      sessionToken: sessionToken,
      status: SessionStateStatus.authenticated,
      errorMessage: '',
    );
  }

  Future<void> clearSession() async {
    await _repository.clearSession();
    state = const SessionState(status: SessionStateStatus.unauthenticated);
  }
}

class SessionState {
  const SessionState({
    this.playerId,
    this.playerName,
    this.sessionToken,
    this.status = SessionStateStatus.initial,
    this.errorMessage = '',
  });

  final String? playerId;
  final String? playerName;
  final String? sessionToken;
  final SessionStateStatus status;
  final String errorMessage;

  bool get isReady =>
      status == SessionStateStatus.authenticated ||
      status == SessionStateStatus.unauthenticated;

  SessionState copyWith({
    String? playerId,
    String? playerName,
    String? sessionToken,
    SessionStateStatus? status,
    String? errorMessage,
  }) {
    return SessionState(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      sessionToken: sessionToken ?? this.sessionToken,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

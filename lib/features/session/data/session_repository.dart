import '../domain/persisted_session.dart';

abstract class SessionRepository {
  Future<void> saveSession({
    required String playerId,
    required String sessionToken,
    required String playerName,
  });

  Future<PersistedSession?> readSession();
  Future<void> clearSession();
}

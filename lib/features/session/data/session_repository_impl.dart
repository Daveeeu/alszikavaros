import '../../../core/storage/preferences_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/persisted_session.dart';
import '../domain/session_keys.dart';
import 'session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl({
    required SecureStorageService secureStorage,
    required PreferencesService preferences,
  })  : _secureStorage = secureStorage,
        _preferences = preferences;

  final SecureStorageService _secureStorage;
  final PreferencesService _preferences;

  @override
  Future<void> saveSession({
    required String playerId,
    required String sessionToken,
    required String playerName,
  }) async {
    await _preferences.setString(SessionKeys.playerId, playerId);
    await _preferences.setString(SessionKeys.playerName, playerName);
    await _secureStorage.write(SessionKeys.sessionToken, sessionToken);
  }

  @override
  Future<PersistedSession?> readSession() async {
    final playerId = await _preferences.getString(SessionKeys.playerId);
    final playerName = await _preferences.getString(SessionKeys.playerName);
    final sessionToken = await _secureStorage.read(SessionKeys.sessionToken);

    if (playerId == null || playerName == null || sessionToken == null) {
      return null;
    }

    return PersistedSession(
      playerId: playerId,
      playerName: playerName,
      sessionToken: sessionToken,
    );
  }

  @override
  Future<void> clearSession() async {
    await _preferences.remove(SessionKeys.playerId);
    await _preferences.remove(SessionKeys.playerName);
    await _secureStorage.delete(SessionKeys.sessionToken);
  }
}

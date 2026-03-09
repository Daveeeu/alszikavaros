import '../../../core/domain/types/id_types.dart';

class PersistedSession {
  const PersistedSession({
    required this.playerId,
    required this.sessionToken,
    required this.playerName,
  });

  final PlayerId playerId;
  final SessionToken sessionToken;
  final String playerName;
}

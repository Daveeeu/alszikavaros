import '../../../core/domain/enums/game_phase.dart';
import '../../../core/router/route_paths.dart';

String? routeForPhase({
  required GamePhase phase,
  required String gameId,
}) {
  switch (phase) {
    case GamePhase.roleReveal:
      return RoutePaths.roleRevealByGameId(gameId);
    case GamePhase.nightKiller:
    case GamePhase.nightDoctor:
      return RoutePaths.nightActionByGameId(gameId);
    case GamePhase.nightResolve:
      return RoutePaths.waitingByGameId(gameId);
    case GamePhase.dayReveal:
      return RoutePaths.dayResultByGameId(gameId);
    case GamePhase.discussion:
      return RoutePaths.discussionByGameId(gameId);
    case GamePhase.voting:
      return RoutePaths.votingByGameId(gameId);
    case GamePhase.voteResult:
      return RoutePaths.voteResultByGameId(gameId);
    case GamePhase.ended:
      return RoutePaths.endByGameId(gameId);
    case GamePhase.lobby:
      return null;
  }
}

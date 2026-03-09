import '../../../../core/domain/enums/role.dart';
import '../../../../core/domain/enums/winner_type.dart';
import 'rule_models.dart';

class WinConditionService {
  const WinConditionService();

  WinConditionResult checkWinCondition(
    List<PlayerRoleStatus> playerStates,
  ) {
    final alivePlayers = playerStates.where((player) => player.isAlive).toList();

    final aliveKillers = alivePlayers
        .where((player) => player.role == Role.killer)
        .length;

    final aliveNonKillers = alivePlayers.length - aliveKillers;

    if (aliveKillers == 0) {
      return WinConditionResult(
        isGameEnded: true,
        winner: WinnerType.villagers,
        aliveKillers: aliveKillers,
        aliveNonKillers: aliveNonKillers,
      );
    }

    if (aliveKillers >= aliveNonKillers) {
      return WinConditionResult(
        isGameEnded: true,
        winner: WinnerType.killers,
        aliveKillers: aliveKillers,
        aliveNonKillers: aliveNonKillers,
      );
    }

    return WinConditionResult(
      isGameEnded: false,
      winner: WinnerType.none,
      aliveKillers: aliveKillers,
      aliveNonKillers: aliveNonKillers,
    );
  }
}

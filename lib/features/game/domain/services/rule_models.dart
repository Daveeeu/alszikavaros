import '../../../../core/domain/enums/role.dart';
import '../../../../core/domain/enums/winner_type.dart';
import '../../../../core/domain/types/id_types.dart';

class RoleDistribution {
  const RoleDistribution({
    required this.assignments,
    required this.roles,
  });

  final Map<PlayerId, Role> assignments;
  final List<Role> roles;
}

class NightResolution {
  const NightResolution({
    required this.targetedPlayerId,
    required this.savedPlayerId,
    required this.eliminatedPlayerId,
    required this.wasSaved,
    required this.wasRandomTieBreak,
  });

  final PlayerId? targetedPlayerId;
  final PlayerId? savedPlayerId;
  final PlayerId? eliminatedPlayerId;
  final bool wasSaved;
  final bool wasRandomTieBreak;
}

class VoteResolution {
  const VoteResolution({
    required this.eliminatedPlayerId,
    required this.isTie,
    required this.highestVoteCount,
  });

  final PlayerId? eliminatedPlayerId;
  final bool isTie;
  final int highestVoteCount;
}

class PlayerRoleStatus {
  const PlayerRoleStatus({
    required this.playerId,
    required this.role,
    required this.isAlive,
  });

  final PlayerId playerId;
  final Role role;
  final bool isAlive;
}

class WinConditionResult {
  const WinConditionResult({
    required this.isGameEnded,
    required this.winner,
    required this.aliveKillers,
    required this.aliveNonKillers,
  });

  final bool isGameEnded;
  final WinnerType winner;
  final int aliveKillers;
  final int aliveNonKillers;
}

import 'dart:math';

import '../../../../core/domain/enums/role.dart';
import '../../../../core/domain/types/id_types.dart';
import 'rule_models.dart';

class RoleDistributionService {
  const RoleDistributionService({Random? random}) : _random = random;

  final Random? _random;

  RoleDistribution distributeForSixPlayers(List<PlayerId> playerIds) {
    if (playerIds.length != 6) {
      throw ArgumentError(
        'Role distribution for MVP requires exactly 6 players.',
      );
    }

    final roles = <Role>[
      Role.killer,
      Role.killer,
      Role.doctor,
      Role.villager,
      Role.villager,
      Role.villager,
    ];

    final shuffledRoles = List<Role>.from(roles)
      ..shuffle(_random ?? Random());

    final assignments = <PlayerId, Role>{};
    for (var i = 0; i < playerIds.length; i++) {
      assignments[playerIds[i]] = shuffledRoles[i];
    }

    return RoleDistribution(assignments: assignments, roles: shuffledRoles);
  }
}

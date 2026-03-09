import '../../../../core/domain/types/id_types.dart';
import 'services/night_resolution_service.dart';
import 'services/role_distribution_service.dart';
import 'services/rule_models.dart';
import 'services/vote_resolution_service.dart';
import 'services/win_condition_service.dart';

class GameRulesService {
  GameRulesService({
    RoleDistributionService? roleDistributionService,
    NightResolutionService? nightResolutionService,
    VoteResolutionService? voteResolutionService,
    WinConditionService? winConditionService,
  })  : _roleDistributionService =
            roleDistributionService ?? const RoleDistributionService(),
        _nightResolutionService =
            nightResolutionService ?? const NightResolutionService(),
        _voteResolutionService =
            voteResolutionService ?? const VoteResolutionService(),
        _winConditionService =
            winConditionService ?? const WinConditionService();

  final RoleDistributionService _roleDistributionService;
  final NightResolutionService _nightResolutionService;
  final VoteResolutionService _voteResolutionService;
  final WinConditionService _winConditionService;

  RoleDistribution distributeRolesForSixPlayers(List<PlayerId> playerIds) {
    return _roleDistributionService.distributeForSixPlayers(playerIds);
  }

  NightResolution resolveNight({
    required List<PlayerId> killerTargets,
    PlayerId? doctorSavedPlayerId,
  }) {
    return _nightResolutionService.resolveNight(
      killerTargets: killerTargets,
      doctorSavedPlayerId: doctorSavedPlayerId,
    );
  }

  VoteResolution resolveVotes({required List<PlayerId> voteTargets}) {
    return _voteResolutionService.resolveVotes(voteTargets: voteTargets);
  }

  WinConditionResult checkWinCondition(List<PlayerRoleStatus> playerStates) {
    return _winConditionService.checkWinCondition(playerStates);
  }
}

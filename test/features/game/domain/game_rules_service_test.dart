import 'package:alszik_a_varos/core/domain/enums/role.dart';
import 'package:alszik_a_varos/core/domain/enums/winner_type.dart';
import 'package:alszik_a_varos/features/game/domain/game_rules_service.dart';
import 'package:alszik_a_varos/features/game/domain/services/night_resolution_service.dart';
import 'package:alszik_a_varos/features/game/domain/services/rule_models.dart';
import 'package:alszik_a_varos/features/game/domain/services/vote_resolution_service.dart';
import 'package:alszik_a_varos/features/game/domain/services/win_condition_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoleDistributionService', () {
    test('distributes MVP role counts for 6 players', () {
      final service = GameRulesService();
      final distribution = service.distributeRolesForSixPlayers(
        const ['p1', 'p2', 'p3', 'p4', 'p5', 'p6'],
      );

      final killers =
          distribution.assignments.values.where((role) => role == Role.killer).length;
      final doctors =
          distribution.assignments.values.where((role) => role == Role.doctor).length;
      final villagers = distribution.assignments.values
          .where((role) => role == Role.villager)
          .length;

      expect(distribution.assignments.length, 6);
      expect(killers, 2);
      expect(doctors, 1);
      expect(villagers, 3);
    });
  });

  group('NightResolutionService', () {
    test('doctor save prevents elimination', () {
      const service = NightResolutionService();

      final result = service.resolveNight(
        killerTargets: const ['p2', 'p2'],
        doctorSavedPlayerId: 'p2',
      );

      expect(result.targetedPlayerId, 'p2');
      expect(result.wasSaved, true);
      expect(result.eliminatedPlayerId, isNull);
    });

    test('killer tie picks random among tied targets for MVP', () {
      final service = NightResolutionService(
        randomIndexPicker: (_) => 1,
      );

      final result = service.resolveNight(
        killerTargets: const ['p2', 'p3'],
        doctorSavedPlayerId: null,
      );

      expect(result.wasRandomTieBreak, true);
      expect(result.targetedPlayerId, 'p3');
      expect(result.eliminatedPlayerId, 'p3');
    });
  });

  group('VoteResolutionService', () {
    test('tie means nobody is eliminated', () {
      const service = VoteResolutionService();

      final result = service.resolveVotes(
        voteTargets: const ['p2', 'p3'],
      );

      expect(result.isTie, true);
      expect(result.eliminatedPlayerId, isNull);
    });

    test('highest vote target is eliminated on clear majority', () {
      const service = VoteResolutionService();

      final result = service.resolveVotes(
        voteTargets: const ['p2', 'p2', 'p3'],
      );

      expect(result.isTie, false);
      expect(result.eliminatedPlayerId, 'p2');
      expect(result.highestVoteCount, 2);
    });
  });

  group('WinConditionService', () {
    test('villagers win when all killers are eliminated', () {
      const service = WinConditionService();

      final result = service.checkWinCondition(
        const [
          PlayerRoleStatus(playerId: 'p1', role: Role.killer, isAlive: false),
          PlayerRoleStatus(playerId: 'p2', role: Role.killer, isAlive: false),
          PlayerRoleStatus(playerId: 'p3', role: Role.doctor, isAlive: true),
          PlayerRoleStatus(playerId: 'p4', role: Role.villager, isAlive: true),
        ],
      );

      expect(result.isGameEnded, true);
      expect(result.winner, WinnerType.villagers);
    });

    test('killers win when killers alive >= non-killers alive', () {
      const service = WinConditionService();

      final result = service.checkWinCondition(
        const [
          PlayerRoleStatus(playerId: 'p1', role: Role.killer, isAlive: true),
          PlayerRoleStatus(playerId: 'p2', role: Role.killer, isAlive: true),
          PlayerRoleStatus(playerId: 'p3', role: Role.doctor, isAlive: true),
          PlayerRoleStatus(playerId: 'p4', role: Role.villager, isAlive: false),
        ],
      );

      expect(result.isGameEnded, true);
      expect(result.winner, WinnerType.killers);
      expect(result.aliveKillers, 2);
      expect(result.aliveNonKillers, 1);
    });
  });
}

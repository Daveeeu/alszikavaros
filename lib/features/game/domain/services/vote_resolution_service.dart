import '../../../../core/domain/types/id_types.dart';
import 'rule_models.dart';

class VoteResolutionService {
  const VoteResolutionService();

  VoteResolution resolveVotes({
    required List<PlayerId> voteTargets,
  }) {
    if (voteTargets.isEmpty) {
      return const VoteResolution(
        eliminatedPlayerId: null,
        isTie: false,
        highestVoteCount: 0,
      );
    }

    final voteCounts = <PlayerId, int>{};
    for (final target in voteTargets) {
      voteCounts[target] = (voteCounts[target] ?? 0) + 1;
    }

    final highestVoteCount = voteCounts.values.reduce(
      (value, element) => value > element ? value : element,
    );

    final topTargets = voteCounts.entries
        .where((entry) => entry.value == highestVoteCount)
        .map((entry) => entry.key)
        .toList(growable: false);

    if (topTargets.length > 1) {
      return VoteResolution(
        eliminatedPlayerId: null,
        isTie: true,
        highestVoteCount: highestVoteCount,
      );
    }

    return VoteResolution(
      eliminatedPlayerId: topTargets.first,
      isTie: false,
      highestVoteCount: highestVoteCount,
    );
  }
}

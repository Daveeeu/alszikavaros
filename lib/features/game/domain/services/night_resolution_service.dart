import '../../../../core/domain/types/id_types.dart';
import 'rule_models.dart';

typedef RandomIndexPicker = int Function(int upperBoundExclusive);

class NightResolutionService {
  const NightResolutionService({RandomIndexPicker? randomIndexPicker})
      : _randomIndexPicker = randomIndexPicker;

  final RandomIndexPicker? _randomIndexPicker;

  NightResolution resolveNight({
    required List<PlayerId> killerTargets,
    PlayerId? doctorSavedPlayerId,
  }) {
    final targetedPlayerId = _resolveKillerTarget(killerTargets);

    if (targetedPlayerId == null) {
      return NightResolution(
        targetedPlayerId: null,
        savedPlayerId: doctorSavedPlayerId,
        eliminatedPlayerId: null,
        wasSaved: false,
        wasRandomTieBreak: false,
      );
    }

    final wasSaved = doctorSavedPlayerId != null &&
        doctorSavedPlayerId == targetedPlayerId;

    return NightResolution(
      targetedPlayerId: targetedPlayerId,
      savedPlayerId: doctorSavedPlayerId,
      eliminatedPlayerId: wasSaved ? null : targetedPlayerId,
      wasSaved: wasSaved,
      wasRandomTieBreak: _hadTie(killerTargets),
    );
  }

  PlayerId? _resolveKillerTarget(List<PlayerId> killerTargets) {
    if (killerTargets.isEmpty) {
      return null;
    }

    final voteCounts = <PlayerId, int>{};
    for (final target in killerTargets) {
      voteCounts[target] = (voteCounts[target] ?? 0) + 1;
    }

    final highestVoteCount = voteCounts.values.reduce(
      (value, element) => value > element ? value : element,
    );

    final topTargets = voteCounts.entries
        .where((entry) => entry.value == highestVoteCount)
        .map((entry) => entry.key)
        .toList(growable: false);

    if (topTargets.length == 1) {
      return topTargets.first;
    }

    final picker = _randomIndexPicker;
    final pickedIndex = picker != null
        ? picker(topTargets.length)
        : DateTime.now().millisecondsSinceEpoch % topTargets.length;

    return topTargets[pickedIndex];
  }

  bool _hadTie(List<PlayerId> killerTargets) {
    if (killerTargets.length <= 1) return false;

    final voteCounts = <PlayerId, int>{};
    for (final target in killerTargets) {
      voteCounts[target] = (voteCounts[target] ?? 0) + 1;
    }

    final highestVoteCount = voteCounts.values.reduce(
      (value, element) => value > element ? value : element,
    );

    final topTargets = voteCounts.values
        .where((count) => count == highestVoteCount)
        .length;

    return topTargets > 1;
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/types/id_types.dart';

part 'latest_vote_result.freezed.dart';
part 'latest_vote_result.g.dart';

@freezed
class LatestVoteResult with _$LatestVoteResult {
  const factory LatestVoteResult({
    required int dayNumber,
    required bool isTie,
    PlayerId? eliminatedPlayerId,
    String? eliminatedPlayerName,
    @Default(<PlayerId>[]) List<PlayerId> alivePlayerIds,
  }) = _LatestVoteResult;

  factory LatestVoteResult.fromJson(Map<String, dynamic> json) =>
      _$LatestVoteResultFromJson(json);
}

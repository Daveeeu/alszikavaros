import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/types/id_types.dart';
import '../../../room/domain/models/player.dart';
import '../../../room/domain/models/room.dart';
import 'final_role_entry.dart';
import 'game.dart';
import 'latest_vote_result.dart';
import 'player_role.dart';

part 'game_snapshot.freezed.dart';
part 'game_snapshot.g.dart';

@freezed
class GameSnapshot with _$GameSnapshot {
  const factory GameSnapshot({
    required Room room,
    required List<Player> players,
    required Game game,
    PlayerRole? currentPlayerRole,
    required PlayerId currentPlayerId,
    LatestVoteResult? latestVoteResult,
    @Default(<FinalRoleEntry>[]) List<FinalRoleEntry> finalRoles,
  }) = _GameSnapshot;

  factory GameSnapshot.fromJson(Map<String, dynamic> json) =>
      _$GameSnapshotFromJson(json);
}

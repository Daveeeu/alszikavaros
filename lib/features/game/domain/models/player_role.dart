import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/enums/role.dart';
import '../../../../core/domain/types/id_types.dart';

part 'player_role.freezed.dart';
part 'player_role.g.dart';

@freezed
class PlayerRole with _$PlayerRole {
  const factory PlayerRole({
    required GameId gameId,
    required PlayerId playerId,
    required Role role,
  }) = _PlayerRole;

  factory PlayerRole.fromJson(Map<String, dynamic> json) =>
      _$PlayerRoleFromJson(json);
}

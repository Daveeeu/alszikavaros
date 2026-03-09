import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/enums/role.dart';
import '../../../../core/domain/types/id_types.dart';

part 'night_action.freezed.dart';
part 'night_action.g.dart';

@freezed
class NightAction with _$NightAction {
  const factory NightAction({
    required GameId gameId,
    required PlayerId playerId,
    required Role role,
    required PlayerId targetPlayerId,
    required int roundNumber,
  }) = _NightAction;

  factory NightAction.fromJson(Map<String, dynamic> json) =>
      _$NightActionFromJson(json);
}

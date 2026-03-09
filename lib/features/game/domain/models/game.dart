import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/enums/game_phase.dart';
import '../../../../core/domain/enums/winner_type.dart';
import '../../../../core/domain/types/id_types.dart';

part 'game.freezed.dart';
part 'game.g.dart';

@freezed
class Game with _$Game {
  const factory Game({
    required GameId id,
    required RoomId roomId,
    required GamePhase phase,
    required int dayNumber,
    required WinnerType winner,
    required List<PlayerId> alivePlayerIds,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

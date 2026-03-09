import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/types/id_types.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  const factory Player({
    required PlayerId id,
    required RoomId roomId,
    required String name,
    required bool isHost,
    required bool isAlive,
    required SessionToken sessionToken,
    required bool isConnected,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

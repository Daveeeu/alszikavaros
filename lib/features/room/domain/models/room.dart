import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/enums/room_status.dart';
import '../../../../core/domain/types/id_types.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required RoomId id,
    required RoomCode code,
    required PlayerId hostPlayerId,
    required RoomStatus status,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      hostPlayerId: json['hostPlayerId'] as String,
      status: $enumDecode(_$RoomStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'hostPlayerId': instance.hostPlayerId,
      'status': _$RoomStatusEnumMap[instance.status]!,
    };

const _$RoomStatusEnumMap = {
  RoomStatus.waiting: 'waiting',
  RoomStatus.inGame: 'in_game',
  RoomStatus.finished: 'finished',
};

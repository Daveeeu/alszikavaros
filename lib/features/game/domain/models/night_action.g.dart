// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'night_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NightActionImpl _$$NightActionImplFromJson(Map<String, dynamic> json) =>
    _$NightActionImpl(
      gameId: json['gameId'] as String,
      playerId: json['playerId'] as String,
      role: $enumDecode(_$RoleEnumMap, json['role']),
      targetPlayerId: json['targetPlayerId'] as String,
      roundNumber: (json['roundNumber'] as num).toInt(),
    );

Map<String, dynamic> _$$NightActionImplToJson(_$NightActionImpl instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'playerId': instance.playerId,
      'role': _$RoleEnumMap[instance.role]!,
      'targetPlayerId': instance.targetPlayerId,
      'roundNumber': instance.roundNumber,
    };

const _$RoleEnumMap = {
  Role.killer: 'killer',
  Role.doctor: 'doctor',
  Role.villager: 'villager',
};

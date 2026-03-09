// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerRoleImpl _$$PlayerRoleImplFromJson(Map<String, dynamic> json) =>
    _$PlayerRoleImpl(
      gameId: json['gameId'] as String,
      playerId: json['playerId'] as String,
      role: $enumDecode(_$RoleEnumMap, json['role']),
    );

Map<String, dynamic> _$$PlayerRoleImplToJson(_$PlayerRoleImpl instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'playerId': instance.playerId,
      'role': _$RoleEnumMap[instance.role]!,
    };

const _$RoleEnumMap = {
  Role.killer: 'killer',
  Role.doctor: 'doctor',
  Role.villager: 'villager',
};

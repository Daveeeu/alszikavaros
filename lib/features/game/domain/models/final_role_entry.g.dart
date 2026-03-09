// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'final_role_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FinalRoleEntryImpl _$$FinalRoleEntryImplFromJson(Map<String, dynamic> json) =>
    _$FinalRoleEntryImpl(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      role: $enumDecode(_$RoleEnumMap, json['role']),
      isAlive: json['isAlive'] as bool,
    );

Map<String, dynamic> _$$FinalRoleEntryImplToJson(
        _$FinalRoleEntryImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'role': _$RoleEnumMap[instance.role]!,
      'isAlive': instance.isAlive,
    };

const _$RoleEnumMap = {
  Role.killer: 'killer',
  Role.doctor: 'doctor',
  Role.villager: 'villager',
};

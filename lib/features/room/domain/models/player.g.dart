// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      name: json['name'] as String,
      isHost: json['isHost'] as bool,
      isAlive: json['isAlive'] as bool,
      sessionToken: json['sessionToken'] as String,
      isConnected: json['isConnected'] as bool,
    );

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'name': instance.name,
      'isHost': instance.isHost,
      'isAlive': instance.isAlive,
      'sessionToken': instance.sessionToken,
      'isConnected': instance.isConnected,
    };

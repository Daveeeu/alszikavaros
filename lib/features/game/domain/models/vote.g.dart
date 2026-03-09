// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoteImpl _$$VoteImplFromJson(Map<String, dynamic> json) => _$VoteImpl(
      gameId: json['gameId'] as String,
      voterPlayerId: json['voterPlayerId'] as String,
      targetPlayerId: json['targetPlayerId'] as String,
      dayNumber: (json['dayNumber'] as num).toInt(),
    );

Map<String, dynamic> _$$VoteImplToJson(_$VoteImpl instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'voterPlayerId': instance.voterPlayerId,
      'targetPlayerId': instance.targetPlayerId,
      'dayNumber': instance.dayNumber,
    };

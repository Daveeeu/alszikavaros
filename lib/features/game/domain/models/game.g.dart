// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameImpl _$$GameImplFromJson(Map<String, dynamic> json) => _$GameImpl(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      phase: $enumDecode(_$GamePhaseEnumMap, json['phase']),
      dayNumber: (json['dayNumber'] as num).toInt(),
      winner: $enumDecode(_$WinnerTypeEnumMap, json['winner']),
      alivePlayerIds: (json['alivePlayerIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$GameImplToJson(_$GameImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'phase': _$GamePhaseEnumMap[instance.phase]!,
      'dayNumber': instance.dayNumber,
      'winner': _$WinnerTypeEnumMap[instance.winner]!,
      'alivePlayerIds': instance.alivePlayerIds,
    };

const _$GamePhaseEnumMap = {
  GamePhase.lobby: 'lobby',
  GamePhase.roleReveal: 'role_reveal',
  GamePhase.nightKiller: 'night_killer',
  GamePhase.nightDoctor: 'night_doctor',
  GamePhase.nightResolve: 'night_resolve',
  GamePhase.dayReveal: 'day_reveal',
  GamePhase.discussion: 'discussion',
  GamePhase.voting: 'voting',
  GamePhase.voteResult: 'vote_result',
  GamePhase.ended: 'ended',
};

const _$WinnerTypeEnumMap = {
  WinnerType.villagers: 'villagers',
  WinnerType.killers: 'killers',
  WinnerType.none: 'none',
};

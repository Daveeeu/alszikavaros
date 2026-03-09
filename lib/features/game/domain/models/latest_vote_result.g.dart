// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_vote_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LatestVoteResultImpl _$$LatestVoteResultImplFromJson(
        Map<String, dynamic> json) =>
    _$LatestVoteResultImpl(
      dayNumber: (json['dayNumber'] as num).toInt(),
      isTie: json['isTie'] as bool,
      eliminatedPlayerId: json['eliminatedPlayerId'] as String?,
      eliminatedPlayerName: json['eliminatedPlayerName'] as String?,
      alivePlayerIds: (json['alivePlayerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <PlayerId>[],
    );

Map<String, dynamic> _$$LatestVoteResultImplToJson(
        _$LatestVoteResultImpl instance) =>
    <String, dynamic>{
      'dayNumber': instance.dayNumber,
      'isTie': instance.isTie,
      'eliminatedPlayerId': instance.eliminatedPlayerId,
      'eliminatedPlayerName': instance.eliminatedPlayerName,
      'alivePlayerIds': instance.alivePlayerIds,
    };

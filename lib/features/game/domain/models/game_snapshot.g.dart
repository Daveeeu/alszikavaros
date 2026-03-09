// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameSnapshotImpl _$$GameSnapshotImplFromJson(Map<String, dynamic> json) =>
    _$GameSnapshotImpl(
      room: Room.fromJson(json['room'] as Map<String, dynamic>),
      players: (json['players'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      game: Game.fromJson(json['game'] as Map<String, dynamic>),
      currentPlayerRole: json['currentPlayerRole'] == null
          ? null
          : PlayerRole.fromJson(
              json['currentPlayerRole'] as Map<String, dynamic>),
      currentPlayerId: json['currentPlayerId'] as String,
      latestVoteResult: json['latestVoteResult'] == null
          ? null
          : LatestVoteResult.fromJson(
              json['latestVoteResult'] as Map<String, dynamic>),
      finalRoles: (json['finalRoles'] as List<dynamic>?)
              ?.map((e) => FinalRoleEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FinalRoleEntry>[],
    );

Map<String, dynamic> _$$GameSnapshotImplToJson(_$GameSnapshotImpl instance) =>
    <String, dynamic>{
      'room': instance.room,
      'players': instance.players,
      'game': instance.game,
      'currentPlayerRole': instance.currentPlayerRole,
      'currentPlayerId': instance.currentPlayerId,
      'latestVoteResult': instance.latestVoteResult,
      'finalRoles': instance.finalRoles,
    };

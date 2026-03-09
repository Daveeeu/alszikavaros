import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum RealtimeEventType {
  roomPlayerJoined('room.player_joined'),
  roomPlayerLeft('room.player_left'),
  roomUpdated('room.updated'),
  gameStarted('game.started'),
  gamePhaseChanged('game.phase_changed'),
  gameDayStarted('game.day_started'),
  gameVoteStarted('game.vote_started'),
  gameVoteResult('game.vote_result'),
  gameEnded('game.ended');

  const RealtimeEventType(this.value);

  final String value;
}

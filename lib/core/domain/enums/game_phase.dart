import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum GamePhase {
  lobby,
  roleReveal,
  nightKiller,
  nightDoctor,
  nightResolve,
  dayReveal,
  discussion,
  voting,
  voteResult,
  ended,
}

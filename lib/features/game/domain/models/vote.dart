import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/types/id_types.dart';

part 'vote.freezed.dart';
part 'vote.g.dart';

@freezed
class Vote with _$Vote {
  const factory Vote({
    required GameId gameId,
    required PlayerId voterPlayerId,
    required PlayerId targetPlayerId,
    required int dayNumber,
  }) = _Vote;

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);
}

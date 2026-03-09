// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Vote _$VoteFromJson(Map<String, dynamic> json) {
  return _Vote.fromJson(json);
}

/// @nodoc
mixin _$Vote {
  String get gameId => throw _privateConstructorUsedError;
  String get voterPlayerId => throw _privateConstructorUsedError;
  String get targetPlayerId => throw _privateConstructorUsedError;
  int get dayNumber => throw _privateConstructorUsedError;

  /// Serializes this Vote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoteCopyWith<Vote> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoteCopyWith<$Res> {
  factory $VoteCopyWith(Vote value, $Res Function(Vote) then) =
      _$VoteCopyWithImpl<$Res, Vote>;
  @useResult
  $Res call(
      {String gameId,
      String voterPlayerId,
      String targetPlayerId,
      int dayNumber});
}

/// @nodoc
class _$VoteCopyWithImpl<$Res, $Val extends Vote>
    implements $VoteCopyWith<$Res> {
  _$VoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? voterPlayerId = null,
    Object? targetPlayerId = null,
    Object? dayNumber = null,
  }) {
    return _then(_value.copyWith(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      voterPlayerId: null == voterPlayerId
          ? _value.voterPlayerId
          : voterPlayerId // ignore: cast_nullable_to_non_nullable
              as String,
      targetPlayerId: null == targetPlayerId
          ? _value.targetPlayerId
          : targetPlayerId // ignore: cast_nullable_to_non_nullable
              as String,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoteImplCopyWith<$Res> implements $VoteCopyWith<$Res> {
  factory _$$VoteImplCopyWith(
          _$VoteImpl value, $Res Function(_$VoteImpl) then) =
      __$$VoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String gameId,
      String voterPlayerId,
      String targetPlayerId,
      int dayNumber});
}

/// @nodoc
class __$$VoteImplCopyWithImpl<$Res>
    extends _$VoteCopyWithImpl<$Res, _$VoteImpl>
    implements _$$VoteImplCopyWith<$Res> {
  __$$VoteImplCopyWithImpl(_$VoteImpl _value, $Res Function(_$VoteImpl) _then)
      : super(_value, _then);

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? voterPlayerId = null,
    Object? targetPlayerId = null,
    Object? dayNumber = null,
  }) {
    return _then(_$VoteImpl(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      voterPlayerId: null == voterPlayerId
          ? _value.voterPlayerId
          : voterPlayerId // ignore: cast_nullable_to_non_nullable
              as String,
      targetPlayerId: null == targetPlayerId
          ? _value.targetPlayerId
          : targetPlayerId // ignore: cast_nullable_to_non_nullable
              as String,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoteImpl implements _Vote {
  const _$VoteImpl(
      {required this.gameId,
      required this.voterPlayerId,
      required this.targetPlayerId,
      required this.dayNumber});

  factory _$VoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoteImplFromJson(json);

  @override
  final String gameId;
  @override
  final String voterPlayerId;
  @override
  final String targetPlayerId;
  @override
  final int dayNumber;

  @override
  String toString() {
    return 'Vote(gameId: $gameId, voterPlayerId: $voterPlayerId, targetPlayerId: $targetPlayerId, dayNumber: $dayNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoteImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.voterPlayerId, voterPlayerId) ||
                other.voterPlayerId == voterPlayerId) &&
            (identical(other.targetPlayerId, targetPlayerId) ||
                other.targetPlayerId == targetPlayerId) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, gameId, voterPlayerId, targetPlayerId, dayNumber);

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoteImplCopyWith<_$VoteImpl> get copyWith =>
      __$$VoteImplCopyWithImpl<_$VoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoteImplToJson(
      this,
    );
  }
}

abstract class _Vote implements Vote {
  const factory _Vote(
      {required final String gameId,
      required final String voterPlayerId,
      required final String targetPlayerId,
      required final int dayNumber}) = _$VoteImpl;

  factory _Vote.fromJson(Map<String, dynamic> json) = _$VoteImpl.fromJson;

  @override
  String get gameId;
  @override
  String get voterPlayerId;
  @override
  String get targetPlayerId;
  @override
  int get dayNumber;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoteImplCopyWith<_$VoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

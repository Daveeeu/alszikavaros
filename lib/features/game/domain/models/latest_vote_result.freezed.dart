// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'latest_vote_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LatestVoteResult _$LatestVoteResultFromJson(Map<String, dynamic> json) {
  return _LatestVoteResult.fromJson(json);
}

/// @nodoc
mixin _$LatestVoteResult {
  int get dayNumber => throw _privateConstructorUsedError;
  bool get isTie => throw _privateConstructorUsedError;
  String? get eliminatedPlayerId => throw _privateConstructorUsedError;
  String? get eliminatedPlayerName => throw _privateConstructorUsedError;
  List<String> get alivePlayerIds => throw _privateConstructorUsedError;

  /// Serializes this LatestVoteResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LatestVoteResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LatestVoteResultCopyWith<LatestVoteResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LatestVoteResultCopyWith<$Res> {
  factory $LatestVoteResultCopyWith(
          LatestVoteResult value, $Res Function(LatestVoteResult) then) =
      _$LatestVoteResultCopyWithImpl<$Res, LatestVoteResult>;
  @useResult
  $Res call(
      {int dayNumber,
      bool isTie,
      String? eliminatedPlayerId,
      String? eliminatedPlayerName,
      List<String> alivePlayerIds});
}

/// @nodoc
class _$LatestVoteResultCopyWithImpl<$Res, $Val extends LatestVoteResult>
    implements $LatestVoteResultCopyWith<$Res> {
  _$LatestVoteResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LatestVoteResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayNumber = null,
    Object? isTie = null,
    Object? eliminatedPlayerId = freezed,
    Object? eliminatedPlayerName = freezed,
    Object? alivePlayerIds = null,
  }) {
    return _then(_value.copyWith(
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      isTie: null == isTie
          ? _value.isTie
          : isTie // ignore: cast_nullable_to_non_nullable
              as bool,
      eliminatedPlayerId: freezed == eliminatedPlayerId
          ? _value.eliminatedPlayerId
          : eliminatedPlayerId // ignore: cast_nullable_to_non_nullable
              as String?,
      eliminatedPlayerName: freezed == eliminatedPlayerName
          ? _value.eliminatedPlayerName
          : eliminatedPlayerName // ignore: cast_nullable_to_non_nullable
              as String?,
      alivePlayerIds: null == alivePlayerIds
          ? _value.alivePlayerIds
          : alivePlayerIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LatestVoteResultImplCopyWith<$Res>
    implements $LatestVoteResultCopyWith<$Res> {
  factory _$$LatestVoteResultImplCopyWith(_$LatestVoteResultImpl value,
          $Res Function(_$LatestVoteResultImpl) then) =
      __$$LatestVoteResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int dayNumber,
      bool isTie,
      String? eliminatedPlayerId,
      String? eliminatedPlayerName,
      List<String> alivePlayerIds});
}

/// @nodoc
class __$$LatestVoteResultImplCopyWithImpl<$Res>
    extends _$LatestVoteResultCopyWithImpl<$Res, _$LatestVoteResultImpl>
    implements _$$LatestVoteResultImplCopyWith<$Res> {
  __$$LatestVoteResultImplCopyWithImpl(_$LatestVoteResultImpl _value,
      $Res Function(_$LatestVoteResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of LatestVoteResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayNumber = null,
    Object? isTie = null,
    Object? eliminatedPlayerId = freezed,
    Object? eliminatedPlayerName = freezed,
    Object? alivePlayerIds = null,
  }) {
    return _then(_$LatestVoteResultImpl(
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      isTie: null == isTie
          ? _value.isTie
          : isTie // ignore: cast_nullable_to_non_nullable
              as bool,
      eliminatedPlayerId: freezed == eliminatedPlayerId
          ? _value.eliminatedPlayerId
          : eliminatedPlayerId // ignore: cast_nullable_to_non_nullable
              as String?,
      eliminatedPlayerName: freezed == eliminatedPlayerName
          ? _value.eliminatedPlayerName
          : eliminatedPlayerName // ignore: cast_nullable_to_non_nullable
              as String?,
      alivePlayerIds: null == alivePlayerIds
          ? _value._alivePlayerIds
          : alivePlayerIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LatestVoteResultImpl implements _LatestVoteResult {
  const _$LatestVoteResultImpl(
      {required this.dayNumber,
      required this.isTie,
      this.eliminatedPlayerId,
      this.eliminatedPlayerName,
      final List<String> alivePlayerIds = const <PlayerId>[]})
      : _alivePlayerIds = alivePlayerIds;

  factory _$LatestVoteResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$LatestVoteResultImplFromJson(json);

  @override
  final int dayNumber;
  @override
  final bool isTie;
  @override
  final String? eliminatedPlayerId;
  @override
  final String? eliminatedPlayerName;
  final List<String> _alivePlayerIds;
  @override
  @JsonKey()
  List<String> get alivePlayerIds {
    if (_alivePlayerIds is EqualUnmodifiableListView) return _alivePlayerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alivePlayerIds);
  }

  @override
  String toString() {
    return 'LatestVoteResult(dayNumber: $dayNumber, isTie: $isTie, eliminatedPlayerId: $eliminatedPlayerId, eliminatedPlayerName: $eliminatedPlayerName, alivePlayerIds: $alivePlayerIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LatestVoteResultImpl &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.isTie, isTie) || other.isTie == isTie) &&
            (identical(other.eliminatedPlayerId, eliminatedPlayerId) ||
                other.eliminatedPlayerId == eliminatedPlayerId) &&
            (identical(other.eliminatedPlayerName, eliminatedPlayerName) ||
                other.eliminatedPlayerName == eliminatedPlayerName) &&
            const DeepCollectionEquality()
                .equals(other._alivePlayerIds, _alivePlayerIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      dayNumber,
      isTie,
      eliminatedPlayerId,
      eliminatedPlayerName,
      const DeepCollectionEquality().hash(_alivePlayerIds));

  /// Create a copy of LatestVoteResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LatestVoteResultImplCopyWith<_$LatestVoteResultImpl> get copyWith =>
      __$$LatestVoteResultImplCopyWithImpl<_$LatestVoteResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LatestVoteResultImplToJson(
      this,
    );
  }
}

abstract class _LatestVoteResult implements LatestVoteResult {
  const factory _LatestVoteResult(
      {required final int dayNumber,
      required final bool isTie,
      final String? eliminatedPlayerId,
      final String? eliminatedPlayerName,
      final List<String> alivePlayerIds}) = _$LatestVoteResultImpl;

  factory _LatestVoteResult.fromJson(Map<String, dynamic> json) =
      _$LatestVoteResultImpl.fromJson;

  @override
  int get dayNumber;
  @override
  bool get isTie;
  @override
  String? get eliminatedPlayerId;
  @override
  String? get eliminatedPlayerName;
  @override
  List<String> get alivePlayerIds;

  /// Create a copy of LatestVoteResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LatestVoteResultImplCopyWith<_$LatestVoteResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'night_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NightAction _$NightActionFromJson(Map<String, dynamic> json) {
  return _NightAction.fromJson(json);
}

/// @nodoc
mixin _$NightAction {
  String get gameId => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  Role get role => throw _privateConstructorUsedError;
  String get targetPlayerId => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;

  /// Serializes this NightAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NightAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NightActionCopyWith<NightAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NightActionCopyWith<$Res> {
  factory $NightActionCopyWith(
          NightAction value, $Res Function(NightAction) then) =
      _$NightActionCopyWithImpl<$Res, NightAction>;
  @useResult
  $Res call(
      {String gameId,
      String playerId,
      Role role,
      String targetPlayerId,
      int roundNumber});
}

/// @nodoc
class _$NightActionCopyWithImpl<$Res, $Val extends NightAction>
    implements $NightActionCopyWith<$Res> {
  _$NightActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NightAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playerId = null,
    Object? role = null,
    Object? targetPlayerId = null,
    Object? roundNumber = null,
  }) {
    return _then(_value.copyWith(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as Role,
      targetPlayerId: null == targetPlayerId
          ? _value.targetPlayerId
          : targetPlayerId // ignore: cast_nullable_to_non_nullable
              as String,
      roundNumber: null == roundNumber
          ? _value.roundNumber
          : roundNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NightActionImplCopyWith<$Res>
    implements $NightActionCopyWith<$Res> {
  factory _$$NightActionImplCopyWith(
          _$NightActionImpl value, $Res Function(_$NightActionImpl) then) =
      __$$NightActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String gameId,
      String playerId,
      Role role,
      String targetPlayerId,
      int roundNumber});
}

/// @nodoc
class __$$NightActionImplCopyWithImpl<$Res>
    extends _$NightActionCopyWithImpl<$Res, _$NightActionImpl>
    implements _$$NightActionImplCopyWith<$Res> {
  __$$NightActionImplCopyWithImpl(
      _$NightActionImpl _value, $Res Function(_$NightActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of NightAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playerId = null,
    Object? role = null,
    Object? targetPlayerId = null,
    Object? roundNumber = null,
  }) {
    return _then(_$NightActionImpl(
      gameId: null == gameId
          ? _value.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as Role,
      targetPlayerId: null == targetPlayerId
          ? _value.targetPlayerId
          : targetPlayerId // ignore: cast_nullable_to_non_nullable
              as String,
      roundNumber: null == roundNumber
          ? _value.roundNumber
          : roundNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NightActionImpl implements _NightAction {
  const _$NightActionImpl(
      {required this.gameId,
      required this.playerId,
      required this.role,
      required this.targetPlayerId,
      required this.roundNumber});

  factory _$NightActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$NightActionImplFromJson(json);

  @override
  final String gameId;
  @override
  final String playerId;
  @override
  final Role role;
  @override
  final String targetPlayerId;
  @override
  final int roundNumber;

  @override
  String toString() {
    return 'NightAction(gameId: $gameId, playerId: $playerId, role: $role, targetPlayerId: $targetPlayerId, roundNumber: $roundNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NightActionImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.targetPlayerId, targetPlayerId) ||
                other.targetPlayerId == targetPlayerId) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, gameId, playerId, role, targetPlayerId, roundNumber);

  /// Create a copy of NightAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NightActionImplCopyWith<_$NightActionImpl> get copyWith =>
      __$$NightActionImplCopyWithImpl<_$NightActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NightActionImplToJson(
      this,
    );
  }
}

abstract class _NightAction implements NightAction {
  const factory _NightAction(
      {required final String gameId,
      required final String playerId,
      required final Role role,
      required final String targetPlayerId,
      required final int roundNumber}) = _$NightActionImpl;

  factory _NightAction.fromJson(Map<String, dynamic> json) =
      _$NightActionImpl.fromJson;

  @override
  String get gameId;
  @override
  String get playerId;
  @override
  Role get role;
  @override
  String get targetPlayerId;
  @override
  int get roundNumber;

  /// Create a copy of NightAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NightActionImplCopyWith<_$NightActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

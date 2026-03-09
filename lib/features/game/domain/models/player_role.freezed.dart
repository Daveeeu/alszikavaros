// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_role.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlayerRole _$PlayerRoleFromJson(Map<String, dynamic> json) {
  return _PlayerRole.fromJson(json);
}

/// @nodoc
mixin _$PlayerRole {
  String get gameId => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  Role get role => throw _privateConstructorUsedError;

  /// Serializes this PlayerRole to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerRoleCopyWith<PlayerRole> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerRoleCopyWith<$Res> {
  factory $PlayerRoleCopyWith(
          PlayerRole value, $Res Function(PlayerRole) then) =
      _$PlayerRoleCopyWithImpl<$Res, PlayerRole>;
  @useResult
  $Res call({String gameId, String playerId, Role role});
}

/// @nodoc
class _$PlayerRoleCopyWithImpl<$Res, $Val extends PlayerRole>
    implements $PlayerRoleCopyWith<$Res> {
  _$PlayerRoleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playerId = null,
    Object? role = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayerRoleImplCopyWith<$Res>
    implements $PlayerRoleCopyWith<$Res> {
  factory _$$PlayerRoleImplCopyWith(
          _$PlayerRoleImpl value, $Res Function(_$PlayerRoleImpl) then) =
      __$$PlayerRoleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String gameId, String playerId, Role role});
}

/// @nodoc
class __$$PlayerRoleImplCopyWithImpl<$Res>
    extends _$PlayerRoleCopyWithImpl<$Res, _$PlayerRoleImpl>
    implements _$$PlayerRoleImplCopyWith<$Res> {
  __$$PlayerRoleImplCopyWithImpl(
      _$PlayerRoleImpl _value, $Res Function(_$PlayerRoleImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlayerRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? playerId = null,
    Object? role = null,
  }) {
    return _then(_$PlayerRoleImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerRoleImpl implements _PlayerRole {
  const _$PlayerRoleImpl(
      {required this.gameId, required this.playerId, required this.role});

  factory _$PlayerRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerRoleImplFromJson(json);

  @override
  final String gameId;
  @override
  final String playerId;
  @override
  final Role role;

  @override
  String toString() {
    return 'PlayerRole(gameId: $gameId, playerId: $playerId, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerRoleImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gameId, playerId, role);

  /// Create a copy of PlayerRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerRoleImplCopyWith<_$PlayerRoleImpl> get copyWith =>
      __$$PlayerRoleImplCopyWithImpl<_$PlayerRoleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerRoleImplToJson(
      this,
    );
  }
}

abstract class _PlayerRole implements PlayerRole {
  const factory _PlayerRole(
      {required final String gameId,
      required final String playerId,
      required final Role role}) = _$PlayerRoleImpl;

  factory _PlayerRole.fromJson(Map<String, dynamic> json) =
      _$PlayerRoleImpl.fromJson;

  @override
  String get gameId;
  @override
  String get playerId;
  @override
  Role get role;

  /// Create a copy of PlayerRole
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerRoleImplCopyWith<_$PlayerRoleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

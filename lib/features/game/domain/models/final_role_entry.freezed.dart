// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'final_role_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FinalRoleEntry _$FinalRoleEntryFromJson(Map<String, dynamic> json) {
  return _FinalRoleEntry.fromJson(json);
}

/// @nodoc
mixin _$FinalRoleEntry {
  String get playerId => throw _privateConstructorUsedError;
  String get playerName => throw _privateConstructorUsedError;
  Role get role => throw _privateConstructorUsedError;
  bool get isAlive => throw _privateConstructorUsedError;

  /// Serializes this FinalRoleEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinalRoleEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinalRoleEntryCopyWith<FinalRoleEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinalRoleEntryCopyWith<$Res> {
  factory $FinalRoleEntryCopyWith(
          FinalRoleEntry value, $Res Function(FinalRoleEntry) then) =
      _$FinalRoleEntryCopyWithImpl<$Res, FinalRoleEntry>;
  @useResult
  $Res call({String playerId, String playerName, Role role, bool isAlive});
}

/// @nodoc
class _$FinalRoleEntryCopyWithImpl<$Res, $Val extends FinalRoleEntry>
    implements $FinalRoleEntryCopyWith<$Res> {
  _$FinalRoleEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinalRoleEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? playerName = null,
    Object? role = null,
    Object? isAlive = null,
  }) {
    return _then(_value.copyWith(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      playerName: null == playerName
          ? _value.playerName
          : playerName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as Role,
      isAlive: null == isAlive
          ? _value.isAlive
          : isAlive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FinalRoleEntryImplCopyWith<$Res>
    implements $FinalRoleEntryCopyWith<$Res> {
  factory _$$FinalRoleEntryImplCopyWith(_$FinalRoleEntryImpl value,
          $Res Function(_$FinalRoleEntryImpl) then) =
      __$$FinalRoleEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String playerId, String playerName, Role role, bool isAlive});
}

/// @nodoc
class __$$FinalRoleEntryImplCopyWithImpl<$Res>
    extends _$FinalRoleEntryCopyWithImpl<$Res, _$FinalRoleEntryImpl>
    implements _$$FinalRoleEntryImplCopyWith<$Res> {
  __$$FinalRoleEntryImplCopyWithImpl(
      _$FinalRoleEntryImpl _value, $Res Function(_$FinalRoleEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of FinalRoleEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? playerName = null,
    Object? role = null,
    Object? isAlive = null,
  }) {
    return _then(_$FinalRoleEntryImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      playerName: null == playerName
          ? _value.playerName
          : playerName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as Role,
      isAlive: null == isAlive
          ? _value.isAlive
          : isAlive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FinalRoleEntryImpl implements _FinalRoleEntry {
  const _$FinalRoleEntryImpl(
      {required this.playerId,
      required this.playerName,
      required this.role,
      required this.isAlive});

  factory _$FinalRoleEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinalRoleEntryImplFromJson(json);

  @override
  final String playerId;
  @override
  final String playerName;
  @override
  final Role role;
  @override
  final bool isAlive;

  @override
  String toString() {
    return 'FinalRoleEntry(playerId: $playerId, playerName: $playerName, role: $role, isAlive: $isAlive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinalRoleEntryImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.playerName, playerName) ||
                other.playerName == playerName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isAlive, isAlive) || other.isAlive == isAlive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, playerId, playerName, role, isAlive);

  /// Create a copy of FinalRoleEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinalRoleEntryImplCopyWith<_$FinalRoleEntryImpl> get copyWith =>
      __$$FinalRoleEntryImplCopyWithImpl<_$FinalRoleEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FinalRoleEntryImplToJson(
      this,
    );
  }
}

abstract class _FinalRoleEntry implements FinalRoleEntry {
  const factory _FinalRoleEntry(
      {required final String playerId,
      required final String playerName,
      required final Role role,
      required final bool isAlive}) = _$FinalRoleEntryImpl;

  factory _FinalRoleEntry.fromJson(Map<String, dynamic> json) =
      _$FinalRoleEntryImpl.fromJson;

  @override
  String get playerId;
  @override
  String get playerName;
  @override
  Role get role;
  @override
  bool get isAlive;

  /// Create a copy of FinalRoleEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinalRoleEntryImplCopyWith<_$FinalRoleEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

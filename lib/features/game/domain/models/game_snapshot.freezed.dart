// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GameSnapshot _$GameSnapshotFromJson(Map<String, dynamic> json) {
  return _GameSnapshot.fromJson(json);
}

/// @nodoc
mixin _$GameSnapshot {
  Room get room => throw _privateConstructorUsedError;
  List<Player> get players => throw _privateConstructorUsedError;
  Game get game => throw _privateConstructorUsedError;
  PlayerRole? get currentPlayerRole => throw _privateConstructorUsedError;
  String get currentPlayerId => throw _privateConstructorUsedError;
  LatestVoteResult? get latestVoteResult => throw _privateConstructorUsedError;
  List<FinalRoleEntry> get finalRoles => throw _privateConstructorUsedError;

  /// Serializes this GameSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSnapshotCopyWith<GameSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSnapshotCopyWith<$Res> {
  factory $GameSnapshotCopyWith(
          GameSnapshot value, $Res Function(GameSnapshot) then) =
      _$GameSnapshotCopyWithImpl<$Res, GameSnapshot>;
  @useResult
  $Res call(
      {Room room,
      List<Player> players,
      Game game,
      PlayerRole? currentPlayerRole,
      String currentPlayerId,
      LatestVoteResult? latestVoteResult,
      List<FinalRoleEntry> finalRoles});

  $RoomCopyWith<$Res> get room;
  $GameCopyWith<$Res> get game;
  $PlayerRoleCopyWith<$Res>? get currentPlayerRole;
  $LatestVoteResultCopyWith<$Res>? get latestVoteResult;
}

/// @nodoc
class _$GameSnapshotCopyWithImpl<$Res, $Val extends GameSnapshot>
    implements $GameSnapshotCopyWith<$Res> {
  _$GameSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? room = null,
    Object? players = null,
    Object? game = null,
    Object? currentPlayerRole = freezed,
    Object? currentPlayerId = null,
    Object? latestVoteResult = freezed,
    Object? finalRoles = null,
  }) {
    return _then(_value.copyWith(
      room: null == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as Room,
      players: null == players
          ? _value.players
          : players // ignore: cast_nullable_to_non_nullable
              as List<Player>,
      game: null == game
          ? _value.game
          : game // ignore: cast_nullable_to_non_nullable
              as Game,
      currentPlayerRole: freezed == currentPlayerRole
          ? _value.currentPlayerRole
          : currentPlayerRole // ignore: cast_nullable_to_non_nullable
              as PlayerRole?,
      currentPlayerId: null == currentPlayerId
          ? _value.currentPlayerId
          : currentPlayerId // ignore: cast_nullable_to_non_nullable
              as String,
      latestVoteResult: freezed == latestVoteResult
          ? _value.latestVoteResult
          : latestVoteResult // ignore: cast_nullable_to_non_nullable
              as LatestVoteResult?,
      finalRoles: null == finalRoles
          ? _value.finalRoles
          : finalRoles // ignore: cast_nullable_to_non_nullable
              as List<FinalRoleEntry>,
    ) as $Val);
  }

  /// Create a copy of GameSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoomCopyWith<$Res> get room {
    return $RoomCopyWith<$Res>(_value.room, (value) {
      return _then(_value.copyWith(room: value) as $Val);
    });
  }

  /// Create a copy of GameSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameCopyWith<$Res> get game {
    return $GameCopyWith<$Res>(_value.game, (value) {
      return _then(_value.copyWith(game: value) as $Val);
    });
  }

  /// Create a copy of GameSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerRoleCopyWith<$Res>? get currentPlayerRole {
    if (_value.currentPlayerRole == null) {
      return null;
    }

    return $PlayerRoleCopyWith<$Res>(_value.currentPlayerRole!, (value) {
      return _then(_value.copyWith(currentPlayerRole: value) as $Val);
    });
  }

  /// Create a copy of GameSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LatestVoteResultCopyWith<$Res>? get latestVoteResult {
    if (_value.latestVoteResult == null) {
      return null;
    }

    return $LatestVoteResultCopyWith<$Res>(_value.latestVoteResult!, (value) {
      return _then(_value.copyWith(latestVoteResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameSnapshotImplCopyWith<$Res>
    implements $GameSnapshotCopyWith<$Res> {
  factory _$$GameSnapshotImplCopyWith(
          _$GameSnapshotImpl value, $Res Function(_$GameSnapshotImpl) then) =
      __$$GameSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Room room,
      List<Player> players,
      Game game,
      PlayerRole? currentPlayerRole,
      String currentPlayerId,
      LatestVoteResult? latestVoteResult,
      List<FinalRoleEntry> finalRoles});

  @override
  $RoomCopyWith<$Res> get room;
  @override
  $GameCopyWith<$Res> get game;
  @override
  $PlayerRoleCopyWith<$Res>? get currentPlayerRole;
  @override
  $LatestVoteResultCopyWith<$Res>? get latestVoteResult;
}

/// @nodoc
class __$$GameSnapshotImplCopyWithImpl<$Res>
    extends _$GameSnapshotCopyWithImpl<$Res, _$GameSnapshotImpl>
    implements _$$GameSnapshotImplCopyWith<$Res> {
  __$$GameSnapshotImplCopyWithImpl(
      _$GameSnapshotImpl _value, $Res Function(_$GameSnapshotImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? room = null,
    Object? players = null,
    Object? game = null,
    Object? currentPlayerRole = freezed,
    Object? currentPlayerId = null,
    Object? latestVoteResult = freezed,
    Object? finalRoles = null,
  }) {
    return _then(_$GameSnapshotImpl(
      room: null == room
          ? _value.room
          : room // ignore: cast_nullable_to_non_nullable
              as Room,
      players: null == players
          ? _value._players
          : players // ignore: cast_nullable_to_non_nullable
              as List<Player>,
      game: null == game
          ? _value.game
          : game // ignore: cast_nullable_to_non_nullable
              as Game,
      currentPlayerRole: freezed == currentPlayerRole
          ? _value.currentPlayerRole
          : currentPlayerRole // ignore: cast_nullable_to_non_nullable
              as PlayerRole?,
      currentPlayerId: null == currentPlayerId
          ? _value.currentPlayerId
          : currentPlayerId // ignore: cast_nullable_to_non_nullable
              as String,
      latestVoteResult: freezed == latestVoteResult
          ? _value.latestVoteResult
          : latestVoteResult // ignore: cast_nullable_to_non_nullable
              as LatestVoteResult?,
      finalRoles: null == finalRoles
          ? _value._finalRoles
          : finalRoles // ignore: cast_nullable_to_non_nullable
              as List<FinalRoleEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSnapshotImpl implements _GameSnapshot {
  const _$GameSnapshotImpl(
      {required this.room,
      required final List<Player> players,
      required this.game,
      this.currentPlayerRole,
      required this.currentPlayerId,
      this.latestVoteResult,
      final List<FinalRoleEntry> finalRoles = const <FinalRoleEntry>[]})
      : _players = players,
        _finalRoles = finalRoles;

  factory _$GameSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSnapshotImplFromJson(json);

  @override
  final Room room;
  final List<Player> _players;
  @override
  List<Player> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  @override
  final Game game;
  @override
  final PlayerRole? currentPlayerRole;
  @override
  final String currentPlayerId;
  @override
  final LatestVoteResult? latestVoteResult;
  final List<FinalRoleEntry> _finalRoles;
  @override
  @JsonKey()
  List<FinalRoleEntry> get finalRoles {
    if (_finalRoles is EqualUnmodifiableListView) return _finalRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_finalRoles);
  }

  @override
  String toString() {
    return 'GameSnapshot(room: $room, players: $players, game: $game, currentPlayerRole: $currentPlayerRole, currentPlayerId: $currentPlayerId, latestVoteResult: $latestVoteResult, finalRoles: $finalRoles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSnapshotImpl &&
            (identical(other.room, room) || other.room == room) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            (identical(other.game, game) || other.game == game) &&
            (identical(other.currentPlayerRole, currentPlayerRole) ||
                other.currentPlayerRole == currentPlayerRole) &&
            (identical(other.currentPlayerId, currentPlayerId) ||
                other.currentPlayerId == currentPlayerId) &&
            (identical(other.latestVoteResult, latestVoteResult) ||
                other.latestVoteResult == latestVoteResult) &&
            const DeepCollectionEquality()
                .equals(other._finalRoles, _finalRoles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      room,
      const DeepCollectionEquality().hash(_players),
      game,
      currentPlayerRole,
      currentPlayerId,
      latestVoteResult,
      const DeepCollectionEquality().hash(_finalRoles));

  /// Create a copy of GameSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSnapshotImplCopyWith<_$GameSnapshotImpl> get copyWith =>
      __$$GameSnapshotImplCopyWithImpl<_$GameSnapshotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSnapshotImplToJson(
      this,
    );
  }
}

abstract class _GameSnapshot implements GameSnapshot {
  const factory _GameSnapshot(
      {required final Room room,
      required final List<Player> players,
      required final Game game,
      final PlayerRole? currentPlayerRole,
      required final String currentPlayerId,
      final LatestVoteResult? latestVoteResult,
      final List<FinalRoleEntry> finalRoles}) = _$GameSnapshotImpl;

  factory _GameSnapshot.fromJson(Map<String, dynamic> json) =
      _$GameSnapshotImpl.fromJson;

  @override
  Room get room;
  @override
  List<Player> get players;
  @override
  Game get game;
  @override
  PlayerRole? get currentPlayerRole;
  @override
  String get currentPlayerId;
  @override
  LatestVoteResult? get latestVoteResult;
  @override
  List<FinalRoleEntry> get finalRoles;

  /// Create a copy of GameSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSnapshotImplCopyWith<_$GameSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

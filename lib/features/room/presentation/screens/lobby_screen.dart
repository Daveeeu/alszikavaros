import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/enums/room_status.dart';
import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/design/empty_state.dart';
import '../../../../core/presentation/widgets/design/error_banner.dart';
import '../../../../core/presentation/widgets/design/phase_header.dart';
import '../../../../core/presentation/widgets/design/player_list_item.dart';
import '../../../../core/presentation/widgets/design/primary_button.dart';
import '../../../../core/presentation/widgets/design/room_code_card.dart';
import '../../../../core/presentation/widgets/design/secondary_button.dart';
import '../../../../core/router/route_paths.dart';
import '../../../realtime/application/websocket_notifier.dart';
import '../../application/room_notifier.dart';
import '../../data/room_api_provider.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({required this.roomCode, super.key});

  final String roomCode;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  Timer? _pollingTimer;

  List<_LobbyPlayer> _players = <_LobbyPlayer>[];
  String? _hostPlayerId;
  RoomStatus _roomStatus = RoomStatus.waiting;

  bool _isLoading = true;
  bool _isStarting = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await _reloadRoomState();
      await ref.read(webSocketNotifierProvider.notifier).connect(widget.roomCode);
      _pollingTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _reloadRoomState(silent: true),
      );
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _reloadRoomState({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
    }

    try {
      final response = await ref.read(roomApiServiceProvider).getRoom(widget.roomCode);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('invalid payload');
      }

      final statusRaw = (data['status'] as String? ?? 'waiting').toLowerCase();
      final status = switch (statusRaw) {
        'in_game' => RoomStatus.inGame,
        'finished' => RoomStatus.finished,
        _ => RoomStatus.waiting,
      };

      final players = (data['players'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_LobbyPlayer.fromMap)
          .toList(growable: false);

      setState(() {
        _roomStatus = status;
        _hostPlayerId = data['hostPlayerId'] as String?;
        _players = players;
        _isLoading = false;
        _error = '';
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Nem sikerült betölteni a szoba állapotát.';
      });
    }
  }

  Future<void> _startGame() async {
    if (_isStarting) return;

    setState(() {
      _isStarting = true;
      _error = '';
    });

    try {
      final response = await ref.read(roomApiServiceProvider).startGame(widget.roomCode);
      final data = response.data;
      final gameId = data is Map<String, dynamic> ? data['gameId'] as String? : null;

      if (gameId == null || gameId.isEmpty) {
        throw Exception('missing game id');
      }

      if (!mounted) return;
      context.go(RoutePaths.roleRevealByGameId(gameId));
    } catch (_) {
      setState(() {
        _isStarting = false;
        _error = 'Nem sikerült elindítani a játékot.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomNotifierProvider);
    final isHost = roomState.isHost;

    ref.listen<WebSocketState>(webSocketNotifierProvider, (previous, next) {
      final event = next.lastEvent;
      if (event == null) return;

      final eventName = event['event'] as String?;
      final payload = event['payload'];
      if (eventName == 'room.updated') {
        _reloadRoomState(silent: true);
        return;
      }

      if (eventName == 'game.started' && payload is Map<String, dynamic>) {
        final gameId = payload['gameId'] as String?;
        if (gameId != null && gameId.isNotEmpty && context.mounted) {
          context.go(RoutePaths.roleRevealByGameId(gameId));
        }
      }
    });

    return AppScaffold(
      title: 'Lobby',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PhaseHeader(
            title: 'Váró',
            subtitle: 'Várakozás a játékosokra és a játék indítására.',
          ),
          const SizedBox(height: 12),
          RoomCodeCard(roomCode: widget.roomCode),
          const SizedBox(height: 14),
          Text('Játékosok', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _players.isEmpty
                    ? const EmptyState(
                        message: 'Még nincs játékos a szobában.',
                        icon: Icons.groups_outlined,
                      )
                    : ListView.separated(
                        itemCount: _players.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final player = _players[index];
                          return PlayerListItem(
                            name: player.name,
                            isHost: player.id == _hostPlayerId || player.isHost,
                            isAlive: player.isAlive,
                          );
                        },
                      ),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 10),
            ErrorBanner(
              message: _error,
              onRetry: () => _reloadRoomState(),
            ),
          ],
          const SizedBox(height: 12),
          if (isHost)
            PrimaryButton(
              label: _roomStatus == RoomStatus.inGame
                  ? 'Játék folyamatban'
                  : 'Játék indítása',
              icon: Icons.play_arrow_rounded,
              isLoading: _isStarting,
              onPressed: _roomStatus == RoomStatus.inGame ? null : _startGame,
            )
          else
            const SecondaryButton(
              label: 'A hoszt indíthatja a játékot',
              icon: Icons.hourglass_empty_rounded,
              onPressed: null,
            ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Szoba elhagyása',
            icon: Icons.exit_to_app_rounded,
            onPressed: () {
              ref.read(roomNotifierProvider.notifier).clearCurrentRoom();
              context.go(RoutePaths.home);
            },
          ),
        ],
      ),
    );
  }
}

class _LobbyPlayer {
  const _LobbyPlayer({
    required this.id,
    required this.name,
    required this.isHost,
    required this.isAlive,
    required this.isConnected,
  });

  final String id;
  final String name;
  final bool isHost;
  final bool isAlive;
  final bool isConnected;

  factory _LobbyPlayer.fromMap(Map<String, dynamic> map) {
    return _LobbyPlayer(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Játékos',
      isHost: map['isHost'] as bool? ?? false,
      isAlive: map['isAlive'] as bool? ?? true,
      isConnected: map['isConnected'] as bool? ?? true,
    );
  }
}

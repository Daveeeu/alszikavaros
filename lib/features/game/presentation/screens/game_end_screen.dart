import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/enums/game_phase.dart';
import '../../../../core/domain/enums/role.dart';
import '../../../../core/domain/enums/winner_type.dart';
import '../../../../core/presentation/widgets/app_error_state.dart';
import '../../../../core/presentation/widgets/app_loading_state.dart';
import '../../../../core/presentation/widgets/design/empty_state.dart';
import '../../../../core/presentation/widgets/design/error_banner.dart';
import '../../../../core/presentation/widgets/design/phase_header.dart';
import '../../../../core/presentation/widgets/design/player_list_item.dart';
import '../../../../core/presentation/widgets/design/primary_button.dart';
import '../../../../core/presentation/widgets/design/secondary_button.dart';
import '../../../../core/presentation/widgets/reconnecting_indicator.dart';
import '../../../../core/router/route_paths.dart';
import '../../../realtime/application/websocket_notifier.dart';
import '../../../room/application/room_notifier.dart';
import '../../application/game_notifier.dart';
import '../../domain/models/final_role_entry.dart';
import '../phase_route_resolver.dart';

class GameEndScreen extends ConsumerStatefulWidget {
  const GameEndScreen({required this.gameId, super.key});

  final String gameId;

  @override
  ConsumerState<GameEndScreen> createState() => _GameEndScreenState();
}

class _GameEndScreenState extends ConsumerState<GameEndScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(gameNotifierProvider.notifier).initialize(
            gameId: widget.gameId,
          );
      ref.read(gameNotifierProvider.notifier).startPolling();
      _ensureRealtimeConnected(ref.read(gameNotifierProvider).roomCode);
    });
  }

  @override
  void dispose() {
    ref.read(gameNotifierProvider.notifier).stopPolling();
    super.dispose();
  }

  void _ensureRealtimeConnected(String? roomCode) {
    if (roomCode == null || roomCode.isEmpty) return;
    ref.read(webSocketNotifierProvider.notifier).connect(roomCode);
  }

  Future<void> _retryLoad() async {
    await ref.read(gameNotifierProvider.notifier).refresh();
    _ensureRealtimeConnected(ref.read(gameNotifierProvider).roomCode);
    await ref.read(webSocketNotifierProvider.notifier).retry();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameNotifierProvider, (previous, next) {
      if (next.roomCode != previous?.roomCode) {
        _ensureRealtimeConnected(next.roomCode);
      }

      final phase = next.phase;
      if (phase == null || phase == GamePhase.ended) {
        return;
      }

      final nextRoute = routeForPhase(phase: phase, gameId: widget.gameId);
      if (nextRoute != null && context.mounted) {
        context.go(nextRoute);
      }
    });

    final gameState = ref.watch(gameNotifierProvider);
    final isHost = ref.watch(roomNotifierProvider).isHost;

    return Scaffold(
      appBar: AppBar(title: const Text('Játék vége')),
      body: Column(
        children: [
          const ReconnectingIndicator(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _GameEndContent(
                gameState: gameState,
                isHost: isHost,
                onRestart: () => ref.read(gameNotifierProvider.notifier).restartGame(),
                onLeaveHome: () {
                  ref.read(roomNotifierProvider.notifier).clearCurrentRoom();
                  context.go(RoutePaths.home);
                },
                onRetry: _retryLoad,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameEndContent extends StatelessWidget {
  const _GameEndContent({
    required this.gameState,
    required this.isHost,
    required this.onRestart,
    required this.onLeaveHome,
    required this.onRetry,
  });

  final GameState gameState;
  final bool isHost;
  final VoidCallback onRestart;
  final VoidCallback onLeaveHome;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (gameState.isLoading && gameState.finalRoles.isEmpty) {
      return const AppLoadingState(message: 'Játék végi összegzés betöltése...');
    }

    if (gameState.error.isNotEmpty &&
        gameState.finalRoles.isEmpty &&
        gameState.winner == WinnerType.none) {
      return AppErrorState(
        message: gameState.error,
        onRetry: onRetry,
      );
    }

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        children: [
          PhaseHeader(
            title: 'Játék vége',
            subtitle: 'Győztes: ${_winnerLabel(gameState.winner)}',
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Végső szerepek',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (gameState.finalRoles.isEmpty)
                    const EmptyState(
                      message:
                          'A backend nem adott végső szerep-listát ehhez a játékhoz.',
                      icon: Icons.badge_outlined,
                    )
                  else
                    ...gameState.finalRoles.map(
                      (roleEntry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _FinalRoleTile(roleEntry: roleEntry),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (gameState.error.isNotEmpty) ...[
            const SizedBox(height: 12),
            ErrorBanner(
              message: 'Frissítési hiba: ${gameState.error}',
              onRetry: onRetry,
            ),
          ],
          if (gameState.restartError.isNotEmpty) ...[
            const SizedBox(height: 12),
            ErrorBanner(message: gameState.restartError),
          ],
          const SizedBox(height: 12),
          if (isHost)
            PrimaryButton(
              label: 'Játék újraindítása',
              icon: Icons.restart_alt_rounded,
              isLoading: gameState.isRestarting,
              onPressed: gameState.isRestarting ? null : onRestart,
            )
          else
            const SecondaryButton(
              label: 'A hosztra várakozás',
              icon: Icons.hourglass_top_rounded,
              onPressed: null,
            ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Vissza a főmenübe',
            icon: Icons.home_outlined,
            onPressed: onLeaveHome,
          ),
        ],
      ),
    );
  }

  String _winnerLabel(WinnerType winner) {
    switch (winner) {
      case WinnerType.villagers:
        return 'Falusiak';
      case WinnerType.killers:
        return 'Gyilkosok';
      case WinnerType.none:
        return 'Nincs győztes';
    }
  }
}

class _FinalRoleTile extends StatelessWidget {
  const _FinalRoleTile({required this.roleEntry});

  final FinalRoleEntry roleEntry;

  @override
  Widget build(BuildContext context) {
    return PlayerListItem(
      name: '${roleEntry.playerName} (${_roleLabel(roleEntry.role)})',
      isAlive: roleEntry.isAlive,
    );
  }

  String _roleLabel(Role role) {
    switch (role) {
      case Role.killer:
        return 'Gyilkos';
      case Role.doctor:
        return 'Doktor';
      case Role.villager:
        return 'Falusi';
    }
  }
}

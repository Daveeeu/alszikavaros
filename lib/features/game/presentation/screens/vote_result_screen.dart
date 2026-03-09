import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/enums/game_phase.dart';
import '../../../../core/presentation/widgets/app_error_state.dart';
import '../../../../core/presentation/widgets/app_loading_state.dart';
import '../../../../core/presentation/widgets/design/empty_state.dart';
import '../../../../core/presentation/widgets/design/error_banner.dart';
import '../../../../core/presentation/widgets/design/phase_header.dart';
import '../../../../core/presentation/widgets/design/player_list_item.dart';
import '../../../../core/presentation/widgets/reconnecting_indicator.dart';
import '../../../realtime/application/websocket_notifier.dart';
import '../../application/game_notifier.dart';
import '../../domain/models/latest_vote_result.dart';
import '../../../room/domain/models/player.dart';
import '../phase_route_resolver.dart';

class VoteResultScreen extends ConsumerStatefulWidget {
  const VoteResultScreen({required this.gameId, super.key});

  final String gameId;

  @override
  ConsumerState<VoteResultScreen> createState() => _VoteResultScreenState();
}

class _VoteResultScreenState extends ConsumerState<VoteResultScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(gameNotifierProvider.notifier).initialize(
            gameId: widget.gameId,
          );
      ref.read(gameNotifierProvider.notifier).startPolling();

      final roomCode = ref.read(gameNotifierProvider).roomCode;
      _ensureRealtimeChannelConnected(roomCode);
    });
  }

  @override
  void dispose() {
    ref.read(gameNotifierProvider.notifier).stopPolling();
    super.dispose();
  }

  void _ensureRealtimeChannelConnected(String? roomCode) {
    if (roomCode == null || roomCode.isEmpty) return;
    ref.read(webSocketNotifierProvider.notifier).connect(roomCode);
  }

  Future<void> _retryLoad() async {
    await ref.read(gameNotifierProvider.notifier).refresh();
    final roomCode = ref.read(gameNotifierProvider).roomCode;
    _ensureRealtimeChannelConnected(roomCode);
    await ref.read(webSocketNotifierProvider.notifier).retry();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameNotifierProvider, (previous, next) {
      if (next.roomCode != previous?.roomCode) {
        _ensureRealtimeChannelConnected(next.roomCode);
      }

      final phase = next.phase;
      if (phase == null || phase == GamePhase.voteResult) {
        return;
      }

      final nextRoute = routeForPhase(phase: phase, gameId: widget.gameId);
      if (nextRoute != null && context.mounted) {
        context.go(nextRoute);
      }
    });

    final state = ref.watch(gameNotifierProvider);
    final result = state.latestVoteResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Szavazás eredménye')),
      body: Column(
        children: [
          const ReconnectingIndicator(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _VoteResultContent(
                isLoading: state.isLoading,
                error: state.error,
                dayNumber: state.dayNumber,
                result: result,
                alivePlayers: state.alivePlayers,
                onRetry: _retryLoad,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteResultContent extends StatelessWidget {
  const _VoteResultContent({
    required this.isLoading,
    required this.error,
    required this.dayNumber,
    required this.result,
    required this.alivePlayers,
    required this.onRetry,
  });

  final bool isLoading;
  final String error;
  final int dayNumber;
  final LatestVoteResult? result;
  final List<Player> alivePlayers;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading && result == null) {
      return const AppLoadingState(message: 'Szavazási eredmény betöltése...');
    }

    if (error.isNotEmpty && result == null) {
      return AppErrorState(
        message: error,
        onRetry: onRetry,
      );
    }

    final bool nobodyEliminated = result == null || result!.isTie;

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        children: [
          PhaseHeader(
            title: 'Nap: $dayNumber',
            subtitle: 'Szavazási összegzés',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eredmény',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nobodyEliminated
                        ? 'Döntetlen szavazás történt, senki sem esett ki.'
                        : '${result!.eliminatedPlayerName ?? 'Egy játékos'} kiesett a szavazás alapján.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ErrorBanner(
                      message: 'Frissítési hiba: $error',
                      onRetry: onRetry,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Élő játékosok',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (alivePlayers.isEmpty)
                    const EmptyState(
                      message: 'Nincs elérhető adat az élő játékosokról.',
                      icon: Icons.people_outline,
                    )
                  else
                    ...alivePlayers.map(
                      (player) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PlayerListItem(
                          name: player.name,
                          isAlive: player.isAlive,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Várakozás a következő fázisra...',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

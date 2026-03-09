import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/design/phase_header.dart';
import '../../../../core/presentation/widgets/design/primary_button.dart';
import '../../../../core/presentation/widgets/design/secondary_button.dart';
import '../../../../core/router/route_paths.dart';
import '../../../session/application/session_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionNotifierProvider);

    return AppScaffold(
      title: 'Alszik a Város',
      actions: [
        if (session.playerId != null)
          TextButton(
            onPressed: () {
              ref.read(sessionNotifierProvider.notifier).clearSession();
            },
            child: const Text('Kilépés'),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PhaseHeader(
            title: 'Alszik a Város',
            subtitle: 'Narrátor nélküli társas dedukciós játék',
          ),
          const SizedBox(height: 16),
          if (session.playerName != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Jelenlegi játékos: ${session.playerName}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const Spacer(),
          PrimaryButton(
            label: 'Szoba létrehozása / belépés',
            icon: Icons.groups_rounded,
            onPressed: () => context.push(RoutePaths.createOrJoin),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Csatlakozás kóddal',
            icon: Icons.key_rounded,
            onPressed: () => context.push(RoutePaths.join),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../session/application/session_notifier.dart';
import '../../../session/domain/session_state_status.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(sessionNotifierProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionNotifierProvider);

    ref.listen(sessionNotifierProvider, (previous, next) {
      if (next.isReady && context.mounted) {
        context.go(RoutePaths.home);
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Alszik a Város',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (session.status == SessionStateStatus.failure)
              Column(
                children: [
                  Text(session.errorMessage),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      ref.read(sessionNotifierProvider.notifier).bootstrap();
                    },
                    child: const Text('Újrapróbálkozás'),
                  ),
                ],
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

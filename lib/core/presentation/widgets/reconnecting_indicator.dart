import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/realtime/application/websocket_notifier.dart';
import '../../../features/realtime/data/websocket_service.dart';

class ReconnectingIndicator extends ConsumerWidget {
  const ReconnectingIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketState = ref.watch(webSocketNotifierProvider);

    final show = socketState.status == WebSocketConnectionStatus.reconnecting ||
        socketState.status == WebSocketConnectionStatus.connecting ||
        socketState.status == WebSocketConnectionStatus.error;

    if (!show) {
      return const SizedBox.shrink();
    }

    final text = switch (socketState.status) {
      WebSocketConnectionStatus.connecting => 'Kapcsolódás...',
      WebSocketConnectionStatus.reconnecting => 'Újracsatlakozás...',
      WebSocketConnectionStatus.error => socketState.errorMessage.isEmpty
          ? 'Kapcsolati hiba, újrapróbálkozás...'
          : socketState.errorMessage,
      _ => '',
    };

    return Material(
      color: Colors.orange.shade700,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(webSocketNotifierProvider.notifier).retry(),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/mock/mock_websocket_service.dart';
import '../data/websocket_service.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = AppConstants.useMockBackend
      ? MockWebSocketService()
      : WebSocketService();

  ref.onDispose(service.dispose);
  return service;
});

final webSocketNotifierProvider =
    StateNotifierProvider<WebSocketNotifier, WebSocketState>((ref) {
  return WebSocketNotifier(ref.watch(webSocketServiceProvider));
});

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  WebSocketNotifier(this._service) : super(const WebSocketState()) {
    _eventSubscription = _service.events.listen((event) {
      state = state.copyWith(lastEvent: event, errorMessage: '');
    });

    _statusSubscription = _service.status.listen((status) {
      state = state.copyWith(
        status: status,
        errorMessage: status == WebSocketConnectionStatus.error
            ? 'WebSocket kapcsolat hiba.'
            : '',
      );
    });
  }

  final WebSocketService _service;
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;
  StreamSubscription<WebSocketConnectionStatus>? _statusSubscription;

  Future<void> connect(String roomCode) async {
    if (roomCode.trim().isEmpty) return;

    state = state.copyWith(activeRoomCode: roomCode.trim());
    await _service.connect(roomCode.trim());
  }

  Future<void> disconnect() async {
    await _service.disconnect();
  }

  Future<void> retry() async {
    await _service.retry();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }
}

class WebSocketState {
  const WebSocketState({
    this.status = WebSocketConnectionStatus.disconnected,
    this.lastEvent,
    this.activeRoomCode,
    this.errorMessage = '',
  });

  final WebSocketConnectionStatus status;
  final Map<String, dynamic>? lastEvent;
  final String? activeRoomCode;
  final String errorMessage;

  bool get isConnected => status == WebSocketConnectionStatus.connected;
  bool get isReconnecting =>
      status == WebSocketConnectionStatus.reconnecting ||
      status == WebSocketConnectionStatus.connecting;

  WebSocketState copyWith({
    WebSocketConnectionStatus? status,
    Map<String, dynamic>? lastEvent,
    String? activeRoomCode,
    String? errorMessage,
  }) {
    return WebSocketState(
      status: status ?? this.status,
      lastEvent: lastEvent ?? this.lastEvent,
      activeRoomCode: activeRoomCode ?? this.activeRoomCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

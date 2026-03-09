import 'dart:async';

import '../../../mock_backend/data/mock_backend_state.dart';
import '../websocket_service.dart';

class MockWebSocketService extends WebSocketService {
  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketConnectionStatus> _statusController =
      StreamController<WebSocketConnectionStatus>.broadcast();

  StreamSubscription<Map<String, dynamic>>? _backendSubscription;
  String? _roomCode;
  bool _disposed = false;

  @override
  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  @override
  Stream<WebSocketConnectionStatus> get status => _statusController.stream;

  @override
  Future<void> connect(
    String roomCode, {
    String? sessionToken,
    String? playerId,
  }) async {
    if (_disposed) return;

    _roomCode = roomCode.trim();
    if (_roomCode == null || _roomCode!.isEmpty) {
      return;
    }

    _statusController.add(WebSocketConnectionStatus.connecting);
    await _backendSubscription?.cancel();

    _backendSubscription = MockBackendState.instance.events.listen((event) {
      final eventRoom = event['roomCode'] as String?;
      if (eventRoom == _roomCode) {
        _eventsController.add(event);
      }
    });

    _statusController.add(WebSocketConnectionStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    await _backendSubscription?.cancel();
    _backendSubscription = null;
    _statusController.add(WebSocketConnectionStatus.disconnected);
  }

  @override
  Future<void> retry() async {
    final code = _roomCode;
    if (code == null || code.isEmpty) {
      _statusController.add(WebSocketConnectionStatus.error);
      return;
    }

    await connect(code);
  }

  @override
  void dispose() {
    _disposed = true;
    _backendSubscription?.cancel();
    _eventsController.close();
    _statusController.close();
  }
}

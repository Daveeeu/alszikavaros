import 'dart:async';

import 'package:alszik_a_varos/features/realtime/application/websocket_notifier.dart';
import 'package:alszik_a_varos/features/realtime/data/websocket_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWebSocketService extends WebSocketService {
  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketConnectionStatus> _statusController =
      StreamController<WebSocketConnectionStatus>.broadcast();

  String? lastConnectedRoom;
  bool didRetry = false;
  bool didDisconnect = false;

  @override
  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  @override
  Stream<WebSocketConnectionStatus> get status => _statusController.stream;

  @override
  Future<void> connect(String roomCode) async {
    lastConnectedRoom = roomCode;
    _statusController.add(WebSocketConnectionStatus.connected);
  }

  @override
  Future<void> retry() async {
    didRetry = true;
    _statusController.add(WebSocketConnectionStatus.reconnecting);
  }

  @override
  Future<void> disconnect() async {
    didDisconnect = true;
    _statusController.add(WebSocketConnectionStatus.disconnected);
  }

  void emitEvent(Map<String, dynamic> event) {
    _eventsController.add(event);
  }

  void emitStatus(WebSocketConnectionStatus status) {
    _statusController.add(status);
  }

  @override
  void dispose() {
    _eventsController.close();
    _statusController.close();
  }
}

void main() {
  group('WebSocketNotifier', () {
    test('connect sets active room code and connected status', () async {
      final service = _FakeWebSocketService();
      final notifier = WebSocketNotifier(service);

      await notifier.connect('ROOM42');

      expect(service.lastConnectedRoom, 'ROOM42');
      expect(notifier.state.activeRoomCode, 'ROOM42');
      expect(notifier.state.status, WebSocketConnectionStatus.connected);
      notifier.dispose();
      service.dispose();
    });

    test('updates state when websocket event arrives', () async {
      final service = _FakeWebSocketService();
      final notifier = WebSocketNotifier(service);

      service.emitEvent({'event': 'game.phase_changed'});
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.lastEvent?['event'], 'game.phase_changed');
      notifier.dispose();
      service.dispose();
    });

    test('updates status and error message on error status', () async {
      final service = _FakeWebSocketService();
      final notifier = WebSocketNotifier(service);

      service.emitStatus(WebSocketConnectionStatus.error);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.status, WebSocketConnectionStatus.error);
      expect(notifier.state.errorMessage, isNotEmpty);
      notifier.dispose();
      service.dispose();
    });
  });
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';

enum WebSocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;

  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketConnectionStatus> _statusController =
      StreamController<WebSocketConnectionStatus>.broadcast();

  Stream<Map<String, dynamic>> get events => _eventsController.stream;
  Stream<WebSocketConnectionStatus> get status => _statusController.stream;

  String? _roomCode;
  String? _sessionToken;
  String? _playerId;
  bool _manualDisconnect = false;
  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;
  bool _disposed = false;

  Future<void> connect(
    String roomCode, {
    String? sessionToken,
    String? playerId,
  }) async {
    if (_disposed) return;

    final normalizedRoomCode = roomCode.trim();
    if (normalizedRoomCode.isEmpty) return;

    final isSameRoom = _roomCode == normalizedRoomCode;
    if (isSameRoom && _channel != null) {
      return;
    }

    _manualDisconnect = false;
    _roomCode = normalizedRoomCode;
    _sessionToken =
        sessionToken?.trim().isEmpty ?? true ? null : sessionToken?.trim();
    _playerId = playerId?.trim().isEmpty ?? true ? null : playerId?.trim();
    _reconnectAttempt = 0;

    await _openConnection(isReconnect: false);
  }

  Future<void> _openConnection({required bool isReconnect}) async {
    if (_disposed || _roomCode == null) return;

    _reconnectTimer?.cancel();
    _statusController.add(
      isReconnect
          ? WebSocketConnectionStatus.reconnecting
          : WebSocketConnectionStatus.connecting,
    );

    await _closeChannel();

    final uri = Uri.parse(ApiConstants.wsBaseUrl).replace(
      queryParameters: <String, String>{
        'roomCode': _roomCode!,
        if (_sessionToken != null) 'sessionToken': _sessionToken!,
        if (_playerId != null) 'playerId': _playerId!,
      },
    );

    try {
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      await channel.ready;

      _channelSubscription = channel.stream.listen(
        _onMessage,
        onDone: _onConnectionLost,
        onError: (_) => _onConnectionLost(),
        cancelOnError: true,
      );

      _statusController.add(WebSocketConnectionStatus.connected);
      _reconnectAttempt = 0;
    } catch (error) {
      if (kDebugMode && AppConstants.enableNetworkLogs) {
        debugPrint('[WS] connect failed uri=$uri error=$error');
      }
      _statusController.add(WebSocketConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          _eventsController.add(decoded);
        }
      }
    } catch (_) {
      // Ignore malformed event payloads and keep socket alive.
    }
  }

  void _onConnectionLost() {
    if (_disposed || _manualDisconnect) {
      _statusController.add(WebSocketConnectionStatus.disconnected);
      return;
    }

    _statusController.add(WebSocketConnectionStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _manualDisconnect || _roomCode == null) return;

    _reconnectAttempt += 1;
    final seconds = AppConstants.reconnectDelay.inSeconds *
        (_reconnectAttempt > 3 ? 3 : _reconnectAttempt);
    final delay = Duration(seconds: seconds);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _openConnection(isReconnect: true);
    });
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    await _closeChannel();
    _statusController.add(WebSocketConnectionStatus.disconnected);
  }

  Future<void> retry() async {
    if (_roomCode == null) return;
    _manualDisconnect = false;
    await _openConnection(isReconnect: true);
  }

  Future<void> _closeChannel() async {
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _closeChannel();
    _eventsController.close();
    _statusController.close();
  }
}

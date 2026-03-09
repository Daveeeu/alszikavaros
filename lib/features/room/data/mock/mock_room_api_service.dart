import 'package:dio/dio.dart';

import '../../../mock_backend/data/mock_backend_state.dart';
import '../room_api_service.dart';

class MockRoomApiService extends RoomApiService {
  MockRoomApiService() : super(Dio());

  final MockBackendState _mock = MockBackendState.instance;

  @override
  Future<Response<dynamic>> createRoom(Map<String, dynamic> payload) async {
    final name = payload['playerName'] as String? ?? 'Játékos';
    return _mock.createRoom(name);
  }

  @override
  Future<Response<dynamic>> joinRoom(Map<String, dynamic> payload) async {
    final name = payload['playerName'] as String? ?? 'Játékos';
    final code = payload['roomCode'] as String? ?? '';
    return _mock.joinRoom(name, code);
  }

  @override
  Future<Response<dynamic>> getRoom(String code) async {
    return _mock.getRoomState(code);
  }

  @override
  Future<Response<dynamic>> leaveRoom(
    String code,
    Map<String, dynamic> payload,
  ) async {
    return _mock.leaveRoom(code, payload['playerId'] as String?);
  }

  @override
  Future<Response<dynamic>> startGame(String code) async {
    return _mock.startGame(code);
  }

  @override
  Future<Response<dynamic>> restartRoom(String code) async {
    return _mock.restartRoom(code);
  }
}

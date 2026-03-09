import 'package:dio/dio.dart';

import '../../../mock_backend/data/mock_backend_state.dart';
import '../game_api_service.dart';

class MockGameApiService extends GameApiService {
  MockGameApiService() : super(Dio());

  final MockBackendState _mock = MockBackendState.instance;

  @override
  Future<Response<dynamic>> getGameState(String gameId) async {
    return _mock.getGameState(gameId);
  }

  @override
  Future<Response<dynamic>> revealRole(
    String gameId,
    Map<String, dynamic> payload,
  ) async {
    return _mock.revealRole(gameId, payload);
  }

  @override
  Future<Response<dynamic>> submitNightAction(
    String gameId,
    Map<String, dynamic> payload,
  ) async {
    return _mock.submitNightAction(gameId, payload);
  }

  @override
  Future<Response<dynamic>> submitVote(
    String gameId,
    Map<String, dynamic> payload,
  ) async {
    return _mock.submitVote(gameId, payload);
  }
}

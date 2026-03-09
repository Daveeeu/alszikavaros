import 'package:dio/dio.dart';

class GameApiService {
  GameApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getGameState(String gameId) {
    return _dio.get('/games/$gameId/state');
  }

  Future<Response<dynamic>> revealRole(
    String gameId,
    Map<String, dynamic> payload,
  ) {
    return _dio.post('/games/$gameId/role/reveal', data: payload);
  }

  Future<Response<dynamic>> submitNightAction(
    String gameId,
    Map<String, dynamic> payload,
  ) {
    return _dio.post('/games/$gameId/actions', data: payload);
  }

  Future<Response<dynamic>> submitVote(
    String gameId,
    Map<String, dynamic> payload,
  ) {
    return _dio.post('/games/$gameId/votes', data: payload);
  }
}

import 'package:dio/dio.dart';

class RoomApiService {
  RoomApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> createRoom(Map<String, dynamic> payload) {
    return _dio.post('/rooms', data: payload);
  }

  Future<Response<dynamic>> joinRoom(Map<String, dynamic> payload) {
    return _dio.post('/rooms/join', data: payload);
  }

  Future<Response<dynamic>> getRoom(String code) {
    return _dio.get('/rooms/$code');
  }

  Future<Response<dynamic>> leaveRoom(
    String code,
    Map<String, dynamic> payload,
  ) {
    return _dio.post('/rooms/$code/leave', data: payload);
  }

  Future<Response<dynamic>> startGame(String code) {
    return _dio.post('/rooms/$code/start');
  }

  Future<Response<dynamic>> restartRoom(String code) {
    return _dio.post('/rooms/$code/restart');
  }
}

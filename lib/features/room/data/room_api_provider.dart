import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/app_dio_client.dart';
import '../../session/application/session_notifier.dart';
import 'mock/mock_room_api_service.dart';
import 'room_api_service.dart';

final roomApiServiceProvider = Provider<RoomApiService>((ref) {
  if (AppConstants.useMockBackend) {
    return MockRoomApiService();
  }

  final sessionToken = ref.watch(sessionNotifierProvider).sessionToken;
  return RoomApiService(AppDioClient(sessionToken: sessionToken).dio);
});

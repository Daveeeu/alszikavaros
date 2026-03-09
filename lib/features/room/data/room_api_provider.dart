import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/app_dio_client.dart';
import 'mock/mock_room_api_service.dart';
import 'room_api_service.dart';

final roomApiServiceProvider = Provider<RoomApiService>((ref) {
  if (AppConstants.useMockBackend) {
    return MockRoomApiService();
  }

  return RoomApiService(AppDioClient().dio);
});

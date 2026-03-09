import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class AppDioClient {
  AppDioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: AppConstants.networkTimeout,
            receiveTimeout: AppConstants.networkTimeout,
            sendTimeout: AppConstants.networkTimeout,
            headers: const {'Content-Type': 'application/json'},
          ),
        );

  final Dio dio;
}

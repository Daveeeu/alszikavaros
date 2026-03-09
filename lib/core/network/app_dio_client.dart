import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class AppDioClient {
  AppDioClient({String? sessionToken})
      : dio = Dio(_options(sessionToken: sessionToken)) {
    if (kDebugMode && AppConstants.enableNetworkLogs) {
      debugPrint(
        '[DIO] configured baseUrl=${ApiConstants.baseUrl} wsBaseUrl=${ApiConstants.wsBaseUrl} hasSessionToken=${sessionToken != null && sessionToken.isNotEmpty}',
      );

      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (message) => debugPrint('[DIO] $message'),
        ),
      );
    }
  }

  final Dio dio;

  static BaseOptions _options({String? sessionToken}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final normalizedToken = sessionToken?.trim();
    if (normalizedToken != null && normalizedToken.isNotEmpty) {
      headers['X-Session-Token'] = normalizedToken;
    }

    return BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: AppConstants.networkTimeout,
      receiveTimeout: AppConstants.networkTimeout,
      sendTimeout: AppConstants.networkTimeout,
      headers: headers,
    );
  }
}

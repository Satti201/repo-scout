import 'package:dio/dio.dart';

Dio createDioClient() {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/vnd.github+json'},
    ),
  );
}

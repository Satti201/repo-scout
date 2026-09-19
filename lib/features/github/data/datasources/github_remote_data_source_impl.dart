import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/github_repo_model.dart';
import '../models/github_user_model.dart';
import 'github_remote_data_source.dart';

class GitHubRemoteDataSourceImpl implements GitHubRemoteDataSource {
  final Dio dio;

  GitHubRemoteDataSourceImpl(this.dio);

  @override
  Future<List<GitHubUserModel>> searchUsers({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    try {
      final response = await dio.get(
        '/search/users',
        queryParameters: {'q': query, 'page': page, 'per_page': perPage},
      );

      final items = response.data['items'] as List;

      return items
          .map((item) => GitHubUserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
    } on TypeError {
      throw const ParsingException('Unable to parse GitHub response.');
    }
  }

  @override
  Future<GitHubUserModel> getUserProfile(String username) async {
    try {
      final response = await dio.get('/users/$username');

      return GitHubUserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioException(e);
    } on TypeError {
      throw const ParsingException('Unable to parse GitHub response.');
    }
  }

  @override
  Future<List<GitHubRepoModel>> getUserRepositories({
    required String username,
    int page = 1,
    int perPage = 30,
  }) async {
    try {
      final response = await dio.get(
        '/users/$username/repos',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      final data = response.data as List;

      return data
          .map((item) => GitHubRepoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
    } on TypeError {
      throw const ParsingException('Unable to parse GitHub response.');
    }
  }

  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw const NetworkException(
        'Unable to connect. Please check your internet connection.',
      );
    }

    final statusCode = e.response?.statusCode;

    if (statusCode == 404) {
      throw const NotFoundException('Requested GitHub resource was not found.');
    }

    if (statusCode == 403 || statusCode == 429) {
      throw const RateLimitException(
        'GitHub API rate limit reached. Please try again later.',
      );
    }

    throw const ServerException(
      'Something went wrong while communicating with GitHub.',
    );
  }
}

import 'package:dio/dio.dart';

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
    final response = await dio.get(
      '/search/users',
      queryParameters: {
        'q': query,
        'page': page,
        'per_page': perPage,
      },
    );

    final items = response.data['items'] as List;

    return items
        .map(
          (item) => GitHubUserModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<GitHubUserModel> getUserProfile(String username) async {
    final response = await dio.get('/users/$username');

    return GitHubUserModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<GitHubRepoModel>> getUserRepositories({
    required String username,
    int page = 1,
    int perPage = 30,
  }) async {
    final response = await dio.get(
      '/users/$username/repos',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    final data = response.data as List;

    return data
        .map(
          (item) => GitHubRepoModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}

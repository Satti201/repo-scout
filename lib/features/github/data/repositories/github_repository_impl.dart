import '../../domain/entities/github_repo_entity.dart';
import '../../domain/entities/github_user_entity.dart';
import '../../domain/repositories/github_repository.dart';
import '../datasources/github_remote_data_source.dart';

class GitHubRepositoryImpl implements GitHubRepository {
  final GitHubRemoteDataSource remoteDataSource;

  GitHubRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<GitHubUserEntity>> searchUsers({
    required String query,
    int page = 1,
    int perPage = 30,
  }) {
    return remoteDataSource.searchUsers(
      query: query,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<GitHubUserEntity> getUserProfile(String username) {
    return remoteDataSource.getUserProfile(username);
  }

  @override
  Future<List<GitHubRepoEntity>> getUserRepositories({
    required String username,
    int page = 1,
    int perPage = 30,
  }) {
    return remoteDataSource.getUserRepositories(
      username: username,
      page: page,
      perPage: perPage,
    );
  }
}

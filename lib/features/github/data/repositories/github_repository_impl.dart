import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/github_repo_entity.dart';
import '../../domain/entities/github_user_entity.dart';
import '../../domain/repositories/github_repository.dart';
import '../datasources/github_local_data_source.dart';
import '../datasources/github_remote_data_source.dart';
import '../models/github_repo_model.dart';
import '../models/github_user_model.dart';

class GitHubRepositoryImpl implements GitHubRepository {
  final GitHubRemoteDataSource remoteDataSource;
  final GitHubLocalDataSource localDataSource;

  GitHubRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<GitHubUserEntity>> searchUsers({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    return remoteDataSource.searchUsers(
      query: query,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<GitHubUserEntity> getUserProfile(String username) async {
    try {
      final user = await remoteDataSource.getUserProfile(username);
      await _cacheUserProfileSafely(user);
      return user;
    } on NetworkException {
      final cached = _getCachedUserProfile(username);
      if (cached != null) return cached;
      rethrow;
    } on ServerException {
      final cached = _getCachedUserProfile(username);
      if (cached != null) return cached;
      rethrow;
    } on RateLimitException {
      final cached = _getCachedUserProfile(username);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<GitHubRepoEntity>> getUserRepositories({
    required String username,
    int page = 1,
    int perPage = 30,
  }) async {
    try {
      final repositories = await remoteDataSource.getUserRepositories(
        username: username,
        page: page,
        perPage: perPage,
      );

      await _cacheRepositoriesSafely(
        username: username,
        page: page,
        repositories: repositories,
      );

      return repositories;
    } on NetworkException {
      final cached = _getCachedRepositories(
        username: username,
        page: page,
      );
      if (cached != null) return cached;
      rethrow;
    } on ServerException {
      final cached = _getCachedRepositories(
        username: username,
        page: page,
      );
      if (cached != null) return cached;
      rethrow;
    } on RateLimitException {
      final cached = _getCachedRepositories(
        username: username,
        page: page,
      );
      if (cached != null) return cached;
      rethrow;
    }
  }

  GitHubUserModel? _getCachedUserProfile(String username) {
    return localDataSource.getCachedUserProfile(username);
  }

  Future<void> _cacheUserProfileSafely(GitHubUserModel user) async {
    try {
      await localDataSource.cacheUserProfile(user);
    } catch (_) {
      // Cache failure should not fail an otherwise successful remote request.
    }
  }

  List<GitHubRepoModel>? _getCachedRepositories({
    required String username,
    required int page,
  }) {
    return localDataSource.getCachedUserRepositories(
      username: username,
      page: page,
    );
  }

  Future<void> _cacheRepositoriesSafely({
    required String username,
    required int page,
    required List<GitHubRepoModel> repositories,
  }) async {
    try {
      await localDataSource.cacheUserRepositories(
        username: username,
        page: page,
        repositories: repositories,
      );
    } catch (_) {
      // Ignore cache write failure.
    }
  }

  @override
  Future<void> addFavorite(GitHubUserEntity user) async {
    final model = GitHubUserModel(
      id: user.id,
      login: user.login,
      avatarUrl: user.avatarUrl,
      htmlUrl: user.htmlUrl,
      name: user.name,
      bio: user.bio,
      company: user.company,
      location: user.location,
      publicRepos: user.publicRepos,
      followers: user.followers,
      following: user.following,
    );

    await localDataSource.addFavorite(model);
  }

  @override
  Future<void> removeFavorite(String username) {
    return localDataSource.removeFavorite(username);
  }

  @override
  bool isFavorite(String username) {
    return localDataSource.isFavorite(username);
  }

  @override
  List<GitHubUserEntity> getFavorites() {
    return localDataSource.getFavorites();
  }
}

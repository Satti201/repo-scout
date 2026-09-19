import 'package:flutter_test/flutter_test.dart';
import 'package:repo_scout/core/errors/exceptions.dart';
import 'package:repo_scout/features/github/data/datasources/github_local_data_source.dart';
import 'package:repo_scout/features/github/data/datasources/github_remote_data_source.dart';
import 'package:repo_scout/features/github/data/models/github_repo_model.dart';
import 'package:repo_scout/features/github/data/models/github_user_model.dart';
import 'package:repo_scout/features/github/data/repositories/github_repository_impl.dart';

class FakeGitHubRemoteDataSource implements GitHubRemoteDataSource {
  GitHubUserModel? userProfileToReturn;
  Exception? userProfileException;

  List<GitHubRepoModel>? repositoriesToReturn;
  Exception? repositoriesException;

  List<GitHubUserModel>? searchUsersToReturn;
  Exception? searchUsersException;

  @override
  Future<GitHubUserModel> getUserProfile(String username) async {
    if (userProfileException != null) throw userProfileException!;
    return userProfileToReturn!;
  }

  @override
  Future<List<GitHubRepoModel>> getUserRepositories({
    required String username,
    int page = 1,
    int perPage = 30,
  }) async {
    if (repositoriesException != null) throw repositoriesException!;
    return repositoriesToReturn!;
  }

  @override
  Future<List<GitHubUserModel>> searchUsers({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    if (searchUsersException != null) throw searchUsersException!;
    return searchUsersToReturn!;
  }
}

class FakeGitHubLocalDataSource implements GitHubLocalDataSource {
  final Map<String, GitHubUserModel> cachedProfiles = {};
  final Map<String, List<GitHubRepoModel>> cachedRepositories = {};
  final Map<String, GitHubUserModel> favorites = {};

  Exception? addFavoriteException;
  Exception? removeFavoriteException;

  @override
  Future<void> cacheUserProfile(GitHubUserModel user) async {
    cachedProfiles[user.login.toLowerCase()] = user;
  }

  @override
  GitHubUserModel? getCachedUserProfile(String username) {
    return cachedProfiles[username.toLowerCase()];
  }

  @override
  Future<void> cacheUserRepositories({
    required String username,
    required int page,
    required List<GitHubRepoModel> repositories,
  }) async {
    cachedRepositories['${username.toLowerCase()}:$page'] = repositories;
  }

  @override
  List<GitHubRepoModel>? getCachedUserRepositories({
    required String username,
    required int page,
  }) {
    return cachedRepositories['${username.toLowerCase()}:$page'];
  }

  @override
  Future<void> addFavorite(GitHubUserModel user) async {
    if (addFavoriteException != null) throw addFavoriteException!;
    favorites[user.login.toLowerCase()] = user;
  }

  @override
  Future<void> removeFavorite(String username) async {
    if (removeFavoriteException != null) throw removeFavoriteException!;
    favorites.remove(username.toLowerCase());
  }

  @override
  bool isFavorite(String username) {
    return favorites.containsKey(username.toLowerCase());
  }

  @override
  List<GitHubUserModel> getFavorites() {
    return favorites.values.toList();
  }
}

void main() {
  late FakeGitHubRemoteDataSource fakeRemote;
  late FakeGitHubLocalDataSource fakeLocal;
  late GitHubRepositoryImpl repository;

  const testUser = GitHubUserModel(
    id: 1,
    login: 'octocat',
    avatarUrl: 'https://example.com/avatar.png',
    htmlUrl: 'https://github.com/octocat',
    name: 'The Octocat',
  );

  const testRepo = GitHubRepoModel(
    id: 101,
    name: 'Hello-World',
    fullName: 'octocat/Hello-World',
    htmlUrl: 'https://github.com/octocat/Hello-World',
    stargazersCount: 42,
  );

  setUp(() {
    fakeRemote = FakeGitHubRemoteDataSource();
    fakeLocal = FakeGitHubLocalDataSource();
    repository = GitHubRepositoryImpl(
      remoteDataSource: fakeRemote,
      localDataSource: fakeLocal,
    );
  });

  group('getUserProfile', () {
    test('Remote profile succeeds -> returns remote profile and writes to cache', () async {
      fakeRemote.userProfileToReturn = testUser;

      final result = await repository.getUserProfile('octocat');

      expect(result.login, 'octocat');
      expect(fakeLocal.getCachedUserProfile('octocat'), testUser);
    });

    test('Remote profile throws NetworkException + cache exists -> returns cached profile', () async {
      fakeRemote.userProfileException = const NetworkException('Connection error');
      await fakeLocal.cacheUserProfile(testUser);

      final result = await repository.getUserProfile('octocat');

      expect(result.login, 'octocat');
      expect(result.name, 'The Octocat');
    });

    test('Remote profile throws NetworkException + no cache -> NetworkException escapes', () async {
      fakeRemote.userProfileException = const NetworkException('Connection error');

      expect(
        () => repository.getUserProfile('octocat'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('Remote throws NotFoundException + cache exists -> DO NOT return cache and rethrow NotFoundException', () async {
      fakeRemote.userProfileException = const NotFoundException('User not found');
      await fakeLocal.cacheUserProfile(testUser);

      expect(
        () => repository.getUserProfile('octocat'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getUserRepositories', () {
    test('Remote repositories succeed -> returns remote repos and caches username/page', () async {
      fakeRemote.repositoriesToReturn = [testRepo];

      final result = await repository.getUserRepositories(username: 'octocat', page: 1);

      expect(result.length, 1);
      expect(result.first.name, 'Hello-World');
      final cached = fakeLocal.getCachedUserRepositories(username: 'octocat', page: 1);
      expect(cached, isNotNull);
      expect(cached!.first.name, 'Hello-World');
    });

    test('Remote repositories fail + cached page exists -> returns cached page', () async {
      fakeRemote.repositoriesException = const NetworkException('Connection error');
      await fakeLocal.cacheUserRepositories(
        username: 'octocat',
        page: 1,
        repositories: [testRepo],
      );

      final result = await repository.getUserRepositories(username: 'octocat', page: 1);

      expect(result.length, 1);
      expect(result.first.name, 'Hello-World');
    });

    test('Remote repositories fail + no cache -> rethrows exception', () async {
      fakeRemote.repositoriesException = const ServerException('500 internal error');

      expect(
        () => repository.getUserRepositories(username: 'octocat', page: 1),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('favorites', () {
    test('addFavorite stores user in local datasource', () async {
      await repository.addFavorite(testUser);

      expect(fakeLocal.isFavorite('octocat'), true);
      expect(repository.isFavorite('octocat'), true);
      expect(repository.getFavorites().length, 1);
      expect(repository.getFavorites().first.login, 'octocat');
    });

    test('removeFavorite removes user from local datasource', () async {
      await repository.addFavorite(testUser);
      expect(repository.isFavorite('octocat'), true);

      await repository.removeFavorite('octocat');
      expect(repository.isFavorite('octocat'), false);
      expect(repository.getFavorites(), isEmpty);
    });

    test('isFavorite returns false for non-favorited user', () {
      expect(repository.isFavorite('non_existent'), false);
    });
  });
}

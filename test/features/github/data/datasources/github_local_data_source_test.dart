import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:repo_scout/features/github/data/datasources/github_local_data_source_impl.dart';
import 'package:repo_scout/features/github/data/models/github_repo_model.dart';
import 'package:repo_scout/features/github/data/models/github_user_model.dart';

void main() {
  late Directory tempDir;
  late Box profilesBox;
  late Box reposBox;
  late Box favoritesBox;
  late GitHubLocalDataSourceImpl localDataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    profilesBox = await Hive.openBox('test_profiles');
    reposBox = await Hive.openBox('test_repos');
    favoritesBox = await Hive.openBox('test_favorites');

    localDataSource = GitHubLocalDataSourceImpl(
      profilesBox: profilesBox,
      repositoriesBox: reposBox,
      favoritesBox: favoritesBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('caches and retrieves user profile correctly', () async {
    const user = GitHubUserModel(
      id: 1,
      login: 'octocat',
      avatarUrl: 'https://example.com/avatar.png',
      htmlUrl: 'https://github.com/octocat',
      name: 'The Octocat',
    );

    await localDataSource.cacheUserProfile(user);
    final cached = localDataSource.getCachedUserProfile('octocat');

    expect(cached, isNotNull);
    expect(cached!.id, 1);
    expect(cached.login, 'octocat');
    expect(cached.name, 'The Octocat');
  });

  test('caches and retrieves user repositories pagination correctly', () async {
    const repo = GitHubRepoModel(
      id: 123,
      name: 'Hello-World',
      fullName: 'octocat/Hello-World',
      htmlUrl: 'https://github.com/octocat/Hello-World',
      stargazersCount: 42,
    );

    await localDataSource.cacheUserRepositories(
      username: 'octocat',
      page: 1,
      repositories: [repo],
    );

    final cachedRepos = localDataSource.getCachedUserRepositories(
      username: 'octocat',
      page: 1,
    );

    expect(cachedRepos, isNotNull);
    expect(cachedRepos!.length, 1);
    expect(cachedRepos.first.id, 123);
    expect(cachedRepos.first.stargazersCount, 42);
  });

  test('manages favorites correctly', () async {
    const user = GitHubUserModel(
      id: 1,
      login: 'octocat',
      avatarUrl: 'https://example.com/avatar.png',
      htmlUrl: 'https://github.com/octocat',
    );

    expect(localDataSource.isFavorite('octocat'), false);
    await localDataSource.addFavorite(user);
    expect(localDataSource.isFavorite('octocat'), true);
    expect(localDataSource.getFavorites().length, 1);

    await localDataSource.removeFavorite('octocat');
    expect(localDataSource.isFavorite('octocat'), false);
    expect(localDataSource.getFavorites(), isEmpty);
  });
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repo_scout/core/errors/exceptions.dart';
import 'package:repo_scout/core/network/connectivity_service.dart';
import 'package:repo_scout/features/github/data/models/github_repo_model.dart';
import 'package:repo_scout/features/github/data/models/github_user_model.dart';
import 'package:repo_scout/features/github/data/repositories/github_repository_impl.dart';
import 'package:repo_scout/features/github/domain/usecases/get_github_user_profile.dart';
import 'package:repo_scout/features/github/domain/usecases/get_github_user_repositories.dart';
import 'package:repo_scout/features/github/presentation/providers/user_profile_notifier.dart';

import '../../data/repositories/github_repository_impl_test.dart';

class FakeConnectivityService implements ConnectivityService {
  bool isConnected;
  FakeConnectivityService({this.isConnected = true});

  @override
  Connectivity get connectivity => throw UnimplementedError();

  @override
  Future<bool> get isOnline async => isConnected;
}

void main() {
  late FakeGitHubRemoteDataSource fakeRemote;
  late FakeGitHubLocalDataSource fakeLocal;
  late FakeConnectivityService fakeConnectivity;
  late UserProfileNotifier notifier;

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
    fakeConnectivity = FakeConnectivityService(isConnected: true);

    final repository = GitHubRepositoryImpl(
      remoteDataSource: fakeRemote,
      localDataSource: fakeLocal,
    );

    notifier = UserProfileNotifier(
      getUserProfileUseCase: GetGitHubUserProfileUseCase(repository),
      getUserRepositoriesUseCase: GetGitHubUserRepositoriesUseCase(repository),
      connectivityService: fakeConnectivity,
    );
  });

  test(
    'Case 1 & 2: Cached profile & repos + offline flag -> cache flags are true',
    () async {
      // Setup cached data in local storage
      await fakeLocal.cacheUserProfile(testUser);
      await fakeLocal.cacheUserRepositories(
        username: 'octocat',
        page: 1,
        repositories: [testRepo],
      );

      // Simulate remote failure and offline connection
      fakeRemote.userProfileException = const NetworkException('No connection');
      fakeRemote.repositoriesException = const NetworkException(
        'No connection',
      );
      fakeConnectivity.isConnected = false;

      await notifier.loadProfile('octocat');

      expect(notifier.state.user, isNotNull);
      expect(notifier.state.user!.login, 'octocat');
      expect(notifier.state.isUsingCachedProfile, true);
      expect(notifier.state.isUsingCachedRepositories, true);
      expect(notifier.state.repositories.length, 1);
    },
  );

  test(
    'Case 3: Existing repos + page 2 failure -> existing list preserved and friendly error',
    () async {
      fakeRemote.userProfileToReturn = testUser;
      fakeRemote.repositoriesToReturn = List.generate(
        30,
        (i) => GitHubRepoModel(
          id: 100 + i,
          name: 'repo-$i',
          fullName: 'octocat/repo-$i',
          htmlUrl: 'https://github.com/octocat/repo-$i',
        ),
      );

      // Load initial page successfully
      await notifier.loadProfile('octocat');
      expect(notifier.state.repositories.length, 30);
      expect(notifier.state.hasMoreRepos, true);

      // Page 2 fails
      fakeRemote.repositoriesException = const NetworkException(
        'Connection dropped',
      );
      await notifier.loadRepositories('octocat');

      expect(notifier.state.repositories.length, 30);
      expect(
        notifier.state.errorMessage,
        'Could not load more repositories. Check your connection and retry.',
      );
    },
  );

  test(
    'Case 4: No cache + network failure -> friendly offline message',
    () async {
      fakeRemote.userProfileException = const NetworkException('Offline');

      await notifier.loadProfile('unknown_user');

      expect(
        notifier.state.errorMessage,
        'No internet connection and no cached data is available.',
      );
    },
  );

  test('Case 5: NotFoundException -> "GitHub user not found."', () async {
    fakeRemote.userProfileException = const NotFoundException('404 Not Found');

    await notifier.loadProfile('deleted_user');

    expect(notifier.state.errorMessage, 'GitHub user not found.');
  });
}

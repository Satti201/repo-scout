import 'package:flutter_test/flutter_test.dart';
import 'package:repo_scout/features/github/data/models/github_user_model.dart';
import 'package:repo_scout/features/github/domain/usecases/add_favorite.dart';
import 'package:repo_scout/features/github/domain/usecases/get_favorites.dart';
import 'package:repo_scout/features/github/domain/usecases/is_favorite.dart';
import 'package:repo_scout/features/github/domain/usecases/remove_favorite.dart';
import 'package:repo_scout/features/github/presentation/providers/favorites_notifier.dart';

import 'package:repo_scout/features/github/data/repositories/github_repository_impl.dart';

import '../../data/repositories/github_repository_impl_test.dart';

void main() {
  late FakeGitHubRemoteDataSource fakeRemote;
  late FakeGitHubLocalDataSource fakeLocal;
  late FavoritesNotifier notifier;

  const testUser = GitHubUserModel(
    id: 1,
    login: 'octocat',
    avatarUrl: 'https://example.com/avatar.png',
    htmlUrl: 'https://github.com/octocat',
    name: 'The Octocat',
  );

  setUp(() {
    fakeRemote = FakeGitHubRemoteDataSource();
    fakeLocal = FakeGitHubLocalDataSource();

    // Use our tested GitHubRepositoryImpl with the fakes
    final repository = GitHubRepositoryImpl(
      remoteDataSource: fakeRemote,
      localDataSource: fakeLocal,
    );

    notifier = FavoritesNotifier(
      addFavoriteUseCase: AddFavoriteUseCase(repository),
      removeFavoriteUseCase: RemoveFavoriteUseCase(repository),
      isFavoriteUseCase: IsFavoriteUseCase(repository),
      getFavoritesUseCase: GetFavoritesUseCase(repository),
    );
  });

  test('initial state has empty favorites', () {
    expect(notifier.state.users, isEmpty);
  });

  test('toggleFavorite adds non-favorited user and updates state', () async {
    expect(notifier.isFavorite('octocat'), false);

    await notifier.toggleFavorite(testUser);

    expect(notifier.isFavorite('octocat'), true);
    expect(notifier.state.users.length, 1);
    expect(notifier.state.users.first.login, 'octocat');
  });

  test(
    'toggleFavorite removes already favorited user and updates state',
    () async {
      await notifier.toggleFavorite(testUser);
      expect(notifier.isFavorite('octocat'), true);
      expect(notifier.state.users.length, 1);

      await notifier.toggleFavorite(testUser);
      expect(notifier.isFavorite('octocat'), false);
      expect(notifier.state.users, isEmpty);
    },
  );

  test('loadFavorites updates state with existing favorites', () async {
    await fakeLocal.addFavorite(testUser);

    notifier.loadFavorites();

    expect(notifier.state.users.length, 1);
    expect(notifier.state.users.first.login, 'octocat');
  });

  test(
    'Case 6: Favorites write failure -> errorMessage set and existing favorites remain intact',
    () async {
      // Populate an existing favorite
      await fakeLocal.addFavorite(testUser);
      notifier.loadFavorites();
      expect(notifier.state.users.length, 1);
      expect(notifier.state.errorMessage, isNull);

      const newUser = GitHubUserModel(
        id: 2,
        login: 'flutter',
        avatarUrl: 'https://example.com/flutter.png',
        htmlUrl: 'https://github.com/flutter',
      );

      // Simulate write failure
      fakeLocal.addFavoriteException = Exception('Disk write error');

      await notifier.toggleFavorite(newUser);

      expect(notifier.state.errorMessage, contains('Disk write error'));
      expect(notifier.state.users.length, 1);
      expect(notifier.state.users.first.login, 'octocat');
    },
  );
}

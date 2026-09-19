import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/github_local_data_source.dart';
import '../../data/datasources/github_local_data_source_impl.dart';
import '../../data/datasources/github_remote_data_source.dart';
import '../../data/datasources/github_remote_data_source_impl.dart';
import '../../data/repositories/github_repository_impl.dart';
import '../../domain/repositories/github_repository.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_github_user_profile.dart';
import '../../domain/usecases/get_github_user_repositories.dart';
import '../../domain/usecases/is_favorite.dart';
import '../../domain/usecases/remove_favorite.dart';
import '../../domain/usecases/search_github_users.dart';
import 'favorites_notifier.dart';
import 'favorites_state.dart';
import 'search_users_notifier.dart';
import 'search_users_state.dart';
import 'user_profile_notifier.dart';
import 'user_profile_state.dart';

final dioProvider = Provider<Dio>((ref) {
  return createDioClient();
});

final githubRemoteDataSourceProvider =
    Provider<GitHubRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);

  return GitHubRemoteDataSourceImpl(dio);
});

final githubLocalDataSourceProvider =
    Provider<GitHubLocalDataSource>((ref) {
  return GitHubLocalDataSourceImpl(
    profilesBox: Hive.box(githubProfilesBox),
    repositoriesBox: Hive.box(githubReposBox),
    favoritesBox: Hive.box(githubFavoritesBox),
  );
});

final githubRepositoryProvider =
    Provider<GitHubRepository>((ref) {
  final remoteDataSource =
      ref.watch(githubRemoteDataSourceProvider);
  final localDataSource =
      ref.watch(githubLocalDataSourceProvider);

  return GitHubRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final searchGitHubUsersUseCaseProvider =
    Provider<SearchGitHubUsersUseCase>((ref) {
  final repository =
      ref.watch(githubRepositoryProvider);

  return SearchGitHubUsersUseCase(
    repository,
  );
});

final getGitHubUserProfileUseCaseProvider =
    Provider<GetGitHubUserProfileUseCase>((ref) {
  final repository =
      ref.watch(githubRepositoryProvider);

  return GetGitHubUserProfileUseCase(
    repository,
  );
});

final getGitHubUserRepositoriesUseCaseProvider =
    Provider<GetGitHubUserRepositoriesUseCase>((ref) {
  final repository =
      ref.watch(githubRepositoryProvider);

  return GetGitHubUserRepositoriesUseCase(
    repository,
  );
});

final addFavoriteUseCaseProvider = Provider<AddFavoriteUseCase>((ref) {
  return AddFavoriteUseCase(
    ref.watch(githubRepositoryProvider),
  );
});

final removeFavoriteUseCaseProvider = Provider<RemoveFavoriteUseCase>((ref) {
  return RemoveFavoriteUseCase(
    ref.watch(githubRepositoryProvider),
  );
});

final isFavoriteUseCaseProvider = Provider<IsFavoriteUseCase>((ref) {
  return IsFavoriteUseCase(
    ref.watch(githubRepositoryProvider),
  );
});

final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>((ref) {
  return GetFavoritesUseCase(
    ref.watch(githubRepositoryProvider),
  );
});

final searchUsersNotifierProvider =
    StateNotifierProvider<SearchUsersNotifier, SearchUsersState>((ref) {
  final useCase = ref.watch(searchGitHubUsersUseCaseProvider);

  return SearchUsersNotifier(useCase);
});

final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final profileUseCase = ref.watch(getGitHubUserProfileUseCaseProvider);
  final reposUseCase = ref.watch(getGitHubUserRepositoriesUseCaseProvider);

  return UserProfileNotifier(
    profileUseCase,
    reposUseCase,
  );
});

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(
    addFavoriteUseCase: ref.watch(addFavoriteUseCaseProvider),
    removeFavoriteUseCase: ref.watch(removeFavoriteUseCaseProvider),
    isFavoriteUseCase: ref.watch(isFavoriteUseCaseProvider),
    getFavoritesUseCase: ref.watch(getFavoritesUseCaseProvider),
  );
});

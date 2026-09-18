import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/github_remote_data_source.dart';
import '../../data/datasources/github_remote_data_source_impl.dart';
import '../../data/repositories/github_repository_impl.dart';
import '../../domain/repositories/github_repository.dart';
import '../../domain/usecases/get_github_user_profile.dart';
import '../../domain/usecases/get_github_user_repositories.dart';
import '../../domain/usecases/search_github_users.dart';
import 'search_users_notifier.dart';
import 'search_users_state.dart';

final dioProvider = Provider<Dio>((ref) {
  return createDioClient();
});

final githubRemoteDataSourceProvider =
    Provider<GitHubRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);

  return GitHubRemoteDataSourceImpl(dio);
});

final githubRepositoryProvider =
    Provider<GitHubRepository>((ref) {
  final remoteDataSource =
      ref.watch(githubRemoteDataSourceProvider);

  return GitHubRepositoryImpl(
    remoteDataSource,
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

final searchUsersNotifierProvider =
    StateNotifierProvider<SearchUsersNotifier, SearchUsersState>((ref) {
  final useCase = ref.watch(searchGitHubUsersUseCaseProvider);

  return SearchUsersNotifier(useCase);
});

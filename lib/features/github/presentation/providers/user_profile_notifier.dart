import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/usecases/get_github_user_profile.dart';
import '../../domain/usecases/get_github_user_repositories.dart';
import 'user_profile_state.dart';

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final GetGitHubUserProfileUseCase getUserProfileUseCase;
  final GetGitHubUserRepositoriesUseCase getUserRepositoriesUseCase;
  final ConnectivityService connectivityService;

  UserProfileNotifier({
    required this.getUserProfileUseCase,
    required this.getUserRepositoriesUseCase,
    required this.connectivityService,
  }) : super(const UserProfileState());

  Future<void> loadProfile(String username) async {
    state = const UserProfileState(isLoadingProfile: true);

    try {
      final isOnline = await connectivityService.isOnline;
      final user = await getUserProfileUseCase(username);

      state = state.copyWith(
        user: user,
        isLoadingProfile: false,
        isUsingCachedProfile: !isOnline,
        clearError: true,
      );

      await loadRepositories(username, reset: true);
    } catch (e) {
      state = state.copyWith(
        isLoadingProfile: false,
        errorMessage: _friendlyMessage(e),
      );
    }
  }

  Future<void> loadRepositories(String username, {bool reset = false}) async {
    if (state.isLoadingRepos) return;

    final page = reset ? 1 : state.currentRepoPage + 1;

    if (!reset && !state.hasMoreRepos) {
      return;
    }

    state = state.copyWith(isLoadingRepos: true, clearError: true);

    try {
      final isOnline = await connectivityService.isOnline;
      final repos = await getUserRepositoriesUseCase(
        username: username,
        page: page,
      );

      state = state.copyWith(
        isLoadingRepos: false,
        repositories: reset ? repos : [...state.repositories, ...repos],
        currentRepoPage: page,
        hasMoreRepos: repos.length == 30,
        isUsingCachedRepositories: !isOnline,
      );
    } catch (e) {
      final message = (!reset && state.repositories.isNotEmpty)
          ? 'Could not load more repositories. Check your connection and retry.'
          : (state.repositories.isEmpty
                ? 'Could not load repositories.'
                : _friendlyMessage(e));

      state = state.copyWith(isLoadingRepos: false, errorMessage: message);
    }
  }

  String _friendlyMessage(Object error) {
    if (error is NetworkException) {
      return 'No internet connection and no cached data is available.';
    }

    if (error is RateLimitException) {
      return 'GitHub API rate limit reached. Try again later.';
    }

    if (error is NotFoundException) {
      return 'GitHub user not found.';
    }

    if (error is ServerException) {
      return 'GitHub is unavailable right now. Please try again.';
    }

    return 'Something went wrong.';
  }
}

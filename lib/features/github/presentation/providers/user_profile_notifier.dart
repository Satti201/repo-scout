import 'package:flutter_riverpod/legacy.dart';

import '../../domain/usecases/get_github_user_profile.dart';
import '../../domain/usecases/get_github_user_repositories.dart';
import 'user_profile_state.dart';

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final GetGitHubUserProfileUseCase getUserProfileUseCase;
  final GetGitHubUserRepositoriesUseCase getUserRepositoriesUseCase;

  UserProfileNotifier(
    this.getUserProfileUseCase,
    this.getUserRepositoriesUseCase,
  ) : super(const UserProfileState());

  Future<void> loadProfile(String username) async {
    state = const UserProfileState(
      isLoadingProfile: true,
    );

    try {
      final user = await getUserProfileUseCase(username);

      state = state.copyWith(
        user: user,
        isLoadingProfile: false,
        clearError: true,
      );

      await loadRepositories(
        username,
        reset: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProfile: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadRepositories(
    String username, {
    bool reset = false,
  }) async {
    if (state.isLoadingRepos) return;

    final page = reset ? 1 : state.currentRepoPage + 1;

    if (!reset && !state.hasMoreRepos) {
      return;
    }

    state = state.copyWith(
      isLoadingRepos: true,
      clearError: true,
    );

    try {
      final repos = await getUserRepositoriesUseCase(
        username: username,
        page: page,
      );

      state = state.copyWith(
        isLoadingRepos: false,
        repositories: reset
            ? repos
            : [
                ...state.repositories,
                ...repos,
              ],
        currentRepoPage: page,
        hasMoreRepos: repos.length == 30,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingRepos: false,
        errorMessage: e.toString(),
      );
    }
  }
}

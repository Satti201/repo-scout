import '../../domain/entities/github_repo_entity.dart';
import '../../domain/entities/github_user_entity.dart';

class UserProfileState {
  final bool isLoadingProfile;
  final bool isLoadingRepos;

  final GitHubUserEntity? user;
  final List<GitHubRepoEntity> repositories;

  final String? errorMessage;

  final int currentRepoPage;
  final bool hasMoreRepos;

  final bool isUsingCachedProfile;
  final bool isUsingCachedRepositories;

  const UserProfileState({
    this.isLoadingProfile = false,
    this.isLoadingRepos = false,
    this.user,
    this.repositories = const [],
    this.errorMessage,
    this.currentRepoPage = 1,
    this.hasMoreRepos = true,
    this.isUsingCachedProfile = false,
    this.isUsingCachedRepositories = false,
  });

  UserProfileState copyWith({
    bool? isLoadingProfile,
    bool? isLoadingRepos,
    GitHubUserEntity? user,
    List<GitHubRepoEntity>? repositories,
    String? errorMessage,
    bool clearError = false,
    int? currentRepoPage,
    bool? hasMoreRepos,
    bool? isUsingCachedProfile,
    bool? isUsingCachedRepositories,
  }) {
    return UserProfileState(
      isLoadingProfile:
          isLoadingProfile ?? this.isLoadingProfile,
      isLoadingRepos:
          isLoadingRepos ?? this.isLoadingRepos,
      user: user ?? this.user,
      repositories:
          repositories ?? this.repositories,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      currentRepoPage:
          currentRepoPage ?? this.currentRepoPage,
      hasMoreRepos:
          hasMoreRepos ?? this.hasMoreRepos,
      isUsingCachedProfile:
          isUsingCachedProfile ?? this.isUsingCachedProfile,
      isUsingCachedRepositories:
          isUsingCachedRepositories ?? this.isUsingCachedRepositories,
    );
  }
}

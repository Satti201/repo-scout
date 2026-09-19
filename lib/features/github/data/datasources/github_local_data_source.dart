import '../models/github_repo_model.dart';
import '../models/github_user_model.dart';

abstract class GitHubLocalDataSource {
  Future<void> cacheUserProfile(GitHubUserModel user);

  GitHubUserModel? getCachedUserProfile(String username);

  Future<void> cacheUserRepositories({
    required String username,
    required int page,
    required List<GitHubRepoModel> repositories,
  });

  List<GitHubRepoModel>? getCachedUserRepositories({
    required String username,
    required int page,
  });

  Future<void> addFavorite(GitHubUserModel user);

  Future<void> removeFavorite(String username);

  bool isFavorite(String username);

  List<GitHubUserModel> getFavorites();
}

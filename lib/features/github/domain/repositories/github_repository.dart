import '../entities/github_user_entity.dart';
import '../entities/github_repo_entity.dart';

/// Abstract contract for GitHub repository operations in the Domain layer.
abstract class GitHubRepository {
  /// Searches GitHub users matching [query] with pagination support.
  Future<List<GitHubUserEntity>> searchUsers({
    required String query,
    int page = 1,
    int perPage = 30,
  });

  /// Fetches detailed profile information for a specific [username].
  Future<GitHubUserEntity> getUserProfile(String username);

  /// Fetches public repositories belonging to [username] with pagination support.
  Future<List<GitHubRepoEntity>> getUserRepositories({
    required String username,
    int page = 1,
    int perPage = 30,
  });

  /// Adds a user to favorites.
  Future<void> addFavorite(GitHubUserEntity user);

  /// Removes a user from favorites by username.
  Future<void> removeFavorite(String username);

  /// Checks if a username is favorited.
  bool isFavorite(String username);

  /// Returns all favorited users.
  List<GitHubUserEntity> getFavorites();
}

import '../models/github_repo_model.dart';
import '../models/github_user_model.dart';

abstract class GitHubRemoteDataSource {
  Future<List<GitHubUserModel>> searchUsers({
    required String query,
    int page = 1,
    int perPage = 30,
  });

  Future<GitHubUserModel> getUserProfile(String username);

  Future<List<GitHubRepoModel>> getUserRepositories({
    required String username,
    int page = 1,
    int perPage = 30,
  });
}

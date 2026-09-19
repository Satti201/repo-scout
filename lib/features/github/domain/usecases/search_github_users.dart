import '../entities/github_user_entity.dart';
import '../repositories/github_repository.dart';

class SearchGitHubUsersUseCase {
  final GitHubRepository repository;

  SearchGitHubUsersUseCase(this.repository);

  Future<List<GitHubUserEntity>> call({
    required String query,
    int page = 1,
    int perPage = 30,
  }) {
    return repository.searchUsers(query: query, page: page, perPage: perPage);
  }
}

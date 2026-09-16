import '../entities/github_repo_entity.dart';
import '../repositories/github_repository.dart';

class GetGitHubUserRepositoriesUseCase {
  final GitHubRepository repository;

  GetGitHubUserRepositoriesUseCase(this.repository);

  Future<List<GitHubRepoEntity>> call({
    required String username,
    int page = 1,
    int perPage = 30,
  }) {
    return repository.getUserRepositories(
      username: username,
      page: page,
      perPage: perPage,
    );
  }
}

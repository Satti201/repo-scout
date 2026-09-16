import '../entities/github_user_entity.dart';
import '../repositories/github_repository.dart';

class GetGitHubUserProfileUseCase {
  final GitHubRepository repository;

  GetGitHubUserProfileUseCase(this.repository);

  Future<GitHubUserEntity> call(String username) {
    return repository.getUserProfile(username);
  }
}

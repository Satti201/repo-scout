import '../entities/github_user_entity.dart';
import '../repositories/github_repository.dart';

class AddFavoriteUseCase {
  final GitHubRepository repository;

  AddFavoriteUseCase(this.repository);

  Future<void> call(GitHubUserEntity user) {
    return repository.addFavorite(user);
  }
}

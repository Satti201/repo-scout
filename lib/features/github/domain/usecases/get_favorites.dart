import '../entities/github_user_entity.dart';
import '../repositories/github_repository.dart';

class GetFavoritesUseCase {
  final GitHubRepository repository;

  GetFavoritesUseCase(this.repository);

  List<GitHubUserEntity> call() {
    return repository.getFavorites();
  }
}

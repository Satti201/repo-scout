import '../repositories/github_repository.dart';

class RemoveFavoriteUseCase {
  final GitHubRepository repository;

  RemoveFavoriteUseCase(this.repository);

  Future<void> call(String username) {
    return repository.removeFavorite(username);
  }
}

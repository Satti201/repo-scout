import '../repositories/github_repository.dart';

class IsFavoriteUseCase {
  final GitHubRepository repository;

  IsFavoriteUseCase(this.repository);

  bool call(String username) {
    return repository.isFavorite(username);
  }
}

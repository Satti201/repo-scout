import '../../domain/entities/github_user_entity.dart';

class FavoritesState {
  final List<GitHubUserEntity> users;
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FavoritesState copyWith({
    List<GitHubUserEntity>? users,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

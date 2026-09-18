import '../../domain/entities/github_user_entity.dart';

class SearchUsersState {
  final bool isLoading;
  final List<GitHubUserEntity> users;
  final String? errorMessage;
  final String query;
  final int currentPage;
  final bool hasMore;

  const SearchUsersState({
    this.isLoading = false,
    this.users = const [],
    this.errorMessage,
    this.query = '',
    this.currentPage = 1,
    this.hasMore = true,
  });

  SearchUsersState copyWith({
    bool? isLoading,
    List<GitHubUserEntity>? users,
    String? errorMessage,
    bool clearError = false,
    String? query,
    int? currentPage,
    bool? hasMore,
  }) {
    return SearchUsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

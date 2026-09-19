import 'package:flutter_riverpod/legacy.dart';

import '../../domain/usecases/search_github_users.dart';
import 'search_users_state.dart';

class SearchUsersNotifier extends StateNotifier<SearchUsersState> {
  final SearchGitHubUsersUseCase searchUsersUseCase;

  SearchUsersNotifier(this.searchUsersUseCase)
    : super(const SearchUsersState());

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      state = const SearchUsersState();
      return;
    }

    state = SearchUsersState(
      isLoading: true,
      query: trimmedQuery,
      currentPage: 1,
    );

    try {
      final users = await searchUsersUseCase(query: trimmedQuery, page: 1);

      state = state.copyWith(
        isLoading: false,
        users: users,
        currentPage: 1,
        hasMore: users.length == 30,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.query.isEmpty) {
      return;
    }

    final nextPage = state.currentPage + 1;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final newUsers = await searchUsersUseCase(
        query: state.query,
        page: nextPage,
      );

      state = state.copyWith(
        isLoading: false,
        users: [...state.users, ...newUsers],
        currentPage: nextPage,
        hasMore: newUsers.length == 30,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    if (state.query.isEmpty) return;

    await search(state.query);
  }
}

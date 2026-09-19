import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/github_user_entity.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/is_favorite.dart';
import '../../domain/usecases/remove_favorite.dart';
import 'favorites_state.dart';

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  final IsFavoriteUseCase isFavoriteUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;

  FavoritesNotifier({
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.isFavoriteUseCase,
    required this.getFavoritesUseCase,
  }) : super(const FavoritesState());

  void loadFavorites() {
    state = state.copyWith(
      users: getFavoritesUseCase(),
      clearError: true,
    );
  }

  bool isFavorite(String username) {
    return isFavoriteUseCase(username);
  }

  Future<void> toggleFavorite(GitHubUserEntity user) async {
    try {
      if (isFavorite(user.login)) {
        await removeFavoriteUseCase(user.login);
      } else {
        await addFavoriteUseCase(user);
      }

      loadFavorites();
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    }
  }
}

import 'package:hive/hive.dart';

import '../models/github_repo_model.dart';
import '../models/github_user_model.dart';
import 'github_local_data_source.dart';

class GitHubLocalDataSourceImpl implements GitHubLocalDataSource {
  final Box profilesBox;
  final Box repositoriesBox;
  final Box favoritesBox;

  GitHubLocalDataSourceImpl({
    required this.profilesBox,
    required this.repositoriesBox,
    required this.favoritesBox,
  });

  @override
  Future<void> cacheUserProfile(GitHubUserModel user) async {
    await profilesBox.put(user.login.toLowerCase(), user.toJson());
  }

  @override
  GitHubUserModel? getCachedUserProfile(String username) {
    final raw = profilesBox.get(username.toLowerCase());

    if (raw == null) return null;

    return GitHubUserModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  String _repoPageKey(String username, int page) {
    return '${username.toLowerCase()}:$page';
  }

  @override
  Future<void> cacheUserRepositories({
    required String username,
    required int page,
    required List<GitHubRepoModel> repositories,
  }) async {
    await repositoriesBox.put(
      _repoPageKey(username, page),
      repositories.map((repo) => repo.toJson()).toList(),
    );
  }

  @override
  List<GitHubRepoModel>? getCachedUserRepositories({
    required String username,
    required int page,
  }) {
    final raw = repositoriesBox.get(_repoPageKey(username, page));

    if (raw == null) return null;

    final list = raw as List;

    return list
        .map(
          (item) =>
              GitHubRepoModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<void> addFavorite(GitHubUserModel user) async {
    await favoritesBox.put(user.login.toLowerCase(), user.toJson());
  }

  @override
  Future<void> removeFavorite(String username) {
    return favoritesBox.delete(username.toLowerCase());
  }

  @override
  bool isFavorite(String username) {
    return favoritesBox.containsKey(username.toLowerCase());
  }

  @override
  List<GitHubUserModel> getFavorites() {
    return favoritesBox.values
        .map(
          (raw) =>
              GitHubUserModel.fromJson(Map<String, dynamic>.from(raw as Map)),
        )
        .toList();
  }
}

import 'package:hive_flutter/hive_flutter.dart';

const githubProfilesBox = 'github_profiles';
const githubReposBox = 'github_repositories';
const githubFavoritesBox = 'github_favorites';

Future<void> initializeLocalStorage() async {
  await Hive.initFlutter();

  await Future.wait([
    Hive.openBox(githubProfilesBox),
    Hive.openBox(githubReposBox),
    Hive.openBox(githubFavoritesBox),
  ]);
}

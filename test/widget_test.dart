import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_scout/features/github/domain/entities/github_repo_entity.dart';
import 'package:repo_scout/features/github/domain/entities/github_user_entity.dart';
import 'package:repo_scout/features/github/domain/repositories/github_repository.dart';
import 'package:repo_scout/features/github/presentation/providers/github_dependencies.dart';
import 'package:repo_scout/main.dart';

class FakeGitHubRepository implements GitHubRepository {
  @override
  Future<GitHubUserEntity> getUserProfile(String username) async {
    throw UnimplementedError();
  }

  @override
  Future<List<GitHubRepoEntity>> getUserRepositories({
    required String username,
    int page = 1,
    int perPage = 30,
  }) async {
    return [];
  }

  @override
  Future<List<GitHubUserEntity>> searchUsers({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    return [];
  }
}

void main() {
  testWidgets('App renders RepoScout search screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          githubRepositoryProvider.overrideWithValue(FakeGitHubRepository()),
        ],
        child: const RepoScoutApp(),
      ),
    );

    expect(find.text('RepoScout'), findsOneWidget);
    expect(find.text('Search for a GitHub user'), findsOneWidget);
  });
}

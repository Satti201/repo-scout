import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_scout/main.dart';

void main() {
  testWidgets('App renders RepoScout search screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RepoScoutApp(),
      ),
    );

    expect(find.text('RepoScout'), findsOneWidget);
    expect(find.text('Search for a GitHub user'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_scout/main.dart';

void main() {
  testWidgets('App renders RepoScout title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RepoScoutApp(),
      ),
    );

    expect(find.text('RepoScout - GitHub Explorer'), findsOneWidget);
  });
}

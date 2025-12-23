import 'package:flutter_test/flutter_test.dart';
import 'package:octolist/screens/home_screen.dart';
// package:octolist/graphql/anilist_client.dart removed as it was unused
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
// package:gql/src/http.dart removed

void main() {
  testWidgets('HomeScreen renders', (WidgetTester tester) async {
    // We create a simpler mock or just a dummy client that doesn't make requests immediately
    // or just checking if the widget builds.

    final client = ValueNotifier(
      GraphQLClient(
        link: HttpLink(
          'https://example.com',
        ), // No actual request made if we don't pump frames or if we mock
        cache: GraphQLCache(),
      ),
    );

    // To prevent actual network calls causing issues or "400" in tests, we ideally mock the link.
    // But for a simple compile check:

    await tester.pumpWidget(
      GraphQLProvider(
        client: client,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // We verify the AppBar text which is static and doesn't require network
    expect(find.text('OctoList - Trending'), findsOneWidget);

    // We don't pumpAndSettle bc that would trigger network limits/errors
  });
}

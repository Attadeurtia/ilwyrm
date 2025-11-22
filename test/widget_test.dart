import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilwyrm/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: IlwyrmApp()));

    // Verify that our app starts.
    expect(find.text('Ilwyrm'), findsOneWidget);
  });
}

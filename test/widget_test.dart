import 'package:flutter_test/flutter_test.dart';

import 'package:andenken_app/app.dart';

void main() {
  testWidgets('abre a rota /decks', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Decks'), findsWidgets);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:andenken_app/app.dart';

import 'fakes/fake_auth_repository.dart';

void main() {
  testWidgets('visitante abre o app em /login', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(authRepository: FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('ANDENKEN'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}

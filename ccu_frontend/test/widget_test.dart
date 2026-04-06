import 'package:flutter_test/flutter_test.dart';
import 'package:ccu_mobile/main.dart';

void main() {
  testWidgets('Carga inicial de la app - Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CCUApp(
      isLoggedIn: false,
      userName: "Estudiante",
      userEmail: "",
    ));

    expect(find.text('Ingresar'), findsOneWidget);

    expect(find.text('0'), findsNothing);
  });
}
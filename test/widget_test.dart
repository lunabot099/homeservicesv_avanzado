import 'package:flutter_test/flutter_test.dart';
import 'package:homeservicesv/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}

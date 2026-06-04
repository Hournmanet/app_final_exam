import 'package:flutter_test/flutter_test.dart';
import 'package:final_exam/app.dart';
import 'package:final_exam/config/app_environment.dart';

void main() {
  testWidgets('ITE Store home loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const IteStoreApp(environment: AppEnvironment.production),
    );
    await tester.pump();
    expect(find.text('ITE Store'), findsOneWidget);
  });
}

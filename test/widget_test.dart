import 'package:flutter_test/flutter_test.dart';
import 'package:the_film_app/main.dart';

void main() {
  testWidgets('TheFilmApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TheFilmApp());
    expect(find.byType(TheFilmApp), findsOneWidget);
  });
}

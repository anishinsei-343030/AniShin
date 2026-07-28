import 'package:flutter_test/flutter_test.dart';

import 'package:anime_app/main.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimeApp());
    expect(find.text('AnimeApp'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:xworkmate/app/app.dart';

void main() {
  testWidgets('renders XWorkmate shell', (WidgetTester tester) async {
    await tester.pumpWidget(const XWorkmateApp());

    expect(find.text('XWorkmate'), findsWidgets);
    expect(find.text('Assistant'), findsWidgets);
  });
}
